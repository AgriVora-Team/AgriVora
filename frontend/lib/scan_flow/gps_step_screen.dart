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
  late ScanSession _currentSession;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final updatedSession = _currentSession.copyWith(
      latitude: 6.9271,
      longitude: 79.8612,
    );

    setState(() {
      _currentSession = updatedSession;
      _isLoading = false;
    });

    print('Location updated: ${_currentSession.toJson()}');
  }

  void _goToNextStep() {
    final lat = _currentSession.latitude;
    final lon = _currentSession.longitude;

    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fetch GPS location before proceeding'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhStepScreen(session: _currentSession),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = _currentSession.latitude;
    final lon = _currentSession.longitude;

    final coordinatesText = lat == null || lon == null
        ? 'Location not fetched'
        : 'Latitude: ${lat.toStringAsFixed(4)}, Longitude: ${lon.toStringAsFixed(4)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2 – GPS Location'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Retrieve GPS Location',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your location helps AgriVora gather local soil and weather data to improve crop recommendations.',
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
                    'Current Coordinates',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    coordinatesText,
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
                onPressed: _isLoading ? null : _fetchLocation,
                child: _isLoading
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
                        'Get GPS Location',
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
                onPressed: _goToNextStep,
                child: const Text(
                  'Continue to pH Step',
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