import 'package:flutter/material.dart';
import 'package:four_jars/screens/category_details/category_details_controller.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:intl/intl.dart';
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
    return AppBar(title: Text(categoryName));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            'No transactions yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    CategoryDetailsController controller,
  ) {
    return Column(
      children: [
        _buildSearchBar(controller),
        Expanded(
          child: controller.filteredTransactions.isEmpty
              ? _buildNoResultsState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceM,
                    vertical: AppTheme.spaceS,
                  ),
                  itemCount: controller.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.filteredTransactions[index];
                    return _buildTransactionCard(
                      context,
                      controller,
                      transaction,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(CategoryDetailsController controller) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppTheme.spaceM),
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            'No matching transactions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    CategoryDetailsController controller,
    dynamic transaction,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final transactionDate = transaction.date ?? DateTime.now();

    return Dismissible(
      key: ValueKey(transaction.id),
      background: _buildDismissibleBackground(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        controller.deleteTransaction(context, transaction);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${transaction.description} deleted'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: InkWell(
          onTap: () => controller.editTransaction(context, transaction),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceM),
            child: Row(
              children: [
                // Left side - Description and sub-category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getSubCategoryName(
                          transaction.subCategoryId,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceM),
                // Right side - Amount, date, and chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${transaction.amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dateFormat.format(transactionDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppTheme.spaceL),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }
}
