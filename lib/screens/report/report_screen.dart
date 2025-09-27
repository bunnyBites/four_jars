import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Reports')),
      body: const Center(
        child: Text(
          'Monthly charts and summaries will be here!',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
