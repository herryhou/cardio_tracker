import 'package:flutter/material.dart';

class DistributionScreen extends StatelessWidget {
  const DistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution'),
      ),
      body: const Center(
        child: Text(
          'Distribution - Coming Soon',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}