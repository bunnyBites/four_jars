// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet.dart';

class HomeScreen extends StatefulWidget {
  final BudgetManager budgetManager;
  const HomeScreen({super.key, required this.budgetManager});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A map to convert color names from our constants to actual Color objects.
  final Map<String, Color> _colorMap = {
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'orange': Colors.orange,
  };

  Future<void> _addTransaction(
    double amount,
    String description,
    MainCategoryType categoryType,
  ) async {
    // Tell the manager to perform the logic.
    await widget.budgetManager.addTransaction(
      amount: amount,
      categoryType: categoryType,
    );

    // Then, simply tell the UI to rebuild itself.
    if (mounted) {
      setState(() {});
    }
  }

  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // 5. PASS the _addTransaction function to the sheet
        return AddTransactionSheet(
          onSave: _addTransaction,
          budgetManager: widget.budgetManager,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Four Jars'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.budgetManager.categories.length,
        itemBuilder: (context, index) {
          final category = widget.budgetManager.categories[index];
          return CategoryCard(
            name: category['name'],
            allocated: category['allocated'],
            spent: category['spent'],
            color: _colorMap[category['colorName']] ?? Colors.grey,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionSheet,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
