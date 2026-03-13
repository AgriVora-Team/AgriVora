import 'package:flutter/material.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      "text":
          "Hello! I am the AgriVora AI Assistant. How can I help with your farm today?",
      "isUser": false,
    },
    {"text": "What's the best fertilizer for paddy fields?", "isUser": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildChatList()),
                _buildInputBox(),
                const SizedBox(height: 110),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _messageBubble(message["text"], message["isUser"]);
      },
    );
  }

  Widget _messageBubble(String text, bool isUser) {
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

  Widget _buildInputBox() {
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
              controller: _controller,
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

  Widget _buildBottomNavigation() {
    final List<Map<String, dynamic>> navItems = [
      {"icon": Icons.home_filled, "route": "/home", "active": false},
      {"icon": Icons.alt_route_rounded, "route": "/map", "active": false},
      {"icon": Icons.memory_rounded, "route": "/ai-chat", "active": true},
      {"icon": Icons.person_pin_rounded, "route": "/profile", "active": false},
    ];

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
          children: navItems.map((item) {
            return IconButton(
              icon: Icon(
                item["icon"],
                size: 30,
                color: item["active"]
                    ? const Color(0xFF2E7D32)
                    : Colors.green.withOpacity(0.5),
              ),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, item["route"]),
            );
          }).toList(),
        ),
      ),
    );
  }
}
