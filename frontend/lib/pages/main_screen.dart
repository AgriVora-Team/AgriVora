import 'package:flutter/material.dart';
import '../widgets/agri_bottom_nav_bar.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'history_page.dart';
import 'ai_chat_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<int> _tabTrail = [0];

  int get currentTab => _tabTrail.last;

  List<Widget> get pages => const [
    HomePage(),
    MapPage(),
    HistoryPage(),
    AIChatPage(),
    ProfilePage(),
  ];

  void _selectTab(int index) {
    if (currentTab == index) {
      return;
    }

    setState(() {
      if (_tabTrail.contains(index)) {
        _tabTrail.remove(index);
      }
      _tabTrail.add(index);
    });
  }

  Future<bool> _handleSystemBack() async {
    final hasPreviousTab = _tabTrail.length > 1;

    if (hasPreviousTab) {
      setState(() {
        _tabTrail.removeLast();
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSystemBack,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            IndexedStack(index: currentTab, children: pages),
            AgriBottomNavBar(activeIndex: currentTab, onTap: _selectTab),
          ],
        ),
      ),
    );
  }
}
