// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Needs',
      'type': MainCategoryType.needs,
      'allocated': 50000.0,
      'spent': 32500.0,
      'color': Colors.green,
    },
    {
      'name': 'Wants',
      'type': MainCategoryType.wants,
      'allocated': 30000.0,
      'spent': 15750.0,
      'color': Colors.blue,
    },
    {
      'name': 'Savings',
      'type': MainCategoryType.savings,
      'allocated': 10000.0,
      'spent': 10000.0,
      'color': Colors.purple,
    },
    {
      'name': 'Investments',
      'type': MainCategoryType.investments,
      'allocated': 10000.0,
      'spent': 10000.0,
      'color': Colors.orange,
    },
  ];

  // 3. CREATE the function to handle adding a transaction
  void _addTransaction(
    double amount,
    String description,
    MainCategoryType categoryType,
  ) {
    // setState() tells Flutter that data has changed and the UI needs to rebuild
    setState(() {
      final categoryIndex = _categories.indexWhere(
        (cat) => cat['type'] == categoryType,
      );
      if (categoryIndex != -1) {
        _categories[categoryIndex]['spent'] += amount;
      }
    });
    // In a real app, you would also save the full transaction object to a database here
    print('Added transaction: $description - ₹$amount to ${categoryType.name}');
  }

  // 4. CREATE the function to show the modal
  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // 5. PASS the _addTransaction function to the sheet
        return AddTransactionSheet(onSave: _addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Four Jars'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryCard(
            name: category['name'],
            allocated: category['allocated'],
            spent: category['spent'],
            color: category['color'],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // 6. CALL our new function to open the modal
        onPressed: _openAddTransactionSheet,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        tooltip: 'Add Transaction',
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
