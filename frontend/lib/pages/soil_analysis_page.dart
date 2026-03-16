import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

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

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzingImage = false;
  Map<String, dynamic>? _imageResult;

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _imageResult = null;
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access camera or gallery')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() => _isAnalyzingImage = true);

    try {
      final result = await ApiService.analyzeSoilImage(_image!);
      if (!mounted) return;

      setState(() {
        _isAnalyzingImage = false;
        _imageResult = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isAnalyzingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildModeToggle(),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildActiveModeCard(),
                        if (_activeMode == AnalysisMode.image &&
                            _imageResult != null) ...[
                          const SizedBox(height: 16),
                          _buildImageResultCard(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAnalyzingImage)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2E7D32)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Text('Tap to upload soil image'),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _image == null || _isAnalyzingImage ? null : _analyzeImage,
                child: const Text('Identify Soil Type'),
              ),
            ),
          ],
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Sensor mode will display live pH data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildImageResultCard() {
    final result = _imageResult!;
    final soilType =
        (result['soil_type'] ?? result['texture'] ?? 'Unknown').toString();
    final confidence = result['confidence'] != null
        ? (result['confidence'] as num).toDouble()
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Detected Soil Type: $soilType',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Confidence: ${(confidence * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}