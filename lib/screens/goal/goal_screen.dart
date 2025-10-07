import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: const Center(child: Text('Your savings goals will appear here.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We will add logic to create a new goal here
        },
        tooltip: 'Add Goal',
        child: const Icon(Icons.add),
      ),
    );
  }
}
