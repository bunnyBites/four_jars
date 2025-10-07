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

  DateTime calculateNextDueDate(RecurringTransaction tx) {
    final lastDate = tx.lastProcessedDate ?? tx.startDate;

    switch (tx.frequency) {
      case RecurrenceFrequency.daily:
        return DateTime(lastDate.year, lastDate.month, lastDate.day + 1);
      case RecurrenceFrequency.weekly:
        return DateTime(lastDate.year, lastDate.month, lastDate.day + 7);
      default:
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
    }
  }
}
