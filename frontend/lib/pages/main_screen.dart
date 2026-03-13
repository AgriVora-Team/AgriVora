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
  final List<int> _navigationStack = [0];

  final List<Widget> _screens = const [
    HomePage(),
    MapPage(),
    HistoryPage(),
    AIChatPage(),
    ProfilePage(),
  ];

  int get _selectedIndex => _navigationStack.last;

  void _handleTabChange(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _navigationStack.remove(index);
      _navigationStack.add(index);
    });
  }

  Future<bool> _handleBackPress() async {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
      });
      return false;
    }
    return true;
  }

  Widget _buildBody() {
    return IndexedStack(index: _selectedIndex, children: _screens);
  }

  Widget _buildBottomNav() {
    return AgriBottomNavBar(
      activeIndex: _selectedIndex,
      onTap: _handleTabChange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        extendBody: true,
        body: Stack(children: [_buildBody(), _buildBottomNav()]),
      ),
    );
  }
}
