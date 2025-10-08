// lib/screens/home/main_screen.dart
import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/screens/dashboard/dashboard_screen.dart';
import 'package:four_jars/screens/goal/goals_controller.dart';
import 'package:four_jars/screens/goal/goals_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    ChangeNotifierProvider(
      create: (context) => GoalsController(context.read<BudgetManager>()),
      child: const GoalsScreen(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
