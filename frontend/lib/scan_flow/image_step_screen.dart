/// **ImageStepScreen**
/// Responsible for: Capturing or uploading soil image for CNN texture analysis.
/// API Dependency: /image/texture

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart'; // ScanSession

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

  // For picking image
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;

    // If session already had an imagePath, restore preview
    if (_currentSession.imagePath != null) {
      _selectedImage = File(_currentSession.imagePath!);
    }
  }

  Future<void> _pickImageFromGallery() async {
    // 1. Check permissions first (Photos/Gallery)
    final hasPerm = await PermissionService.handlePermission(
      context: context,
      permission: Permission.photos,
      title: "Gallery Access",
      message: "Please allow access to your gallery to upload soil images.",
    );

    if (!hasPerm) return;

    // 2. Pick the image
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    if (mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _currentSession = _currentSession.copyWith(imagePath: pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery photo selected successfully.')),
      );
    }
  }

  Future<void> _captureFromCamera() async {
    // 1. Check camera permission
    final hasPerm = await PermissionService.handlePermission(
      context: context,
      permission: Permission.camera,
      title: "Camera Access",
      message: "Please allow camera access to capture soil photos.",
    );

    if (!hasPerm) return;

    // 2. Capture the image
    final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);

    if (capturedFile == null) return;

    if (mounted) {
      setState(() {
        _selectedImage = File(capturedFile.path);
        _currentSession = _currentSession.copyWith(imagePath: capturedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera photo captured successfully.')),
      );
    }
  }

  void _goToAnalyze() {
    if (_currentSession.imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image before continuing.'),
        ),
      );
      return;
    }

    // TODO: navigate to Analyze/Results step with _currentSession
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ready for Analyze step – TODO.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _selectedImage != null;

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
              'AgriVora uses this soil image as input to the CNN texture classifier. '
              'For Dev1 we let the user pick an image from the gallery and store its path in ScanSession.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Preview card
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
                        'No soil image selected yet.\n\n'
                        'Tap the button below to choose a soil image from the gallery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
            ),

            const Spacer(),

            // Buttons row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _captureFromCamera,
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                      label: const Text(
                        'Camera',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF004D40), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library_rounded, color: Color(0xFF004D40)),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Next button
            SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _goToAnalyze,
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
