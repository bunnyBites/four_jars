import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';

import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet/add_transaction_sheet.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet/add_transaction_sheet_controller.dart';
import 'package:provider/provider.dart';

class CategoryDetailsController extends ChangeNotifier {
  final BudgetManager _budgetManager;

  late List<Transaction> _allTransactions;
  List<Transaction> get transactions => _allTransactions;

  // create a new list that will be displayed in the UI
  late List<Transaction> filteredTransactions;

  final TextEditingController searchController = TextEditingController();

  String getSubCategoryName(String subCategoryId) {
    return _budgetManager.getSubCategoryNameById(subCategoryId);
  }

  CategoryDetailsController({
    required BudgetManager budgetManager,
    required List<Transaction> existingTransactions,
  }) : _budgetManager = budgetManager {
    _budgetManager.loadData();
    _allTransactions = existingTransactions;

    // initially, the filtered list is the same as the full list
    filteredTransactions = _allTransactions;
    searchController.addListener(_filterTransactions);
  }

  void _filterTransactions() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      // if the search bar is empty, show all transactions
      filteredTransactions = _allTransactions;
    } else {
      // otherwise, filter the list based on the description
      filteredTransactions = _allTransactions
          .where((t) => t.description.toLowerCase().contains(query))
          .toList();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    // clean up the controller to avoid memory leaks
    searchController.dispose();
    super.dispose();
  }

  void deleteTransaction(BuildContext context, Transaction transaction) async {
    final txIndex = _allTransactions.indexWhere(
      (tx) => tx.id == transaction.id,
    );

    // Check if transaction exists in the list
    if (txIndex == -1) {
      return; // Transaction not found, nothing to delete
    }

    final transactionToDelete = _allTransactions[txIndex];

    _allTransactions.remove(transactionToDelete);
    notifyListeners();

    // Show a SnackBar with an Undo action
    ScaffoldMessenger.of(context).clearSnackBars(); // Remove any old snackbars
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('${transactionToDelete.description} deleted'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // If undo is pressed, re-insert the item into the list
                _allTransactions.insert(txIndex, transactionToDelete);
                notifyListeners();
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          // When the SnackBar closes, check if it was because of Undo
          if (reason != SnackBarClosedReason.action) {
            // If not, permanently delete from the database
            _budgetManager.deleteTransaction(
              transactionId: transactionToDelete.id,
            );
          }
        });
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

      final index = _allTransactions.indexWhere(
        (t) => t.id == updatedTransaction.id,
      );

      if (index != -1) {
        _allTransactions[index] = updatedTransaction;
        notifyListeners();
      }
    }
  }
}
