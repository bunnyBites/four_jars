import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet/add_transaction_sheet.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet/add_transaction_sheet_controller.dart';
import 'package:provider/provider.dart';

class CategoryDetailsController extends ChangeNotifier {
  final BudgetManager _budgetManager = BudgetManager();

  late List<Transaction> _transactions;
  List<Transaction> get transactions => _transactions;

  CategoryDetailsController({required List<Transaction> existingTransactions}) {
    _transactions = existingTransactions;
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _budgetManager.deleteTransaction(transactionId: transaction.id);
    _transactions.remove(transaction);
    notifyListeners(); // This tells the UI to rebuild.
  }

  Future<void> editTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    final updatedTransaction = await showModalBottomSheet<Transaction>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider(
        // Provide controller with existing data for edit mode
        create: (_) =>
            AddTransactionController(existingTransaction: transaction),
        child: const AddTransactionSheet(),
      ),
    );

    if (updatedTransaction != null) {
      await _budgetManager.updateTransaction(
        updatedTransaction: updatedTransaction,
      );

      final index = _transactions.indexWhere(
        (t) => t.id == updatedTransaction.id,
      );

      if (index != -1) {
        _transactions[index] = updatedTransaction;
        notifyListeners();
      }
    }
  }
}
