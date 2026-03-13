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
  final TextEditingController _phController = TextEditingController();
  bool _isValid = false;
  Map<String, dynamic>? _predictionResult;
  double _fetchedTemp = 27.0;
  double _fetchedRain = 100.0;
  double _moisture = 75.0;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    _phController.addListener(_validateInputs);
  }

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
      debugPrint("Weather fetch failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Unable to fetch weather data. Default values applied."),
          ),
        );
      }
    }
  }

  void _validateInputs() {
    final phValue = double.tryParse(_phController.text.trim());
    bool isPhValid = false;
    if (phValue != null) {
      isPhValid = phValue >= 0 && phValue <= 14;
    }
    if (_isValid != isPhValid) {
      setState(() {
        _isValid = isPhValid;
      });
    }
  }

  bool _isPhOutOfRange() {
    final phNum = double.tryParse(_phController.text.trim());
    return phNum != null && (phNum < 0 || phNum > 14);
  }

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

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
      debugPrint("Prediction error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ),
          ),
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fields.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 55,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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

  Widget _buildInputFormCard() {
    return _GlassCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter Soil Parameters",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          TextField(
            controller: _phController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "pH Value",
              helperText: _isPhOutOfRange()
                  ? "Warning: pH must be between 0 and 14"
                  : "Required range: 0 - 14",
              prefixIcon: const Icon(Icons.science_outlined),
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
              child: const Text(
                "Analyze Soil & Recommend Crops",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return _GlassCardContainer(
      child: Column(
        children: const [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 20),
          Text(
            "Processing soil data...\nRunning AI crop prediction model.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return const SizedBox();
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