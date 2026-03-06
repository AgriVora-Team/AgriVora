import 'dart:async';
import 'dart:convert';
import 'dart:ui' show ImageFilter, Path; // explicit Path import beats latlong2's
import 'package:flutter/material.dart';
import '../widgets/agri_bottom_nav_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/location_service.dart';
import '../services/api_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  Position? _currentLocation;
  String _cityName = "Locating...";
  String _temperature = "--°C";
  String _rainfall = "--mm";
  String _humidity = "--%";
  bool _mapReady = false;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    _startLocationTracking();
    await _getUserLocation();
  }

  void _startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() => _currentLocation = position);
        if (_mapReady) {
          try { _mapController.move(LatLng(position.latitude, position.longitude), 16); }
          catch (_) {}
        }
      }
    }, onError: (e) => debugPrint("Location stream error: $e"));
  }

  Future<void> _getUserLocation() async {
    // 1. Try last known for instant centering
    final lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null && mounted) {
      setState(() => _currentLocation = lastPos);
    }

    try {
      final pos = await LocationService.getCurrentLocation()
          .timeout(const Duration(seconds: 15));
      if (mounted) {
        setState(() => _currentLocation = pos);
        if (_mapReady) {
          try { _mapController.move(LatLng(pos.latitude, pos.longitude), 16); }
          catch (_) {}
        }
        await _fetchWeatherData(pos);
      }
    } catch (e) {
      debugPrint("Location fetch failed: $e");
      // Fallback to medium accuracy
      try {
        final fallbackPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 8));
        if (mounted) {
          setState(() => _currentLocation = fallbackPos);
          await _fetchWeatherData(fallbackPos);
        }
      } catch (_) {}
    }
  }

  Future<void> _fetchWeatherData([Position? pos]) async {
    final location = pos ?? _currentLocation;
    if (location == null) return;
    final lat = location.latitude;
    final lon = location.longitude;

    // ── Try backend first ──────────────────────────────────────────────────
    try {
      final summary = await ApiService.getLocationSummary(lat, lon)
          .timeout(const Duration(seconds: 8));
      final weather = summary['weatherSummary'];
      if (mounted && weather != null) {
        setState(() {
          _temperature = "${weather['temperature'] ?? '--'}°C";
          _rainfall   = "${weather['rainfall']    ?? '--'}mm";
          _humidity   = "${weather['humidity']    ?? '--'}%";
          _cityName   = summary['location'] ?? "My Fields";
        });
        return; // success — done
      }
    } catch (e) {
      debugPrint("Backend weather failed, falling back to direct APIs: $e");
    }

    // ── Fallback: call Open-Meteo + Nominatim directly ─────────────────────
    await _fetchWeatherDirect(lat, lon);
  }

  Future<void> _fetchWeatherDirect(double lat, double lon) async {
    // Open-Meteo (free, no key)
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current=temperature_2m,relative_humidity_2m,precipitation'
          '&timezone=auto');
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data    = jsonDecode(res.body);
        final current = data['current'] ?? {};
        if (mounted) {
          setState(() {
            _temperature = "${current['temperature_2m']       ?? '--'}°C";
            _rainfall   = "${current['precipitation']         ?? '--'}mm";
            _humidity   = "${current['relative_humidity_2m']  ?? '--'}%";
          });
        }
      }
    } catch (e) {
      debugPrint("Open-Meteo direct call failed: $e");
    }

    // Nominatim reverse geocoding (free, no key)
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=$lat&lon=$lon&zoom=10');
      final res = await http
          .get(url, headers: {'User-Agent': 'AgriVoraApp/1.0'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data    = jsonDecode(res.body);
        final address = data['address'] ?? {};
        final name    = address['city']   ??
                        address['town']   ??
                        address['village'] ??
                        address['county'] ?? 'My Fields';
        if (mounted) setState(() => _cityName = name);
      }
    } catch (e) {
      debugPrint("Nominatim direct call failed: $e");
      if (mounted) setState(() => _cityName = "My Fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size      = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: Stack(
        children: [
          // 🌾 Background
          Positioned.fill(
            child: Image.asset('assets/images/bg_fields.png', fit: BoxFit.cover),
          ),

          // Glass panel
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _MapWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.88,
                  padding: EdgeInsets.fromLTRB(18, 110, 18, bottomPad + 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8D5).withValues(alpha: 0.65),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Field Map",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B1B1B),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Color(0xFF2E7D32), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    _cityName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _getUserLocation,
                            icon: const Icon(Icons.my_location,
                                color: Color(0xFF2E7D32), size: 30),
                            tooltip: "Find My Location",
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ── Map ─────────────────────────────────────────────
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4), width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: _currentLocation == null
                                ? Container(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                              color: Color(0xFF2E7D32)),
                                          SizedBox(height: 12),
                                          Text("Getting your location…",
                                              style: TextStyle(
                                                  color: Color(0xFF2E7D32),
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  )
                                : FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                          _currentLocation!.latitude,
                                          _currentLocation!.longitude),
                                      initialZoom: 16,
                                      onMapReady: () {
                                        setState(() => _mapReady = true);
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.agrivora_ui_test',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(
                                                _currentLocation!.latitude,
                                                _currentLocation!.longitude),
                                            width: 60,
                                            height: 60,
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Color(0xFF2E7D32),
                                              size: 50,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ── Stats bar ────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(Icons.thermostat, _temperature, "Temp"),
                            _buildStat(Icons.water_drop, _rainfall, "Rain"),
                            _buildStat(Icons.air, _humidity, "Humid"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navigation Bar
          const AgriBottomNavBar(activeIndex: 1),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1B1B1B)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

/// Wave-shaped clipper for the glass panel
class _MapWaveClipper extends CustomClipper<Path> {
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
