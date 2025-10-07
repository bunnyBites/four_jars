import 'package:flutter/material.dart';
import 'package:four_jars/models/recurring_transaction/recurring_transaction.dart';
import 'package:four_jars/screens/settings/recurring_transactions/add_edit_transaction/add_edit_transaction_screen.dart';
import 'package:four_jars/screens/settings/recurring_transactions/recurring_transactions_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RecurringTransactionsController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: controller.recurringTransactions.isEmpty
          ? const Center(child: Text('No recurring transactions set up yet.'))
          : ListView.builder(
              itemCount: controller.recurringTransactions.length,
              itemBuilder: (context, index) {
                final tx = controller.recurringTransactions[index];
                final nextDueDate = controller.calculateNextDueDate(tx);

                return ListTile(
                  title: Text(tx.description),
                  subtitle: Text(
                    '₹${tx.amount.toStringAsFixed(0)} every ${tx.frequency.name}',
                  ),
                  // display the calculated next due date
                  trailing: Text(
                    'Next: ${DateFormat.yMd().format(nextDueDate)}',
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTx = await Navigator.push<RecurringTransaction>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditRecurringTransactionScreen(),
            ),
          );
          if (newTx != null) {
            controller.addTransaction(newTx);
          }
        },
        tooltip: 'Add Recurring Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
