import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌿 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png', 
              fit: BoxFit.cover,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 🏷️ Header Section (Logo Removed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("AgriVora", 
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF424242))),
                          Text("My Profile", 
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ],
                  ),
                ),

                // 👤 Profile Picture Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.person, size: 60, color: Colors.white),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.green, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("Edit your profile picture", 
                        style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 📝 User Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.person_outline, "Full Name", "Steve John"),
                      const Divider(color: Colors.green, thickness: 1),
                      _buildInfoRow(Icons.email_outlined, "Email Address", "agrivora@gmail.com"),
                      const Divider(color: Colors.green, thickness: 1),
                      _buildInfoRow(Icons.phone_outlined, "Phone Number", "0771234567"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ⚙️ Settings List Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(Icons.person_outline, "Account Settings"),
                      _buildSettingsTile(Icons.videocam_outlined, "AgriVora Tutorial"),
                      _buildSettingsTile(Icons.help_outline, "Help & Support"),
                      _buildSettingsTile(Icons.description_outlined, "Terms & Conditions"),
                    ],
                  ),
                ),
                // No "Developed by" text here anymore
                const Spacer(), 
              ],
            ),
          ),
          
          // 🧭 The Floating Navigation Bar
          _buildFloatingBottomNav(context, 3), 
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, color: Colors.green, size: 22),
              const SizedBox(width: 15),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.green),
      onTap: () {},
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context, int activeIndex) {
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
            _navItem(context, Icons.home_filled, "Home", activeIndex == 0, '/home'),
            _navItem(context, Icons.alt_route_rounded, "Map", false, '/map'),
            _navItem(context, Icons.memory_rounded, "AI Chat", false, '/ai-chat'),
            _navItem(context, Icons.person_pin_rounded, "Profile", activeIndex == 3, '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, String route) {
    return GestureDetector(
      onTap: () {
        if (!active) Navigator.pushReplacementNamed(context, route);
      },
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