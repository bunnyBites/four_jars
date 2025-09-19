import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A Scaffold provides the basic structure of a visual screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Four Jars'),
        backgroundColor: Colors.blueGrey[900], // A nice dark color
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Dashboard will go here!')),
    );
  }
}
