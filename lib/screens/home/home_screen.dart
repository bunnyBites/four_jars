import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/screens/category_details/category_details.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet.dart';
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

  void _addTransaction(
    double amount,
    String description,
    MainCategoryType categoryType,
    String subCategoryId,
  ) {
    setState(() {
      _budgetManager.addTransaction(
        amount: amount,
        description: description,
        categoryType: categoryType,
        subCategoryId: subCategoryId,
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
        title: const Text('My Four Jars'),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _budgetManager.categories.length,
        itemBuilder: (context, index) {
          final category = _budgetManager.categories[index];
          return GestureDetector(
            onTap: () {
              final categoryTransactions = _budgetManager.transactions
                  .where((t) => t.mainCategoryId == category['type'])
                  .toList();
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
    final double progress = (allocated > 0) ? spent / allocated : 0.0;
    final double remaining = allocated - spent;

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              '₹${spent.toStringAsFixed(0)} / ₹${allocated.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12.0,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(6.0),
            ),
            const SizedBox(height: 8.0),
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
