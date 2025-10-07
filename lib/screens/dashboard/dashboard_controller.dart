import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/models/transaction/transaction.dart';
import 'package:four_jars/screens/main/widgets/add_transaction_sheet/add_transaction_sheet.dart';
import 'package:four_jars/screens/main/widgets/add_transaction_sheet/add_transaction_sheet_controller.dart';
import 'package:four_jars/screens/report/report_screen.dart';
import 'package:four_jars/screens/report/report_screen_controller.dart';
import 'package:four_jars/screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';

class DashboardController extends ChangeNotifier {
  final BudgetManager _budgetManager;

  late Future<void> initFuture;

  // expose the manager's data through the controller
  List<Map<String, dynamic>> get categories => _budgetManager.categories;
  List<Transaction> get transactions => _budgetManager.transactions;

  final Map<String, Color> colorMap = {
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'orange': Colors.orange,
  };

  DashboardController(this._budgetManager) {
    initFuture = _initialize();
  }

  Future<void> _initialize() async {
    // process recurring transactions first
    await _budgetManager.processRecurringTransactions();

    // load all data (which now includes any new transactions)
    _budgetManager.loadData();
  }

  void refreshData() {
    _budgetManager.loadData();
    notifyListeners();
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
    notifyListeners();
  }

  void openAddTransactionSheet(BuildContext context) async {
    final newTransaction = await showModalBottomSheet<Transaction>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return ChangeNotifierProvider(
          create: (_) => AddTransactionController(),
          child: const AddTransactionSheet(),
        );
      },
    );

    if (newTransaction != null) {
      _budgetManager.addTransaction(
        amount: newTransaction.amount,
        description: newTransaction.description,
        categoryType: newTransaction.mainCategoryId,
        subCategoryId: newTransaction.subCategoryId,
      );
      notifyListeners();
    }
  }

  void openSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    _budgetManager.loadData();
    notifyListeners();
  }

  void openReportsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          // Provide the ReportsController, giving it the BudgetManager
          create: (_) => ReportsController(context.read<BudgetManager>()),
          child: const ReportsScreen(),
        ),
      ),
    );
  }
}
