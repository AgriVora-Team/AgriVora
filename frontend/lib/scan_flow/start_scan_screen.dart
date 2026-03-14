import 'package:flutter/material.dart';

import '../main.dart';
import 'gps_step_screen.dart';

class StartScanScreen extends StatelessWidget {
  const StartScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Scan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, screenPadding.bottom + 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'AgriVora Soil Scan',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'This flow collects your GPS location, soil pH value and soil image before sending data to the backend for crop recommendations.',
              style: TextStyle(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Steps:\n'
                '1. Get GPS location\n'
                '2. Enter or read pH\n'
                '3. Capture or upload soil image\n'
                '4. Analyze and view ranked crops & tips',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  final scanSession = ScanSession.empty(
                    DateTime.now().millisecondsSinceEpoch.toString(),
                  );

                  debugPrint('New scan started: ${scanSession.toJson()}');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GpsStepScreen(session: scanSession),
                    ),
                  );
                },
                child: const Text(
                  'Start Scan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}