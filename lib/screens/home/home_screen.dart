import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/category_details/category_details.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet.dart';
import 'package:four_jars/screens/home/widgets/spending_chart.dart';
import 'package:four_jars/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _budgetManager = BudgetManager();

  final Map<String, Color> _colorMap = {
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'orange': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _budgetManager.loadData();
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _budgetManager.addTransaction(
        amount: transaction.amount,
        description: transaction.description,
        categoryType: transaction.mainCategoryId,
        subCategoryId: transaction.subCategoryId,
      );
    });
  }

  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return AddTransactionSheet(onSave: _addTransaction);
      },
    );
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    setState(() {
      _budgetManager.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Four Jars'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SpendingChart(
              categories: _budgetManager.categories,
              colorMap: _colorMap,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            // --- CHANGE 1: Replace ListView.builder with GridView.builder ---
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              // This delegate defines the grid's layout
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 16, // Horizontal space between items
                mainAxisSpacing: 16, // Vertical space between items
                childAspectRatio: 1, // Makes the items square (width == height)
              ),
              itemCount: _budgetManager.categories.length,
              itemBuilder: (context, index) {
                final category = _budgetManager.categories[index];
                return GestureDetector(
                  onTap: () {
                    final categoryTransactions = _budgetManager.transactions
                        .where((t) => t.mainCategoryId == category['type'])
                        .toList();

                    print(
                      'Found ${categoryTransactions.length} transactions for this category.',
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailsScreen(
                          categoryName: category['name'],
                          transactions: categoryTransactions,
                        ),
                      ),
                    );
                  },
                  child: CategoryCard(
                    name: category['name'],
                    allocated: category['allocated'],
                    spent: category['spent'],
                    color: _colorMap[category['colorName']] ?? Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
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

// In lib/screens/home/home_screen.dart

// --- Updated CategoryCard with Piggy Bank Icon ---
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
    final double progress = (allocated > 0) ? spent / allocated : 0.0;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: color, size: 32),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '₹${spent.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'of ₹${allocated.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8.0,
              backgroundColor: color.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4.0),
            ),
          ],
        ),
      ),
    );
  }
}
