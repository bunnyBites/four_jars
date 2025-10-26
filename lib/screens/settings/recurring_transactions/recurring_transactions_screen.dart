import 'package:flutter/material.dart';
import 'package:four_jars/models/recurring_transaction/recurring_transaction.dart';
import 'package:four_jars/screens/settings/recurring_transactions/add_edit_transaction/add_edit_transaction_screen.dart';
import 'package:four_jars/screens/settings/recurring_transactions/recurring_transactions_controller.dart';
import 'package:four_jars/theme/app_theme.dart';
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
          ? _buildEmptyState(context)
          : _buildTransactionsList(context, controller),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            'No recurring transactions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            'Tap + to add your first recurring transaction',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    RecurringTransactionsController controller,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      itemCount: controller.recurringTransactions.length,
      itemBuilder: (context, index) {
        final tx = controller.recurringTransactions[index];
        return _buildTransactionCard(context, controller, tx);
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    RecurringTransactionsController controller,
    RecurringTransaction tx,
  ) {
    final nextDueDate = controller.calculateNextDueDate(tx);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spaceM),
        title: Text(
          tx.description,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '₹${tx.amount.toStringAsFixed(0)} • ${_capitalizeFirst(tx.frequency.name)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Next on: ${dateFormat.format(nextDueDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
        onTap: () {
          // Could navigate to edit screen here
        },
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
