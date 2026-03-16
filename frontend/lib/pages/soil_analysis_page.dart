import 'package:flutter/material.dart';

class SoilAnalysisPage extends StatefulWidget {
  const SoilAnalysisPage({super.key});

  @override
  State<SoilAnalysisPage> createState() => _SoilAnalysisPageState();
}

enum AnalysisMode { image, manual, sensor }

class _SoilAnalysisPageState extends State<SoilAnalysisPage> {
  AnalysisMode _activeMode = AnalysisMode.image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      appBar: AppBar(
        title: const Text('Soil Analysis'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildModeToggle(),
            const SizedBox(height: 20),
            Expanded(child: _buildActiveModeCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _activeMode = AnalysisMode.image),
            child: const Text('Image'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _activeMode = AnalysisMode.manual),
            child: const Text('Manual'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _activeMode = AnalysisMode.sensor),
            child: const Text('Sensor'),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveModeCard() {
    switch (_activeMode) {
      case AnalysisMode.image:
        return _buildImageCard();
      case AnalysisMode.manual:
        return _buildManualCard();
      case AnalysisMode.sensor:
        return _buildSensorCard();
    }
  }

  Widget _buildImageCard() {
    return const Card(
      child: Center(
        child: Text(
          'Image analysis mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildManualCard() {
    return const Card(
      child: Center(
        child: Text(
          'Manual soil data input mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSensorCard() {
    return const Card(
      child: Center(
        child: Text(
          'Sensor reading mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}