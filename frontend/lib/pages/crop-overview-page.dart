import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/agri_bottom_nav_bar.dart';

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
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          _buildBackground(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 55,
            left: 24,
            right: 24,
            child: _buildHeader(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _OverviewWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.85,
                  padding: EdgeInsets.fromLTRB(16, 80, 16, bottomPad + 70),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8D5).withOpacity(0.75),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: _buildBody(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// BACKGROUND
  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/bg_fields.png',
        fit: BoxFit.cover,
      ),
    );
  }

  /// HEADER
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 2))
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "AI Recommended Based on Your Soil Data",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              _buildSuitabilityBadge(),
            ],
          ),
        ),
        _buildHeaderIcon(),
      ],
    );
  }

  Widget _buildSuitabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "85% Suitable",
        style: TextStyle(
            fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
      ),
      child: const Icon(Icons.spa_rounded, color: Colors.white, size: 32),
    );
  }

  /// BODY
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16),
          _buildSoilSection(),
          const SizedBox(height: 16),
          _buildClimateSection(),
          const SizedBox(height: 16),
          _buildAdviceSection(),
          const SizedBox(height: 24),
          _buildActions(context),
        ],
      ),
    );
  }

  /// OVERVIEW
  Widget _buildOverviewCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.info_outline, "Crop Overview"),
          const SizedBox(height: 12),
          Text(
            "$name ($scientific) can perform well under current soil conditions. "
            "Balanced nutrients and irrigation will maximize yield.",
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// SOIL
  Widget _buildSoilSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.landscape, "Soil Compatibility"),
          const SizedBox(height: 12),
          _progress("pH Compatibility", 0.8),
          const SizedBox(height: 10),
          _progress("Nitrogen Match", 0.65),
        ],
      ),
    );
  }

  /// CLIMATE
  Widget _buildClimateSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.cloud, "Climate Suitability"),
          const SizedBox(height: 10),
          const Text(
            "Weather conditions appear favorable for germination and crop growth.",
          ),
        ],
      ),
    );
  }

  /// FARMING TIPS
  Widget _buildAdviceSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.lightbulb_outline, "Farming Advice"),
          const SizedBox(height: 10),
          _tip("Fertilizer", "Use balanced NPK fertilizer"),
          _tip("Irrigation", "Drip irrigation improves water efficiency"),
          _tip("Pest Monitoring", "Inspect leaves weekly"),
        ],
      ),
    );
  }

  /// ACTIONS
  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Saved to History")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
          ),
          child: const Text("Save Crop"),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/ai_chat');
          },
          child: const Text("Ask AI"),
        ),
      ],
    );
  }

  /// SMALL HELPERS

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1B1B)),
        ),
      ],
    );
  }

  Widget _progress(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          color: const Color(0xFF2E7D32),
          backgroundColor: Colors.black12,
        ),
      ],
    );
  }

  Widget _tip(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text("$title • $desc")),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _OverviewWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 115);
    path.quadraticBezierTo(size.width * 0.22, 35, size.width * 0.52, 98);
    path.quadraticBezierTo(size.width * 0.82, 160, size.width, 85);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}