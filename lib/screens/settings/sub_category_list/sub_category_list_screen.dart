import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/models/sub_category/sub_category.dart';
import 'package:four_jars/screens/settings/sub_category_list/sub_category_list_controller.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:provider/provider.dart';

class SubCategoryListScreen extends StatelessWidget {
  final MainCategoryType mainCategory;

  const SubCategoryListScreen({super.key, required this.mainCategory});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubCategoryListController(
        context.read<BudgetManager>(),
        mainCategory,
      ),
      child: const _SubCategoryListView(),
    );
  }
}

class _SubCategoryListView extends StatelessWidget {
  const _SubCategoryListView();

  void _showAddEditDialog(
    BuildContext context, {
    SubCategory? existingSubCategory,
  }) {
    final controller = context.read<SubCategoryListController>();
    final textController = TextEditingController(
      text: existingSubCategory?.name,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existingSubCategory == null
              ? 'Add Sub-category'
              : 'Edit Sub-category',
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g., Groceries',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;

              if (existingSubCategory == null) {
                await controller.addSubCategory(textController.text);
              } else {
                await controller.updateSubCategory(
                  existingSubCategory,
                  textController.text,
                );
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubCategoryListController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: _buildAppBar(context, controller),
          body: controller.subCategories.isEmpty
              ? _buildEmptyState(context)
              : _buildSubCategoriesList(context, controller),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditDialog(context),
            tooltip: 'Add Sub-category',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    SubCategoryListController controller,
  ) {
    return AppBar(title: Text('${controller.categoryName} Sub-categories'));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            'No sub-categories yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            'Tap + to add your first sub-category',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesList(
    BuildContext context,
    SubCategoryListController controller,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      itemCount: controller.subCategories.length,
      itemBuilder: (context, index) {
        final subCategory = controller.subCategories[index];
        return _buildSubCategoryCard(context, controller, subCategory);
      },
    );
  }

  Widget _buildSubCategoryCard(
    BuildContext context,
    SubCategoryListController controller,
    SubCategory subCategory,
  ) {
    return Dismissible(
      key: ValueKey(subCategory.id),
      background: _buildDismissibleBackground(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await controller.deleteSubCategory(subCategory);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${subCategory.name} deleted'),
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          title: Text(
            subCategory.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showAddEditDialog(
                  context,
                  existingSubCategory: subCategory,
                ),
                tooltip: 'Edit',
              ),
              const Icon(Icons.drag_handle, color: AppTheme.textSecondary),
            ],
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
