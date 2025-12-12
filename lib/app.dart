import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/distribution_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DistributionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6A1B9A),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.only(top: 3.0),
                child: const Icon(
                  Icons.home_outlined,
                  size: 24,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.only(top: 3.0),
                child: const Icon(
                  Icons.home,
                  size: 24,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.only(top: 3.0),
                child: const Icon(
                  Icons.show_chart_outlined,
                  size: 24,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.only(top: 3.0),
                child: const Icon(
                  Icons.show_chart,
                  size: 24,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              label: 'Trends',
            ),
          ],
        ),
      ),
    );
  }
}