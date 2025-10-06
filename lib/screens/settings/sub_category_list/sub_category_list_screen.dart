import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/models/sub_category/sub_category.dart';
import 'package:four_jars/screens/settings/sub_category_list/sub_category_list_controller.dart';
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
      builder: (ctx) => _buildDialog(
        context: ctx,
        controller: controller,
        textController: textController,
        existingSubCategory: existingSubCategory,
      ),
    );
  }

  Widget _buildDialog({
    required BuildContext context,
    required SubCategoryListController controller,
    required TextEditingController textController,
    SubCategory? existingSubCategory,
  }) {
    return AlertDialog(
      title: Text(
        existingSubCategory == null ? 'Add Sub-category' : 'Edit Sub-category',
      ),
      content: TextField(
        controller: textController,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
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

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
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
        );
      },
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    SubCategoryListController controller,
  ) {
    return AppBar(
      title: Text('${controller.categoryName} Sub-categories'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddEditDialog(context),
          tooltip: 'Add Sub-category',
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Sub-categories Yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first sub-category',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Sub-category'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
      itemCount: controller.subCategories.length,
      itemBuilder: (context, index) {
        final subCategory = controller.subCategories[index];
        return _buildSubCategoryTile(context, controller, subCategory);
      },
    );
  }

  Widget _buildSubCategoryTile(
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
            ),
          );
        }
      },
      child: ListTile(
        title: Text(subCategory.name),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () =>
              _showAddEditDialog(context, existingSubCategory: subCategory),
          tooltip: 'Edit Sub-category',
        ),
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
