import 'dart:ui';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final role = ModalRoute.of(context)?.settings.arguments;
    final roleText =
        (role is String && role.trim().isNotEmpty) ? role : "Farmer";

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

          // ✅ Top logo (outside glass)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  'assets/images/logo_agrivora.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ✅ Big Wavy Glass Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _HomeWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.78,
                  padding: EdgeInsets.fromLTRB(18, 95, 18, bottomPad + 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8D5).withOpacity(0.70),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title + subtitle
                              const Text(
                                "Home",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B1B1B),
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Here's your smart farming dashboard • Role: $roleText",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ✅ Weather/Search + Robot
                              SizedBox(
                                height: 230,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _GlassCard(
                                        width: size.width * 0.66,
                                        height: 195,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              14, 14, 14, 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(Icons.cloud,
                                                      color: Color(0xFF004D40)),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Colombo",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      color: Color(0xFF1B1B1B),
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: const [
                                                  _Metric(
                                                      label: "Temperature",
                                                      value: "27°C"),
                                                  _Metric(
                                                      label: "Rainfall",
                                                      value: "75%"),
                                                ],
                                              ),
                                              const Spacer(),

                                              // Search bar
                                              Container(
                                                height: 46,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEAF3EA)
                                                      .withOpacity(0.75),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                      color: Colors.black12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Expanded(
                                                      child: Text(
                                                        "Search",
                                                        style: TextStyle(
                                                          color: Colors.black45,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 38,
                                                      width: 54,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF2E7D32),
                                                        borderRadius:
                                                            BorderRadius.circular(16),
                                                      ),
                                                      child: const Icon(Icons.search,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ✅ Bigger robot
                                    Positioned(
                                      right: -4,
                                      bottom: -6,
                                      child: Image.asset(
                                        'assets/images/robot.png',
                                        height: 235,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text(
                                "Crop recommendation",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B1B1B),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // ✅ Soil analysis (existing)
                              _GlassCard(
                                width: double.infinity,
                                height: 84,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Soil Analysis",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1B1B1B),
                                              ),
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              "pH : 6.8 | N : Good",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ✅ "+" opens Soil Analysis page
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/soil-analysis');
                                        },
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          height: 52,
                                          width: 52,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2E7D32),
                                            shape: BoxShape.circle,
                                          ),
                                          child:
                                              const Icon(Icons.add, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ✅ NEW: Manual Soil Analysis (added under Soil Analysis)
                              const SizedBox(height: 12),
                              _GlassCard(
                                width: double.infinity,
                                height: 84,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Manual Soil Analysis",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1B1B1B),
                                              ),
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              "Enter soil type & pH manually",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ✅ "+" opens Manual Soil Analysis page
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/manual-soil');
                                        },
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          height: 52,
                                          width: 52,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2E7D32),
                                            shape: BoxShape.circle,
                                          ),
                                          child:
                                              const Icon(Icons.add, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Recommended Crops",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1B1B1B),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/crop-recom');
                                    },
                                    child: const Text(
                                      "See All",
                                      style: TextStyle(
                                        color: Color(0xFF004D40),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: const [
                                  Expanded(
                                    child: _CropCard(
                                      title: "Tea Plant",
                                      subtitle: "Ideal for current soil conditions",
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _CropCard(
                                      title: "Paddy (Rice)",
                                      subtitle: "High yield potential this season",
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),

                      // ✅ Bottom nav
                      _BottomNav(
                        index: _navIndex,
                        onTap: (i) => setState(() => _navIndex = i),
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

/// ✅ Wavy clipper
class _HomeWaveClipper extends CustomClipper<Path> {
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

class _GlassCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _GlassCard({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EA).withOpacity(0.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
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

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B1B1B),
          ),
        ),
      ],
    );
  }
}

class _CropCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CropCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EA).withOpacity(0.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEEDD).withOpacity(0.80),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.eco,
                    color: Color(0xFF2E7D32), size: 30),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF004D40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, int i, {String? route}) {
      final selected = index == i;
      return InkWell(
        onTap: () {
          onTap(i);
          if (route != null && route.isNotEmpty) {
            Navigator.pushNamed(context, route);
          }
        },
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
              item(Icons.map_outlined, "Map", 1, route: '/map'),
              item(Icons.smart_toy_outlined, "AI Chat", 2, route: '/ai-chat'),
              item(Icons.person_outline, "Profile", 3, route: '/profile'),
            ],
          ),
        ),
      ),
    );
  }
}