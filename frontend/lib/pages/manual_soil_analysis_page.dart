// Manual Soil Analysis Page
// Initial implementation for AI-based crop recommendation using soil pH and weather data

import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/agri_bottom_nav_bar.dart';

class ManualSoilAnalysisPage extends StatefulWidget {
  const ManualSoilAnalysisPage({super.key});

  @override
  State<ManualSoilAnalysisPage> createState() => _ManualSoilAnalysisPageState();
}

class _ManualSoilAnalysisPageState extends State<ManualSoilAnalysisPage> {
  bool _isLoading = false;

  // Controller for pH input
  final TextEditingController _phController = TextEditingController();

  bool _isValid = false;
  Map<String, dynamic>? _predictionResult;

  // Weather values (fetched automatically)
  double _fetchedTemp = 27.0;
  double _fetchedRain = 100.0;
  double _moisture = 75.0;

  @override
  void initState() {
    super.initState();

    // Fetch location-based weather data
    _fetchWeatherData();

    // Listen for pH field changes to validate input
    _phController.addListener(_validateInputs);
  }

  // Fetch weather data using current GPS location
  Future<void> _fetchWeatherData() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final summary =
          await ApiService.getLocationSummary(pos.latitude, pos.longitude);

      final weather = summary['weatherSummary'] ?? {};

      if (mounted) {
        setState(() {
          _fetchedTemp = (weather['temperature'] ?? 27.0).toDouble();
          _fetchedRain = (weather['rainfall'] ?? 100.0).toDouble();
          _moisture = (weather['humidity'] ?? 75.0).toDouble();

          _validateInputs();
        });
      }
    } catch (e) {
      // If weather fetch fails we keep default values
    }
  }

  // Validate pH input value
  void _validateInputs() {
    final phNum = double.tryParse(_phController.text.trim());

    final bool isPhValid = phNum != null && phNum >= 0 && phNum <= 14;

    if (_isValid != isPhValid) {
      setState(() => _isValid = isPhValid);
    }
  }

  // Check if pH is outside the acceptable range
  bool _isPhOutOfRange() {
    final phNum = double.tryParse(_phController.text.trim());
    return phNum != null && (phNum < 0 || phNum > 14);
  }

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

  // Trigger AI analysis request
  Future<void> _analyzeSoil() async {
    if (!_isValid) return;

    setState(() {
      _isLoading = true;
      _predictionResult = null;
    });

    try {
      final ph = double.parse(_phController.text.trim());

      final res = await ApiService.predictCropLGBM(
        temperature: _fetchedTemp,
        humidity: _moisture,
        rainfall: _fetchedRain,
        ph: ph,
        nitrogen: 40.0,
        carbon: 1.2,
        soilType: 'Loamy',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _predictionResult = res;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fields.png',
              fit: BoxFit.cover,
            ),
          ),

          // Page header
          Positioned(
            top: MediaQuery.of(context).padding.top + 55,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Manual Analysis",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(0, 2))
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Enter Soil Parameters for AI",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 1))
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // Glass UI panel
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _ManualWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.88,
                  padding: EdgeInsets.fromLTRB(16, 160, 16, bottomPad + 70),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8D5).withOpacity(0.68),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        if (_predictionResult != null)
                          _buildResultCard()
                        else if (_isLoading)
                          _buildLoadingCard()
                        else
                          _buildInputFormCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input form card
  Widget _buildInputFormCard() {
    return _GlassCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter Soil Parameters",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1B1B))),
          const SizedBox(height: 16),

          TextField(
            controller: _phController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "pH Value",
              helperText: _isPhOutOfRange()
                  ? "Warning: pH should be between 0 and 14"
                  : "Required: Range 0-14",
              helperStyle: TextStyle(
                  color: _isPhOutOfRange() ? Colors.redAccent : Colors.black54),
              prefixIcon:
                  const Icon(Icons.science_outlined, color: Color(0xFF2E7D32)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid ? _analyzeSoil : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text("Analyze Soil & Recommend Crops",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return _GlassCardContainer(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: const [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 20),
            Text(
              "Processing Soil Data...\nAnalyzing ML model pathways.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return const SizedBox(); // shortened for version 1 example
  }
}

class _GlassCardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _GlassCardContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3EA).withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _ManualWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 115);
    path.quadraticBezierTo(size.width * 0.22, 35, size.width * 0.52, 98);
    path.quadraticBezierTo(size.width * 0.82, 160, size.width, 85);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}