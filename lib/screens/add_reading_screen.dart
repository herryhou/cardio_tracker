import 'package:flutter/material.dart';

class AddReadingScreen extends StatelessWidget {
  const AddReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reading'),
      ),
      body: const Center(
        child: Text(
          'Add Reading - Coming Soon',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}