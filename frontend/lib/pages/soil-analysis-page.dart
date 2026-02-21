import 'dart:ui';
import 'package:flutter/material.dart';

class SoilAnalysisPage extends StatefulWidget {
  const SoilAnalysisPage({super.key});

  @override
  State<SoilAnalysisPage> createState() => _SoilAnalysisPageState();
}

class _SoilAnalysisPageState extends State<SoilAnalysisPage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          // 🌾 Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fields.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌊 Wavy Glass (BEHIND content)
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _SoilWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8D5).withOpacity(0.74),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                ),
              ),
            ),
          ),

          // 🔙 Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 18, top: 12),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withOpacity(0.6),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Main layout
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title + subtitle + divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      Text(
                        "Soil Analysis",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Take a clear, well lit photo of your soil sample\nor upload from your gallery",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: 230,
                        child: Divider(
                          thickness: 2,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Scrollable content (so no overflow)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                    child: Column(
                      children: [
                        // Big circular camera icon
                        Center(
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF3EA).withOpacity(0.65),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 44,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Capture Soil button (green)
                        _PillButton(
                          text: "Capture Soil",
                          filled: true,
                          onTap: () {
                            // TODO: open camera
                          },
                        ),

                        const SizedBox(height: 12),

                        // Upload Soil Image button (light)
                        _PillButton(
                          text: "Upload Soil Image",
                          filled: false,
                          onTap: () {
                            // TODO: open gallery picker
                          },
                        ),

                        const SizedBox(height: 18),

                        // Reading unavailable card
                        _GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.wifi_tethering_off_rounded,
                                  color: Colors.black54,
                                  size: 28,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Reading Unavailable",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B1B1B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Please connect your pH sensor to get a\nlive reading",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.55),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Analyze Soil big button
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: navigate to results / texture / pH page
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              elevation: 10,
                              shadowColor: const Color(0xFF2E7D32).withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34),
                              ),
                            ),
                            child: const Text(
                              "Analyze Soil",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),

                // Bottom nav (same style)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 12),
                  child: _BottomNav(
                    index: _navIndex,
                    onTap: (i) => setState(() => _navIndex = i),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌊 Wave clipper (same family style as your other pages)
class _SoilWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 120);

    path.quadraticBezierTo(size.width * 0.25, 45, size.width * 0.55, 112);
    path.quadraticBezierTo(size.width * 0.86, 175, size.width, 100);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// --- Small UI helpers (kept same style) ---

class _PillButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _PillButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? const Color(0xFF2E7D32)
        : const Color(0xFFEAF3EA).withOpacity(0.70);
    final fg = filled ? Colors.white : const Color(0xFF1B1B1B);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 54,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(30),
                border: filled ? null : Border.all(color: Colors.black12),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        )
                      ]
                    : null,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EA).withOpacity(0.55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ✅ Bottom nav (same as your other pages)
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, int i) {
      final selected = index == i;
      return InkWell(
        onTap: () => onTap(i),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? const Color(0xFF004D40) : Colors.black45,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? const Color(0xFF004D40) : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EA).withOpacity(0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              item(Icons.home_rounded, "Home", 0),
              item(Icons.map_outlined, "Map", 1),
              item(Icons.smart_toy_outlined, "AI Chat", 2),
              item(Icons.person_outline, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }
}
