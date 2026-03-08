import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  bool _isLoaded = false;

  String? _selectedRole;
  bool _agreeTerms = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  // ✅ Continue -> Home page
  void _continue() {
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: _selectedRole, // optional
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final args = ModalRoute.of(context)?.settings.arguments;
    final userName = (args is String && args.trim().isNotEmpty) ? args : "Steve";

    final canContinue = _selectedRole != null && _agreeTerms;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fields.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Image.asset(
                  'assets/images/logo_agrivora.png',
                  height: 170,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutQuart,
            left: 0,
            right: 0,
            bottom: _isLoaded ? 0 : -size.height,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 650),
              opacity: _isLoaded ? 1 : 0,
              child: ClipPath(
                clipper: _TopWaveClipper(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: size.height * 0.78,
                      minHeight: size.height * 0.60,
                    ),
                    padding: EdgeInsets.fromLTRB(24, 70, 24, bottomPad + 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E8D5).withOpacity(0.72),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B1B1B),
                              ),
                              children: [
                                TextSpan(text: "Hi $userName, "),
                                const TextSpan(
                                  text: "Welcome!",
                                  style: TextStyle(color: Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "We will help you to choose the best crops\nbased on the soil data and weather.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            "Select the role of yours!!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _RoleTile(
                            title: "Farmer",
                            selected: _selectedRole == "Farmer",
                            onTap: () => setState(() => _selectedRole = "Farmer"),
                          ),

                          const SizedBox(height: 14),

                          _RoleTile(
                            title: "Home Gardener",
                            selected: _selectedRole == "Home Gardener",
                            onTap: () =>
                                setState(() => _selectedRole = "Home Gardener"),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreeTerms,
                                onChanged: (v) =>
                                    setState(() => _agreeTerms = v ?? false),
                                activeColor: const Color(0xFF004D40),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text:
                                                "By continuing, you agree to our "),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: const TextStyle(
                                            color: Color(0xFF004D40),
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Terms & Conditions clicked"),
                                                ),
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: canContinue ? _continue : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004D40),
                                disabledBackgroundColor:
                                    const Color(0xFF004D40).withOpacity(0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34),
                                ),
                                elevation: 10,
                                shadowColor:
                                    const Color(0xFF004D40).withOpacity(0.35),
                              ),
                              child: const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
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

class _RoleTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3EA).withOpacity(0.55),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDDEEDD).withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank,
                color: const Color(0xFF004D40),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 70);
    path.quadraticBezierTo(size.width * 0.25, 25, size.width * 0.55, 65);
    path.quadraticBezierTo(size.width * 0.82, 100, size.width, 55);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
