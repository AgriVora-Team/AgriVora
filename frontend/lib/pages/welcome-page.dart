import 'dart:ui';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  bool _isLoaded = false;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoaded = true);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fields.png',
              fit: BoxFit.cover,
            ),
          ),

          // Logo
          Positioned(
            top: size.height * 0.04,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_agrivora.png',
                height: 220,
              ),
            ),
          ),

          // ✅ Bottom Glass Panel (same theme as Login)
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: PerfectSoilClipper(),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(0), // keep shape from clipper
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: double.infinity,
                    height: size.height * 0.64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E8D5).withOpacity(0.72),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(28, 180, 28, bottomPad + 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Smart Crop\nRecommendation\nfor Farmers',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Analyze your soil, read pH using a sensor, and get the best crops for your land.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        const Spacer(),

                        // Button pulse stays same
                        ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.03).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/permission');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004D40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                elevation: 8,
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/permission', arguments: {'isGuest': true});
                            },
                            child: const Text(
                              'Continue as Guest',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Farmer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.elasticOut,
            bottom: _isLoaded ? (size.height * 0.38) : -100,
            left: _isLoaded ? 5 : -size.width * 0.5,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 8 * _floatController.value),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/farmer.png',
                width: size.width * 0.48,
              ),
            ),
          ),

          // IoT
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.elasticOut,
            bottom: _isLoaded ? (size.height * 0.34) : -100,
            right: _isLoaded ? 0 : -size.width * 0.7,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -6 * _floatController.value),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/iot_esp_phone.png',
                width: size.width * 0.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PerfectSoilClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 100);
    path.quadraticBezierTo(size.width * 0.25, 20, size.width * 0.5, 85);
    path.quadraticBezierTo(size.width * 0.8, 160, size.width, 50);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
