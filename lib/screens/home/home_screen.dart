// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet.dart';

// --- 1. DUMMY DATA ---
// We'll create some temporary data to simulate a user's budget.
// Later, this will come from our database.
final List<Map<String, dynamic>> dummyCategories = [
  {
    'name': 'Needs',
    'allocated': 50000.0,
    'spent': 32500.0,
    'color': Colors.green,
  },
  {
    'name': 'Wants',
    'allocated': 30000.0,
    'spent': 15750.0,
    'color': Colors.blue,
  },
  {
    'name': 'Savings',
    'allocated': 10000.0,
    'spent': 10000.0,
    'color': Colors.purple,
  },
  {
    'name': 'Investments',
    'allocated': 10000.0,
    'spent': 10000.0,
    'color': Colors.orange,
  },
];

// --- 2. THE MAIN HOME SCREEN WIDGET ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Four Jars'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      // Use a ListView.builder to create a scrollable list of our category cards
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0), // Add some spacing around the list
        itemCount: dummyCategories.length, // The number of items in the list
        itemBuilder: (context, index) {
          final category = dummyCategories[index];
          // For each item in our dummy data, create a CategoryCard
          return CategoryCard(
            name: category['name'],
            allocated: category['allocated'],
            spent: category['spent'],
            color: category['color'],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            // isScrollControlled allows the sheet to take up more screen space
            // and avoids the keyboard covering the text fields.
            isScrollControlled: true,
            builder: (ctx) {
              // Return the widget we just created!
              return const AddTransactionSheet();
            },
          );
        },
        backgroundColor: Colors.teal, // Use a color from our theme
        foregroundColor: Colors.white,
        tooltip: 'Add Transaction', // Shows on long-press
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- 3. THE REUSABLE CARD WIDGET ---
class CategoryCard extends StatelessWidget {
  final String name;
  final double allocated;
  final double spent;
  final Color color;

  const CategoryCard({
    super.key,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        spent / allocated; // Calculate progress from 0.0 to 1.0
    final double remaining = allocated - spent;

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0), // Space between cards
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Title
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12.0),

            // Spent vs Allocated Text
            Text(
              '₹${spent.toStringAsFixed(0)} / ₹${allocated.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8.0),

            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              minHeight: 12.0,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(6.0),
            ),
            const SizedBox(height: 8.0),

            // Remaining Amount Text
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Remaining: ₹${remaining.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
