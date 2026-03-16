import 'package:flutter/material.dart';

class SoilAnalysisPage extends StatefulWidget {
  const SoilAnalysisPage({super.key});

  @override
  State<SoilAnalysisPage> createState() => _SoilAnalysisPageState();
}

enum AnalysisMode { image, manual, sensor }

class _SoilAnalysisPageState extends State<SoilAnalysisPage> {
  AnalysisMode _activeMode = AnalysisMode.image;

  final TextEditingController _phController = TextEditingController();
  String _selectedSoilColor = 'Brown';
  String _selectedSoilTexture = 'Loamy';
  bool _isManualValid = false;

  @override
  void initState() {
    super.initState();
    _phController.addListener(_validateManualInput);
  }

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

  void _validateManualInput() {
    final text = _phController.text.trim();
    final ph = double.tryParse(text);
    final isValid = ph != null && ph >= 0 && ph <= 14;

    if (_isManualValid != isValid) {
      setState(() => _isManualValid = isValid);
    }
  }

  void _analyzeManual() {
    final ph = double.tryParse(_phController.text.trim());
    if (ph == null) return;

    Navigator.pushNamed(
      context,
      '/crop-recom',
      arguments: {
        'ph': ph,
        'soilType': _selectedSoilTexture,
      },
    );
  }

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedSoilColor,
              decoration: const InputDecoration(labelText: 'Soil Color'),
              items: ['Brown', 'Black', 'Red', 'Yellow']
                  .map((color) =>
                      DropdownMenuItem(value: color, child: Text(color)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSoilColor = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSoilTexture,
              decoration: const InputDecoration(labelText: 'Soil Texture'),
              items: ['Loamy', 'Clay', 'Sandy', 'Silt']
                  .map((texture) =>
                      DropdownMenuItem(value: texture, child: Text(texture)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSoilTexture = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'pH Value (0.0 - 14.0)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isManualValid ? _analyzeManual : null,
                child: const Text('Recommend Crops'),
              ),
            ),
          ],
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