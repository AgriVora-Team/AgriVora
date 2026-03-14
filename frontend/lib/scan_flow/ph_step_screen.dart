import 'package:flutter/material.dart';

import '../main.dart';
import 'image_step_screen.dart';

class PhStepScreen extends StatefulWidget {
  final ScanSession session;

  const PhStepScreen({super.key, required this.session});

  @override
  State<PhStepScreen> createState() => _PhStepScreenState();
}

class _PhStepScreenState extends State<PhStepScreen> {
  late ScanSession _currentSession;
  final TextEditingController _phController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    if (_currentSession.ph != null) {
      _phController.text = _currentSession.ph!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    final input = _phController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a pH value before continuing')),
      );
      return;
    }

    final phValue = double.tryParse(input);
    if (phValue == null || phValue < 0 || phValue > 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('pH must be a number between 0 and 14')),
      );
      return;
    }

    _currentSession = _currentSession.copyWith(ph: phValue);
    print('Updated pH: ${_currentSession.toJson()}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageStepScreen(session: _currentSession),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 3 – pH'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Soil pH Input',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Provide the soil pH manually or from a test strip. This will help in recommending suitable crops.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Soil pH',
                hintText: 'e.g. 6.5',
                border: OutlineInputBorder(),
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
                onPressed: _saveAndNext,
                child: const Text(
                  'Next: Image Step',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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