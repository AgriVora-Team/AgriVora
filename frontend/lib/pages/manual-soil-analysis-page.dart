import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/agri_bottom_nav_bar.dart';

class ManualSoilAnalysisPage extends StatefulWidget {
  const ManualSoilAnalysisPage({super.key});

  @override
  State<ManualSoilAnalysisPage> createState() => _ManualSoilAnalysisPageState();
}

class _ManualSoilAnalysisPageState extends State<ManualSoilAnalysisPage> {
  int _navIndex = 0;
  bool _isLoading = false;
  String _cityName = "Locating...";
  String _temperature = "--°C";
  String _rainfall = "--mm";
  String _humidity = "--%";
  double _rawTemp = 27.0;
  double _rawRain = 75.0;
  double _rawHumid = 82.0;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final summary = await ApiService.getLocationSummary(pos.latitude, pos.longitude);
      final weather = summary['weatherSummary'];

      if (mounted) {
        setState(() {
          _cityName = "My Fields";
          _rawTemp = (weather['temperature'] ?? 27.0).toDouble();
          _rawRain = (weather['rainfall'] ?? 75.0).toDouble();
          _rawHumid = (weather['humidity'] ?? 82.0).toDouble();
          _temperature = "${_rawTemp}°C";
          _rainfall = "${_rawRain}mm";
          _humidity = "${_rawHumid}%";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cityName = "Location Error";
        });
      }
    }
  }

  String? _selectedSoilType;
  final TextEditingController _phController = TextEditingController();

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

  Future<void> _analyzeSoil() async {
    final phText = _phController.text.trim();
    if (_selectedSoilType == null || phText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select soil type and enter pH')),
      );
      return;
    }

    final ph = double.tryParse(phText);
    if (ph == null || ph < 0 || ph > 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid pH (0-14)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getRecommendations(
        soilType: _selectedSoilType!,
        ph: ph,
        temperature: _rawTemp,
        rainfall: _rawRain,
        humidity: _rawHumid,
      );

      if (mounted) {
        final crops = response['data']['crops'] as List;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recommendation successful! Found ${crops.length} crops.')),
        );
        // For now just navigate to the page (it will show hardcoded data for now)
        Navigator.pushNamed(context, '/crop_recom');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

          // 🌊 Wavy Glass (behind content)
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _ManualWaveClipper(),
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

          // ✅ Corner logo (like your style)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 18, top: 14),
                child: Image.asset(
                  'assets/images/logo_agrivora.png',
                  height: 54,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),

                // Title + subtitle + divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      Text(
                        "Manual Soil Analysis",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Take a clear, well lit photo of your personalized\nor crop recommendation.",
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

                const SizedBox(height: 16),

                // Weather Card (top)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3EA).withOpacity(0.65),
                          borderRadius: BorderRadius.circular(28),
                        ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Row(
                               children: [
                                 const Icon(Icons.cloud, color: Color(0xFF2E7D32), size: 28),
                                 const SizedBox(width: 8),
                                 Text(
                                   _cityName,
                                   style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                                 ),
                               ],
                             ),
                             Column(
                               children: [
                                 const Text("Temperature",
                                     style: TextStyle(fontSize: 12, color: Colors.black54)),
                                 const SizedBox(height: 4),
                                 Text(_temperature,
                                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                               ],
                             ),
                             Column(
                               children: [
                                 const Text("Rainfall",
                                     style: TextStyle(fontSize: 12, color: Colors.black54)),
                                 const SizedBox(height: 4),
                                 Text(_rainfall,
                                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                               ],
                             ),
                             Column(
                               children: [
                                 const Text("Humidity",
                                     style: TextStyle(fontSize: 12, color: Colors.black54)),
                                 const SizedBox(height: 4),
                                 Text(_humidity,
                                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                               ],
                             ),
                           ],
                         ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Center Camera circle
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

                const SizedBox(height: 16),

                // Scrollable middle so no overflow
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Enter your soil data here"
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            "Enter your soil data here",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withOpacity(0.65),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Form glass card
                        _GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Soil Type",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B1B1B),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _InputPill(
                                  leading: const Icon(Icons.spa_rounded,
                                      color: Color(0xFF2E7D32)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedSoilType,
                                      hint: const Text("Select soil type"),
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF2E7D32)),
                                      items: const [
                                        DropdownMenuItem(value: "Sandy", child: Text("Sandy")),
                                        DropdownMenuItem(value: "Loamy", child: Text("Loamy")),
                                        DropdownMenuItem(value: "Clay", child: Text("Clay")),
                                        DropdownMenuItem(value: "Silt", child: Text("Silt")),
                                      ],
                                      onChanged: (v) => setState(() => _selectedSoilType = v),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  "Soil pH",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B1B1B),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _InputPill(
                                  leading: const Icon(Icons.science_rounded,
                                      color: Color(0xFF2E7D32)),
                                  child: TextField(
                                    controller: _phController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      hintText: "e.g 6.5",
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Analyze Soil button (big green)
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _analyzeSoil,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              elevation: 10,
                              shadowColor: const Color(0xFF2E7D32).withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Analyze Soil",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ✅ Bottom nav (Now outside Column for consistent alignment)
          const AgriBottomNavBar(activeIndex: 0),
        ],
      ),
    );
  }
}

/// 🌊 Wave clipper (same style)
class _ManualWaveClipper extends CustomClipper<Path> {
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

/// Glass form card
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

/// Input pill (white-ish) inside glass card
class _InputPill extends StatelessWidget {
  final Widget leading;
  final Widget child;

  const _InputPill({required this.leading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}
