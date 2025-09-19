import 'package:flutter/material.dart';
import 'package:four_jars/screens/home/home_screen.dart';

void main() {
  runApp(const FourJarsApp());
}

class FourJarsApp extends StatelessWidget {
  const FourJarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Four Jars',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // We will replace this placeholder with our actual home screen
      home: const HomeScreen(),
    );
  }
}
