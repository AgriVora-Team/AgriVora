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
  late ScanSession _session;

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _session = widget.session;

    if (_session.imagePath != null && _session.imagePath!.isNotEmpty) {
      _imageFile = File(_session.imagePath!);
    }
  }

  Future<void> _selectImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    final file = File(pickedImage.path);

    setState(() {
      _imageFile = file;
      _session = _session.copyWith(imagePath: pickedImage.path);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Soil image added successfully'),
      ),
    );
  }

  void _proceedToAnalyze() {
    if (_session.imagePath == null || _session.imagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a soil image to continue'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceeding to analysis step'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _imageFile != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 4 – Soil Image'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Soil Image',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select a soil image from your gallery. The image will be used to analyze soil texture using the AI model.',
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
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No soil image selected.\n\nTap below to choose an image.',
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
                onPressed: _selectImage,
                child: const Text(
                  'Choose Image From Gallery',
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
                onPressed: _proceedToAnalyze,
                child: const Text(
                  'Continue to Analyze',
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