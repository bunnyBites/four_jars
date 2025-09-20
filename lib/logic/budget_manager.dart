// lib/logic/budget_manager.dart

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
    // Load categories summary
    final savedCategories = _budgetBox.get('CATEGORIES');
    if (savedCategories != null) {
      categories = List<Map<String, dynamic>>.from(
        savedCategories.map((item) => Map<String, dynamic>.from(item)),
      );
    } else {
      categories = List.from(initialCategoriesData);
    }

    // Load all transactions
    transactions = _transactionsBox.values.toList();
  }

  Future<void> _saveCategories() async {
    await _budgetBox.put('CATEGORIES', categories);
  }

  Future<void> _saveTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  void addTransaction({
    required double amount,
    required String description,
    required MainCategoryType categoryType,
  }) {
    // 1. Create the new transaction object
    final newTransaction = Transaction(
      id: DateTime.now().toIso8601String(),
      amount: amount,
      description: description,
      date: DateTime.now(),
      mainCategoryId: categoryType,
    );

    // 2. Add it to our local list and save it to its box
    transactions.add(newTransaction);
    _saveTransaction(newTransaction);

    // 3. Update the category summary and save it
    final categoryIndex = categories.indexWhere(
      (cat) => cat['type'] == categoryType,
    );
    if (categoryIndex != -1) {
      categories[categoryIndex]['spent'] += amount;
      _saveCategories();
    }
  }
}
