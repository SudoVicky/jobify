import 'package:flutter/material.dart';
import 'notification_page.dart';
import 'preferences_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Tracks the selected tab index

  // Pages for each tab
  final List<Widget> _pages = [
    const NotificationPage(),
    const PreferencesPage(),
  ];

  // Update selected tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Displays the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Preferences',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Highlight selected tab
        onTap: _onItemTapped,
      ),
    );
  }
}
