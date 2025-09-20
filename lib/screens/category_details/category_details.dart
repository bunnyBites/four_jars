import 'package:flutter/material.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:intl/intl.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;
  final List<Transaction> transactions;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction.description),
            subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
            trailing: Text(
              '- ₹${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
