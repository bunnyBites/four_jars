import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet.dart';
import 'package:four_jars/screens/settings/settings_screen.dart';

class HomeController extends ChangeNotifier {
  final BudgetManager _budgetManager = BudgetManager();

  // Expose the manager's data through the controller
  List<Map<String, dynamic>> get categories => _budgetManager.categories;
  List<Transaction> get transactions => _budgetManager.transactions;

  final Map<String, Color> colorMap = {
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'orange': Colors.orange,
  };

  HomeController() {
    _budgetManager.loadData();
  }

  void addTransaction(
    double amount,
    String description,
    MainCategoryType categoryType,
    String subCategoryId,
  ) {
    _budgetManager.addTransaction(
      amount: amount,
      description: description,
      categoryType: categoryType,
      subCategoryId: subCategoryId,
    );
    notifyListeners(); // This is the new setState()
  }

  void openAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return AddTransactionSheet(
          onSave: (transaction) {
            // Updated onSave
            // We will create/update transaction in the manager now
            _budgetManager.addTransaction(
              // Simplified for example, should be add/update
              amount: transaction.amount,
              description: transaction.description,
              categoryType: transaction.mainCategoryId,
              subCategoryId: transaction.subCategoryId,
            );
            notifyListeners();
          },
        );
      },
    );
  }

  void openSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    _budgetManager.loadData();
    notifyListeners();
  }
}
