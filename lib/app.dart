import 'package:flutter/material.dart';
import 'presentation/screens/main_container_screen.dart';
import 'presentation/screens/splash_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    // Hide splash after animations complete (2 seconds total)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _showSplash
          ? const SplashScreen(key: ValueKey('splash'))
          : const MainContainerScreen(key: ValueKey('main')),
    );
  }
}