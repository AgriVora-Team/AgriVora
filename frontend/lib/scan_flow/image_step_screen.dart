import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class ImageStepScreen extends StatefulWidget {
  final ScanSession session;

  const ImageStepScreen({
    super.key,
    required this.session,
  });

  @override
  State<ImageStepScreen> createState() => _ImageStepScreenState();
}

class _ImageStepScreenState extends State<ImageStepScreen> {
  late ScanSession _currentSession;

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;

    if (_currentSession.imagePath != null) {
      _selectedImage = File(_currentSession.imagePath!);
    }
  }

  Future<void> _pickImage() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) return;

    setState(() {
      _selectedImage = File(file.path);
      _currentSession = _currentSession.copyWith(
        imagePath: file.path,
      );
    });

    print('Image selected: ${_currentSession.toJson()}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Soil image selected successfully.'),
      ),
    );
  }

  void _continueToAnalyze() {
    if (_currentSession.imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image before continuing.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ready for Analyze step – TODO.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _selectedImage != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 4 – Image'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Capture / Upload Soil Image',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'AgriVora uses this soil image as input to the CNN texture classifier. For Dev1 we let the user pick an image from the gallery and store its path in ScanSession.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),

            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasImage ? const Color(0xFF2E7D32) : Colors.grey,
                  width: 1.2,
                ),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No soil image selected yet.\n\nTap the button below to choose a soil image from the gallery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
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
                onPressed: _pickImage,
                child: const Text(
                  'Select soil image from gallery',
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
                onPressed: _continueToAnalyze,
                child: const Text(
                  'Next – Analyze (TODO)',
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