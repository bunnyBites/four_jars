import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/recurring_transaction/recurring_transaction.dart';

class RecurringTransactionsController extends ChangeNotifier {
  final BudgetManager _budgetManager;

  List<RecurringTransaction> get recurringTransactions =>
      _budgetManager.recurringTransactions;

  RecurringTransactionsController(this._budgetManager) {
    _budgetManager.loadData();
  }

  Future<void> addTransaction(RecurringTransaction transaction) async {
    await _budgetManager.addRecurringTransaction(transaction);
    _budgetManager.loadData();
    notifyListeners();
  }
}
