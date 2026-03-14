import 'package:flutter/material.dart';

import '../main.dart';
import 'ph_step_screen.dart';

class GpsStepScreen extends StatefulWidget {
  final ScanSession session;

  const GpsStepScreen({
    super.key,
    required this.session,
  });

  @override
  State<GpsStepScreen> createState() => _GpsStepScreenState();
}

class _GpsStepScreenState extends State<GpsStepScreen> {
  late ScanSession _session;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _session = _session.copyWith(
        latitude: 6.9271,
        longitude: 79.8612,
      );
      _loading = false;
    });

    print('GPS updated: ${_session.toJson()}');
  }

  void _continue() {
    if (_session.latitude == null || _session.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fetch GPS location before continuing.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhStepScreen(session: _session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = _session.latitude;
    final lon = _session.longitude;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2 – GPS'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Get GPS Location',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your location will be used to fetch soil and weather information for crop analysis.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current coordinates',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lat == null || lon == null
                        ? 'Not fetched yet'
                        : 'Latitude: ${lat.toStringAsFixed(4)}, Longitude: ${lon.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _loading ? null : _getLocation,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Fetch GPS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _continue,
                child: const Text(
                  'Next – pH step',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}