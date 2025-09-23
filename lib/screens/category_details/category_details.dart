import 'package:flutter/material.dart';
import 'package:four_jars/screens/category_details/category_details_controller.dart';

import 'package:provider/provider.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CategoryDetailsController>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: controller.transactions.isEmpty
          ? _buildEmptyState(context)
          : _buildTransactionsList(context, controller),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(categoryName),
      backgroundColor: Colors.blueGrey[800],
      foregroundColor: Colors.white,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    CategoryDetailsController controller,
  ) {
    return ListView.builder(
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return _buildTransactionTile(context, controller, transaction);
      },
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    CategoryDetailsController controller,
    dynamic transaction,
  ) {
    return Dismissible(
      key: ValueKey(transaction.id),
      background: _buildDismissibleBackground(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await controller.deleteTransaction(transaction);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${transaction.description} deleted'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: ListTile(
        title: Text(transaction.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sub-category: ${controller.getSubCategoryName(transaction.subCategoryId)}',
            ),
          ],
        ),
        trailing: Text(
          '- ₹${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () =>
            controller.editTransaction(context, transaction), // Tap to edit
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
