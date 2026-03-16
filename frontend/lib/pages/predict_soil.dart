import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ble_service.dart';

class PredictSoilPage extends StatefulWidget {
  const PredictSoilPage({super.key});

  @override
  State<PredictSoilPage> createState() => _PredictSoilPageState();
}

class _PredictSoilPageState extends State<PredictSoilPage> {
  double? _livePh;
  PhReading? _lastReading;
  BleStatus _bleStatus = const BleStatus(
    message: 'Initializing BLE…',
    state: BleConnectionState.scanning,
  );

  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();

    BleService().startScanAndConnect();

    _subs.add(BleService().phStream.listen((ph) {
      if (mounted) setState(() => _livePh = ph);
    }));

    _subs.add(BleService().rawStream.listen((reading) {
      if (mounted) setState(() => _lastReading = reading);
    }));

    _subs.add(BleService().statusStream.listen((status) {
      if (mounted) setState(() => _bleStatus = status);
    }));
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    BleService().disconnect();
    super.dispose();
  }

  Widget _buildPhCard() {
    final st = _bleStatus.state;
    final isConn = st == BleConnectionState.connected;
    final isStab = st == BleConnectionState.stabilizing;
    final isSim = st == BleConnectionState.simulating;

    Color phColor = const Color(0xFF2E7D32);
    String category = 'Waiting';

    if (_livePh != null) {
      final ph = _livePh!;
      if (ph < 5.5) {
        phColor = const Color(0xFFD32F2F);
        category = 'Strongly Acidic';
      } else if (ph < 6.5) {
        phColor = const Color(0xFFF57C00);
        category = 'Acidic';
      } else if (ph < 7.5) {
        phColor = const Color(0xFF2E7D32);
        category = 'Neutral';
      } else if (ph < 8.5) {
        phColor = const Color(0xFF1565C0);
        category = 'Alkaline';
      } else {
        phColor = const Color(0xFF6A1B9A);
        category = 'Strongly Alkaline';
      }
    }

    String badgeLabel = 'Scanning…';
    Color badgeColor = Colors.grey;

    if (isConn) {
      badgeLabel = '● Live';
      badgeColor = const Color(0xFF2E7D32);
    } else if (isStab) {
      badgeLabel = '⏳ Stabilizing';
      badgeColor = const Color(0xFFF57C00);
    } else if (isSim) {
      badgeLabel = '🔵 Simulated';
      badgeColor = const Color(0xFF1565C0);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live pH Reading',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_livePh != null) ...[
              Text(
                _livePh!.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: phColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: phColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: phColor,
                  ),
                ),
              ),
            ] else
              const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              _bleStatus.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _reconnectSensor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reconnecting to ESP32 sensor...'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
    BleService().startScanAndConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      appBar: AppBar(
        title: const Text('Predict Soil'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Predict Soil',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get live pH reading using our BLE sensor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(child: _buildPhCard()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _reconnectSensor,
                icon: const Icon(Icons.bluetooth_connected),
                label: const Text('Reconnect ESP32 Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _livePh != null
                    ? () {
                        Navigator.pushNamed(
                          context,
                          '/crop-recom',
                          arguments: {'ph': _livePh},
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: const Text('Proceed to Recommendation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}