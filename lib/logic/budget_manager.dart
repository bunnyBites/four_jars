import 'package:four_jars/constants/app_data.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetManager {
  final _budgetBox = Hive.box('budgetBox');
  final _transactionsBox = Hive.box<Transaction>('transactionsBox');

  List<Map<String, dynamic>> categories = [];
  List<Transaction> transactions = [];

  void loadData() {
    // Load transactions first
    transactions = _transactionsBox.values.toList();

    // Load saved settings or use defaults
    final double totalIncome = _budgetBox.get(
      'totalIncome',
      defaultValue: 100000.0,
    );
    final Map<String, int> percentages = {
      'needs': _budgetBox.get('needsPercentage', defaultValue: 50),
      'wants': _budgetBox.get('wantsPercentage', defaultValue: 30),
      'savings': _budgetBox.get('savingsPercentage', defaultValue: 10),
      'investments': _budgetBox.get('investmentsPercentage', defaultValue: 10),
    };

    // Re-calculate the budget based on settings and transactions
    _calculateBudget(totalIncome: totalIncome, percentages: percentages);
  }

  void _calculateBudget({
    required double totalIncome,
    required Map<String, int> percentages,
  }) {
    final List<Map<String, dynamic>> freshCategories = List.from(
      initialCategoriesData,
    );

    for (var category in freshCategories) {
      final type = category['type'] as MainCategoryType;
      final percentage = percentages[type.name] ?? 0;

      // Calculate the allocated amount
      category['allocated'] = totalIncome * (percentage / 100);

      // Calculate spent amount by summing up relevant transactions
      final relevantTransactions = transactions.where(
        (t) => t.mainCategoryId == type,
      );
      category['spent'] = relevantTransactions.fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
    }

    categories = freshCategories;
  }

  // Save the user's settings to Hive
  Future<void> saveSettings({required double totalIncome}) async {
    // For now, we'll keep the percentages fixed, but we save the income
    await _budgetBox.put('totalIncome', totalIncome);

    // After saving, we must reload the data to apply the new budget
    loadData();
  }

  Future<void> _saveTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  // UPDATED: This method is now simpler
  void addTransaction({
    required double amount,
    required String description,
    required MainCategoryType categoryType,
  }) {
    final newTransaction = Transaction(
      id: DateTime.now().toIso8601String(),
      amount: amount,
      description: description,
      date: DateTime.now(),
      mainCategoryId: categoryType,
    );

    transactions.add(newTransaction);
    _saveTransaction(newTransaction);

    // After adding a transaction, we must reload the budget state
    loadData();
  }
}
