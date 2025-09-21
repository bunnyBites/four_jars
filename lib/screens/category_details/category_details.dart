// lib/screens/category_details/category_details_screen.dart

import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet/add_transaction_sheet.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet/add_transaction_sheet_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryName;
  final List<Transaction> transactions;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    required this.transactions,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late List<Transaction> _transactions;
  final BudgetManager _budgetManager = BudgetManager();

  @override
  void initState() {
    super.initState();
    _transactions = widget.transactions;
  }

  void _editTransaction(Transaction transaction) async {
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
      // Refresh the list after editing
      setState(() {
        final index = _transactions.indexWhere(
          (t) => t.id == updatedTransaction.id,
        );
        if (index != -1) {
          _transactions[index] = updatedTransaction;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Transactions Yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All transactions for this category will appear here',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Dismissible(
                  key: ValueKey(transaction.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _budgetManager.deleteTransaction(
                      transactionId: transaction.id,
                    );
                    setState(() {
                      _transactions.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${transaction.description} deleted'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(transaction.description),
                    subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
                    trailing: Text(
                      '- ₹${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _editTransaction(transaction), // Tap to edit
                  ),
                );
              },
            ),
    );
  }
}
