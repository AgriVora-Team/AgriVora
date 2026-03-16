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
      if (mounted) {
        setState(() => _livePh = ph);
      }
    }));

    _subs.add(BleService().rawStream.listen((reading) {
      if (mounted) {
        setState(() => _lastReading = reading);
      }
    }));

    _subs.add(BleService().statusStream.listen((status) {
      if (mounted) {
        setState(() => _bleStatus = status);
      }
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Live pH Reading',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            if (_livePh != null)
              Text(
                _livePh!.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32),
                ),
              )
            else
              const CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            const SizedBox(height: 12),
            Text(
              _bleStatus.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (_lastReading != null) ...[
              const SizedBox(height: 12),
              Text(
                'Latest reading: ${_lastReading.toString()}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
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
            const SizedBox(height: 20),
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