import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/screens/settings/sub_category_list_screen.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _incomeController = TextEditingController();
  final BudgetManager _budgetManager = BudgetManager();

  @override
  void initState() {
    super.initState();
    _budgetManager.loadData();
    // Load existing income to show in the text field
    final currentIncome = Hive.box(
      'budgetBox',
    ).get('totalIncome', defaultValue: 100000.0);
    _incomeController.text = currentIncome.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budget Settings'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _incomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'My Total Monthly Income',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Manage Sub-categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...MainCategoryType.values.map((category) {
              return ListTile(
                title: Text(
                  category.name[0].toUpperCase() + category.name.substring(1),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SubCategoryListScreen(mainCategory: category),
                    ),
                  );
                },
              );
            }).toList(),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final income = double.tryParse(_incomeController.text);
                if (income != null) {
                  _budgetManager.saveSettings(totalIncome: income);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
