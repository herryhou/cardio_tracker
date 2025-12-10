import 'package:flutter/material.dart';
import 'screens/neumorphic_demo_screen.dart';

void main() {
  runApp(const NeumorphicDemoApp());
}

class NeumorphicDemoApp extends StatelessWidget {
  const NeumorphicDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const NeumorphicDemoScreen();
  }
}