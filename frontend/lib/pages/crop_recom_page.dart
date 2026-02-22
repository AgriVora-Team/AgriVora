import 'dart:ui';
import 'package:flutter/material.dart';

class CropRecomPage extends StatelessWidget {
  const CropRecomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const Text("Based on your latest soil scan",
                    style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                _buildFilterRow(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildCropCard(context, "Tomato", "Solanum lycopersicum", 0.95, Colors.green, "assets/images/tomato.png", ["High Yield", "Drought Tolerant"]),
                      _buildCropCard(context, "Chilli", "Capsicum Annuum", 0.82, Colors.green, "assets/images/chilli.png", ["Pest Resistant"]),
                      _buildCropCard(context, "Okra", "Abelmoshus Esculentus", 0.75, Colors.orange, "assets/images/okra.png", ["Drought Tolerant"]),
                    ],
                  ),
                ),
                const SizedBox(height: 100), 
              ],
            ),
          ),
          _buildFloatingBottomNav(context, 0), // Index 0 is Home
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.green, size: 25),
          ),
          const Text("Recommendations", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF424242))),
          const SizedBox(width: 25), // Balanced spacing since logo is removed
        ],
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, String name, String scientific, double score, Color color, String img, List<String> tags) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/crop_overview', arguments: {'name': name, 'image': img, 'scientific': scientific});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withOpacity(0.85),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundImage: AssetImage(img)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                      Text(scientific, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.green, size: 30),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Suitability Score", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                Text("${(score * 100).toInt()}% Match", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(value: score, backgroundColor: Colors.black12, color: color, minHeight: 10, borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 12),
            Row(
              children: tags.map((t) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                child: Text(t, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() => const SizedBox(height: 10);

  // UPDATED NAVIGATION BAR
  Widget _buildFloatingBottomNav(BuildContext context, int activeIndex) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withOpacity(0.9),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.home_filled, "Home", activeIndex == 0, '/home'),
            _navItem(context, Icons.alt_route_rounded, "Map", false, '/map'),
            _navItem(context, Icons.memory_rounded, "AI Chat", false, '/ai-chat'),
            _navItem(context, Icons.person_pin_rounded, "Profile", activeIndex == 2, '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 35, color: active ? const Color(0xFF2E7D32) : Colors.green.withOpacity(0.6)),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? const Color(0xFF2E7D32) : Colors.green.withOpacity(0.6))),
        ],
      ),
    );
  }
}