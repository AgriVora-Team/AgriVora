import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _locationService.getLocation();
    setState(() => _currentLocation = locationData);

    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌿 Background Image
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🏷️ Header (Logo Removed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Row(
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Field Map", 
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF424242))),
                          Text("View your farm location here!", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ],
                  ),
                ),

                // ☁️ Glassmorphic Weather Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.cloud_queue, color: Colors.blue[300], size: 30),
                          const Text("Colombo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      _buildStat("Temperature", "27°C"),
                      _buildStat("Rainfall", "75%"),
                      _buildStat("Humidity", "82%"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🗺️ Map Display
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withOpacity(0.9), width: 8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: _currentLocation == null
                          ? const Center(child: CircularProgressIndicator(color: Colors.green))
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                                zoom: 15,
                              ),
                              onMapCreated: (controller) => _mapController = controller,
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              mapType: MapType.normal,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // 🧭 Floating Navigation Bar
          _buildFloatingBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
      ],
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.home_filled, "Home", false, '/home'),
            _navItem(context, Icons.alt_route_rounded, "Map", true, '/map'),
            _navItem(context, Icons.memory_rounded, "AI Chat", false, '/ai-chat'),
            _navItem(context, Icons.person_pin_rounded, "Profile", false, '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, String route) {
    return GestureDetector(
      onTap: () { if (!active) Navigator.pushReplacementNamed(context, route); },
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