import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  static const String deviceName = 'AgriVora_pH_ESP32';
  static const String serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String phCharUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _phChar;
  StreamSubscription? _scanSub;
  StreamSubscription? _connSub;
  StreamSubscription? _valueSub;

  final List<double> _phBuffer = [];
  static const int _filterSize = 5;

  int _stabilizingSec = 0;
  bool _probeStable = false;

  bool _isConnected = false;
  bool _scanning = false;
  Timer? _simTimer;
  Timer? _stabilizeTimer;

  final _phCtrl = StreamController<double?>.broadcast();
  final _rawCtrl = StreamController<PhReading?>.broadcast();
  final _statusCtrl = StreamController<BleStatus>.broadcast();

  Stream<double?> get phStream => _phCtrl.stream;
  Stream<PhReading?> get rawStream => _rawCtrl.stream;
  Stream<BleStatus> get statusStream => _statusCtrl.stream;

  bool get isConnected => _isConnected;

  void _emit(String msg,
      {BleConnectionState state = BleConnectionState.scanning}) {
    debugPrint('[BLE] $msg');
    _statusCtrl.add(BleStatus(message: msg, state: state));
    _isConnected = state == BleConnectionState.connected;
  }

  PhReading? _decode(List<int> bytes) {
    try {
      final raw = utf8.decode(bytes).trim();

      if (raw.isEmpty) return null;

      if (raw.startsWith('{')) {
        final map = json.decode(raw) as Map<String, dynamic>;
        return PhReading(
          ph: (map['ph'] as num).toDouble(),
          voltage: (map['v'] as num?)?.toDouble(),
          temperature: (map['t'] as num?)?.toDouble(),
          timestamp: DateTime.now(),
        );
      }

      final parts = raw.split(',');
      return PhReading(
        ph: double.parse(parts.first.trim()),
        voltage: parts.length > 1 ? double.tryParse(parts[1].trim()) : null,
        temperature:
            parts.length > 2 ? double.tryParse(parts[2].trim()) : null,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  double? _filter(double rawPh) {
    if (rawPh < 0 || rawPh > 14) return null;

    _phBuffer.add(rawPh);

    if (_phBuffer.length > _filterSize) {
      _phBuffer.removeAt(0);
    }

    final sum = _phBuffer.fold(0.0, (a, b) => a + b);
    final avg = sum / _phBuffer.length;

    return double.parse(avg.toStringAsFixed(2));
  }

  void _startStabilisationTimer() {
    _probeStable = false;
    _stabilizingSec = 0;

    _stabilizeTimer?.cancel();

    _stabilizeTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _stabilizingSec++;

      if (_stabilizingSec < 20) {
        _emit('Probe stabilizing… (${20 - _stabilizingSec}s)',
            state: BleConnectionState.stabilizing);
      } else {
        _probeStable = true;
        timer.cancel();
        _emit('Probe stable – reading live pH',
            state: BleConnectionState.connected);
      }
    });
  }

  void _startSimulation() {
    _simTimer?.cancel();

    final rand = Random();
    double base = 6.2 + rand.nextDouble() * 0.6;

    _emit('ESP32 not found. Showing simulated data…',
        state: BleConnectionState.simulating);

    _simTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isConnected) {
        _simTimer?.cancel();
        return;
      }

      base = (base + (rand.nextDouble() - 0.5) * 0.04).clamp(5.5, 7.5);
      final sim = double.parse(base.toStringAsFixed(2));

      _phCtrl.add(sim);
      _rawCtrl.add(
        PhReading(
          ph: sim,
          timestamp: DateTime.now(),
          simulated: true,
        ),
      );
    });
  }

  Future<void> startScanAndConnect({String? targetMac}) async {
    if (_scanning) return;

    _scanning = true;

    await disconnect(emitStatus: false);

    if (defaultTargetPlatform == TargetPlatform.android) {
      final statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (statuses[Permission.bluetoothScan]?.isDenied == true ||
          statuses[Permission.bluetoothConnect]?.isDenied == true) {
        _emit('Bluetooth permissions denied.',
            state: BleConnectionState.error);
        _scanning = false;
        return;
      }
    }

    if (!await FlutterBluePlus.isSupported) {
      _emit('Bluetooth not supported',
          state: BleConnectionState.error);
      _scanning = false;
      return;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;

    if (adapterState != BluetoothAdapterState.on) {
      _emit('Bluetooth is OFF',
          state: BleConnectionState.error);
      _scanning = false;
      return;
    }

    _emit('Scanning for device...',
        state: BleConnectionState.scanning);

    await FlutterBluePlus.stopScan();

    bool found = false;

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : r.advertisementData.advName;

        final mac = r.device.remoteId.str.toUpperCase();

        bool match = false;

        if (targetMac != null) {
          match = mac == targetMac.toUpperCase();
        } else {
          match = name == deviceName;
        }

        if (match) {
          found = true;
          FlutterBluePlus.stopScan();
          _connectToDevice(r.device);
          break;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 12));
    await Future.delayed(const Duration(seconds: 12));

    _scanning = false;

    if (!found && !_isConnected) {
      _startSimulation();

      Future.delayed(const Duration(seconds: 30), () {
        if (!_isConnected) {
          startScanAndConnect(targetMac: targetMac);
        }
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _device = device;

    _emit('Connecting...',
        state: BleConnectionState.connecting);

    _connSub = device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.disconnected) {
        _isConnected = false;

        _phCtrl.add(null);
        _rawCtrl.add(null);

        _stabilizeTimer?.cancel();

        _emit('Disconnected',
            state: BleConnectionState.disconnected);

        _device = null;
        _phChar = null;

        await Future.delayed(const Duration(seconds: 5));

        startScanAndConnect();
      } else if (state == BluetoothConnectionState.connected) {
        _emit('Connected',
            state: BleConnectionState.connected);

        await _discoverAndSubscribe(device);
      }
    });

    try {
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      _emit('Connection failed: $e',
          state: BleConnectionState.error);
    }
  }

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      for (final svc in services) {
        if (svc.uuid.toString().toLowerCase() != serviceUuid) continue;

        for (final char in svc.characteristics) {
          if (char.uuid.toString().toLowerCase() != phCharUuid) continue;

          _phChar = char;

          _startStabilisationTimer();

          await char.setNotifyValue(true);

          _valueSub = char.lastValueStream.listen((bytes) {
            if (bytes.isEmpty) return;

            final reading = _decode(bytes);

            if (reading == null) return;

            if (_phBuffer.isNotEmpty &&
                (reading.ph - _phBuffer.last).abs() > 1.0) {
              return;
            }

            final filtered = _filter(reading.ph);

            if (filtered == null) return;

            _phCtrl.add(filtered);
            _rawCtrl.add(reading.copyWith(ph: filtered));
          });

          return;
        }
      }

      _emit('pH characteristic not found',
          state: BleConnectionState.connected);
    } catch (e) {
      _emit('Service discovery failed: $e',
          state: BleConnectionState.error);
    }
  }

  Future<void> disconnect({bool emitStatus = true}) async {
    _simTimer?.cancel();
    _stabilizeTimer?.cancel();

    await _scanSub?.cancel();
    await _valueSub?.cancel();
    await _connSub?.cancel();

    try {
      await _device?.disconnect();
    } catch (_) {}

    _device = null;
    _phChar = null;

    _phBuffer.clear();

    _isConnected = false;
    _probeStable = false;
    _stabilizingSec = 0;

    if (emitStatus) {
      _phCtrl.add(null);
      _rawCtrl.add(null);
      _emit('Disconnected',
          state: BleConnectionState.disconnected);
    }
  }
}

enum BleConnectionState {
  scanning,
  connecting,
  stabilizing,
  connected,
  simulating,
  disconnected,
  error
}

class BleStatus {
  final String message;
  final BleConnectionState state;

  const BleStatus({
    required this.message,
    required this.state,
  });
}

class PhReading {
  final double ph;
  final double? voltage;
  final double? temperature;
  final DateTime timestamp;
  final bool simulated;

  const PhReading({
    required this.ph,
    required this.timestamp,
    this.voltage,
    this.temperature,
    this.simulated = false,
  });

  PhReading copyWith({double? ph}) => PhReading(
        ph: ph ?? this.ph,
        voltage: voltage,
        temperature: temperature,
        timestamp: timestamp,
        simulated: simulated,
      );

  String get category {
    if (ph < 5.5) return 'Strongly Acidic';
    if (ph < 6.5) return 'Acidic';
    if (ph < 7.5) return 'Neutral';
    if (ph < 8.5) return 'Alkaline';
    return 'Strongly Alkaline';
  }

  String get colorHex {
    if (ph < 5.5) return '#D32F2F';
    if (ph < 6.5) return '#F57C00';
    if (ph < 7.5) return '#2E7D32';
    if (ph < 8.5) return '#1565C0';
    return '#6A1B9A';
  }
}