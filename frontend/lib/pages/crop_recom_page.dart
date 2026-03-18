/*
====================================================================
Agrivora AI Crop Recommendation Page (Enterprise Version)
====================================================================

Enhancements:
✔ Modular UI structure
✔ Pull-to-refresh support
✔ Retry mechanism
✔ Enhanced UI components
✔ Debug logging
✔ Clean architecture separation
✔ Expanded widgets for better UX

====================================================================
*/

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

  // ==============================
  // STATE VARIABLES
  // ==============================

  bool _isLoading = true;
  String? _errorMsg;
  Map<String, dynamic>? _prediction;
  bool _initialized = false;

  String _loadingState = "Initializing AI prediction...";



  // ==============================
  // SAFE CONVERSION
  // ==============================

  double _toDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return fallback;
  }



  // ==============================
  // INIT
  // ==============================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      _runPrediction(args ?? {});
      _initialized = true;
    }
  }



  // ==============================
  // MAIN LOGIC
  // ==============================

  Future<void> _runPrediction(Map<String, dynamic> data) async {

    setState(() {
      _isLoading = true;
      _loadingState = "Fetching environment data...";
    });

    try {

      double temp = 27.0;
      double humid = 75.0;
      double rain = 100.0;
      double carbon = 1.2;



      // ==========================
      // LOCATION + WEATHER
      // ==========================

      try {
        final pos = await LocationService.getCurrentLocation();

        final summary =
            await ApiService.getLocationSummary(pos.latitude, pos.longitude);

        final weather = summary['weatherSummary'] ?? {};
        final soil = summary['soilSummary'] ?? {};

        temp = _toDouble(weather['temperature'], temp);
        humid = _toDouble(weather['humidity'], humid);
        rain = _toDouble(weather['rainfall'], rain);

        carbon = _toDouble(soil['organicCarbon'] ?? soil['soc'], carbon);

      } catch (e) {
        debugPrint("Weather fetch failed: $e");
      }



      // ==========================
      // AI CALL
      // ==========================

      setState(() => _loadingState = "Running AI model...");

      final res = await ApiService.predictCropLGBM(
        temperature: _toDouble(data['temperature'], temp),
        humidity: _toDouble(data['humidity'], humid),
        rainfall: _toDouble(data['rainfall'], rain),
        ph: _toDouble(data['ph'], 6.5),
        nitrogen: _toDouble(data['nitrogen'], 40.0),
        carbon: _toDouble(data['carbon'], carbon),
        soilType: data['soilType']?.toString() ?? 'loamy soil',
      );



      // ==========================
      // SAVE RESULT
      // ==========================

      if (mounted) {
        setState(() {
          _prediction = res;
          _isLoading = false;
        });

        ApiService.saveToHistory({
          "crop": res['recommended_crop'] ?? res['crop'],
          "confidence": res['confidence'],
          "type": "AI Prediction"
        });
      }

    } catch (e) {

      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
    }
  }



  // ==============================
  // BUILD
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _runPrediction({}),
          child: _buildContent(),
        ),
      ),

      bottomNavigationBar: const AgriBottomNavBar(currentIndex: 1),
    );
  }



  // ==============================
  // CONTENT SWITCH
  // ==============================

  Widget _buildContent() {

    if (_isLoading) return _buildLoading();
    if (_errorMsg != null) return _buildError();
    if (_prediction == null) return _buildEmpty();

    return _buildSuccess();
  }



  // ==============================
  // STATES UI
  // ==============================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF2E7D32)),
          const SizedBox(height: 16),
          Text(_loadingState),
        ],
      ),
    );
  }



  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Icon(Icons.error, size: 50, color: Colors.red),

          const SizedBox(height: 16),

          Text(_errorMsg ?? "Unknown error"),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _runPrediction({}),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }



  Widget _buildEmpty() {
    return const Center(
      child: Text("No data available"),
    );
  }



  // ==============================
  // SUCCESS UI
  // ==============================

  Widget _buildSuccess() {

    final crop = _prediction!['recommended_crop'] ?? "Unknown";
    final confidence = (_prediction!['confidence'] ?? 0.85) * 100;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        const Text(
          "AI Recommendation",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        _buildMainCard(crop, confidence),

        const SizedBox(height: 20),

        _buildTipsSection(),

        const SizedBox(height: 20),

        _buildStatsSection(confidence),
      ],
    );
  }



  Widget _buildMainCard(String crop, double confidence) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(crop, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text("${confidence.toInt()}%"),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: confidence / 100),
          ],
        ),
      ),
    );
  }



  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Farming Tips", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("• Use balanced fertilizer"),
        Text("• Monitor irrigation"),
        Text("• Check soil regularly"),
      ],
    );
  }



  Widget _buildStatsSection(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Confidence Analysis"),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: confidence / 100),
      ],
    );
  }
}