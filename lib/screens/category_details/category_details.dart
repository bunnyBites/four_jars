// lib/screens/category_details/category_details_screen.dart

import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet.dart';
import 'package:intl/intl.dart';

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

  void _editTransaction(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTransactionSheet(
        existingTransaction: transaction,
        onSave: (updatedTransaction) async {
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
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
