import 'package:flutter/material.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("AgriVora",
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF424242))),
                          Text("AI Assistant",
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildBubble("Hello! I am the AgriVora AI Assistant. How can I help with your farm today?", false),
                      _buildBubble("What's the best fertilizer for paddy fields?", true),
                    ],
                  ),
                ),
                _buildInputSection(),
                const SizedBox(height: 110),
              ],
            ),
          ),
          _buildFloatingBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9).withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(35)),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Ask your question...", border: InputBorder.none))),
          const Icon(Icons.send, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(context, Icons.home_filled, '/home', false),
            _navIcon(context, Icons.alt_route_rounded, '/map', false),
            _navIcon(context, Icons.memory_rounded, '/ai-chat', true),
            _navIcon(context, Icons.person_pin_rounded, '/profile', false),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, String route, bool active) {
    return IconButton(
      icon: Icon(icon, size: 30, color: active ? const Color(0xFF2E7D32) : Colors.green.withOpacity(0.5)),
      onPressed: () => Navigator.pushReplacementNamed(context, route),
    );
  }
}