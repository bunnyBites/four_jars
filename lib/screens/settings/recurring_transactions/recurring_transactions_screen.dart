import 'package:flutter/material.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: const Center(
        child: Text('Your recurring transactions will be listed here.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We will build the "add" form next
        },
        tooltip: 'Add Recurring Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
