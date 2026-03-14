import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/agri_bottom_nav_bar.dart';

class CropRecomPage extends StatefulWidget {
  const CropRecomPage({super.key});

  @override
  State<CropRecomPage> createState() => _CropRecomPageState();
}

class _CropRecomPageState extends State<CropRecomPage> {

  bool _isLoading = true;
  String? _errorMsg;
  Map<String, dynamic>? _prediction;
  Map<String, dynamic>? _args;
  bool _initialized = false;

  String _loadingState = "Fetching location and weather data...";

  double _numToDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return fallback;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      _args = args;
      _runPrediction(args ?? <String, dynamic>{});
      _initialized = true;
    }
  }

  Future<void> _runPrediction(Map<String, dynamic> data) async {

    try {

      setState(() => _loadingState = "Getting local weather...");

      double? temp;
      double? humid;
      double? rain;
      double? carbon;

      try {

        final pos = await LocationService.getCurrentLocation();

        final summary =
            await ApiService.getLocationSummary(pos.latitude, pos.longitude);

        final weather = summary['weatherSummary'] ?? {};
        final soil = summary['soilSummary'] ?? {};

        temp = _numToDouble(weather['temperature'], 27.0);
        humid = _numToDouble(weather['humidity'], 75.0);
        rain = _numToDouble(weather['rainfall'], 100.0);

        carbon = _numToDouble(
          soil['organicCarbon'] ?? soil['soc'],
          1.2,
        );

      } catch (e) {
        debugPrint("Location/Weather fetch failed -> $e");
      }

      setState(() => _loadingState = "Analyzing data with AI...");

      final res = await ApiService.predictCropLGBM(
        temperature: _numToDouble(data['temperature'], temp ?? 27.0),
        humidity: _numToDouble(data['humidity'], humid ?? 75.0),
        rainfall: _numToDouble(data['rainfall'], rain ?? 100.0),
        ph: _numToDouble(data['ph'], 6.5),
        nitrogen: _numToDouble(data['nitrogen'], 40.0),
        carbon: _numToDouble(data['carbon'], carbon ?? 1.2),
        soilType: data['soilType']?.toString() ?? 'loamy soil',
      );

      if (mounted) {

        setState(() {
          _prediction = res;
          _isLoading = false;
        });

        ApiService.saveToHistory({
          "crop": res['recommended_crop'] ?? res['crop'] ?? 'Unknown',
          "confidence": res['confidence'] ?? 0.85,
          "ph": _numToDouble(data['ph'], 6.5),
          "temperature": _numToDouble(data['temperature'], temp ?? 27.0),
          "humidity": _numToDouble(data['humidity'], humid ?? 75.0),
          "rainfall": _numToDouble(data['rainfall'], rain ?? 100.0),
          "soil_type": data['soilType']?.toString() ?? 'loamy soil',
          "type": "Crop Recommendation (LightGBM)"
        });

      }

    } catch (e) {

      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),

      body: SafeArea(
        child: _buildBody(),
      ),

      bottomNavigationBar: const AgriBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildBody() {

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF2E7D32)),
            const SizedBox(height: 16),
            Text(_loadingState,
                style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.redAccent,
                size: 50),

            const SizedBox(height: 16),

            const Text(
              "Prediction Failed",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(_errorMsg!,
                textAlign: TextAlign.center),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            )
          ],
        ),
      );
    }

    if (_prediction == null) {
      return const Center(
        child: Text("No recommendation available"),
      );
    }

    final cropName =
        _prediction!['recommended_crop'] ??
        _prediction!['crop'] ??
        "Unknown";

    final confidence =
        (_prediction!['confidence'] ?? 0.85) * 100;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "AI Crop Recommendation",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Text(
                    cropName,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32)),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "${confidence.toInt()}% Suitability",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 16),

                  LinearProgressIndicator(
                    value: confidence / 100,
                    minHeight: 10,
                    color: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "This crop is recommended based on soil, weather, and AI prediction results.",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}