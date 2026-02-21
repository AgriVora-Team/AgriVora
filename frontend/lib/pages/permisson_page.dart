import 'dart:ui';
import 'package:flutter/material.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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

          // 🌿 Logo (top)
          Positioned(
            top: size.height * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_agrivora.png',
                height: 120,
              ),
            ),
          ),

          // 🟫 Glass permission card (slide up)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutQuart,
            bottom: _isLoaded ? 0 : -size.height,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: SoilWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: size.height * 0.72,
                  width: double.infinity,
                  // ✅ frosted glass tint (matches login)
                  color: const Color(0xFFF2E8D5).withOpacity(0.78),
                  padding: EdgeInsets.fromLTRB(28, 86, 28, bottomPadding + 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Permissions\nRequired',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'To help you grow better, AgriVora needs access to your location and sensors.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ✅ tiles (animated like your old version)
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            PermissionTile(
                              icon: Icons.location_on_rounded,
                              title: 'Location Services',
                              subtitle: 'For local soil & weather data.',
                              delayMs: 120,
                              isLoaded: _isLoaded,
                            ),
                            const SizedBox(height: 16),
                            PermissionTile(
                              icon: Icons.camera_alt_rounded,
                              title: 'Camera Access',
                              subtitle: 'To scan soil texture and leaves.',
                              delayMs: 260,
                              isLoaded: _isLoaded,
                            ),
                            const SizedBox(height: 16),
                            PermissionTile(
                              icon: Icons.bluetooth_rounded,
                              title: 'Bluetooth & Wi-Fi',
                              subtitle: 'To sync with your ESP32 sensor.',
                              delayMs: 400,
                              isLoaded: _isLoaded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ✅ Allow All -> Login page
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                            elevation: 10,
                            shadowColor: const Color(
                              0xFF004D40,
                            ).withOpacity(0.35),
                          ),
                          child: const Text(
                            'Allow All',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Maybe Later',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌊 Same smooth wave top
class SoilWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 60);
    path.quadraticBezierTo(size.width * 0.25, 10, size.width * 0.55, 55);
    path.quadraticBezierTo(size.width * 0.85, 95, size.width, 45);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ✅ Permission item that matches login-field vibe
class PermissionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int delayMs;
  final bool isLoaded;

  const PermissionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delayMs,
    required this.isLoaded,
  });

  @override
  State<PermissionTile> createState() => _PermissionTileState();
}

class _PermissionTileState extends State<PermissionTile> {
  bool _show = false;

  @override
  void didUpdateWidget(covariant PermissionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoaded && !_show) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) setState(() => _show = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 520),
      opacity: _show ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        offset: _show ? Offset.zero : const Offset(0.08, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ✅ soft “field” tile look (not pure white)
            color: const Color(0xFFEAF3E6).withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ round icon bubble like your permission page style
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFF004D40),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
