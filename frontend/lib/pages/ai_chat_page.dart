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
          const BackgroundImage(),
          SafeArea(
            child: Column(
              children: [
                const HeaderSection(),
                const Expanded(child: ChatSection()),
                InputSection(controller: _controller),
                const SizedBox(height: 110),
              ],
            ),
          ),
          const FloatingBottomNav(),
        ],
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AgriVora",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF424242),
                ),
              ),
              Text(
                "AI Assistant",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatSection extends StatelessWidget {
  const ChatSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        ChatBubble(
          text:
              "Hello! I am the AgriVora AI Assistant. How can I help with your farm today?",
          isUser: false,
        ),
        ChatBubble(
          text: "What's the best fertilizer for paddy fields?",
          isUser: true,
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF2E7D32)
              : const Color(0xFFE8F5E9).withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class InputSection extends StatelessWidget {
  final TextEditingController controller;

  const InputSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Ask your question...",
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.send, color: Colors.green),
        ],
      ),
    );
  }
}

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            NavIcon(icon: Icons.home_filled, route: '/home', active: false),
            NavIcon(
              icon: Icons.alt_route_rounded,
              route: '/map',
              active: false,
            ),
            NavIcon(
              icon: Icons.memory_rounded,
              route: '/ai-chat',
              active: true,
            ),
            NavIcon(
              icon: Icons.person_pin_rounded,
              route: '/profile',
              active: false,
            ),
          ],
        ),
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  final IconData icon;
  final String route;
  final bool active;

  const NavIcon({
    super.key,
    required this.icon,
    required this.route,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 30,
        color: active ? const Color(0xFF2E7D32) : Colors.green.withOpacity(0.5),
      ),
      onPressed: () => Navigator.pushReplacementNamed(context, route),
    );
  }
}
