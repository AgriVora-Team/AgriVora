import 'package:flutter/material.dart';

class CropOverviewPage extends StatelessWidget {
  final String name;
  final String scientific;
  final String image;

  const CropOverviewPage({
    super.key,
    required this.name,
    required this.scientific,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌿 Background
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.green, size: 25),
                      ),
                      Text(
                        "$name Overview",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(width: 25),
                    ],
                  ),
                ),

                // Crop Image
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(scientific, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54)),
                const SizedBox(height: 25),

                // Overview Info
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9).withOpacity(0.85),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Planting Overview",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "The $name is perfect for your soil. Ensure sunlight, water, and care for the best yield.",
                            style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Key Requirements",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 15),
                          _requirementRow(Icons.wb_sunny_rounded, "Sunlight", "6-8 Hours"),
                          _requirementRow(Icons.water_drop_rounded, "Watering", "Moderate"),
                          _requirementRow(Icons.timer_rounded, "Harvest", "70-90 Days"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _requirementRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        ],
      ),
    );
  }
}


