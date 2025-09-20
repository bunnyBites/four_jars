import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';

class SubCategoryListScreen extends StatefulWidget {
  final MainCategoryType mainCategory;
  const SubCategoryListScreen({super.key, required this.mainCategory});

  @override
  State<SubCategoryListScreen> createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  final BudgetManager _budgetManager = BudgetManager();
  late List<SubCategory> _subCategories;

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  void _loadSubCategories() {
    _budgetManager.loadData();
    setState(() {
      _subCategories = _budgetManager.getSubCategoriesFor(widget.mainCategory);
    });
  }

  void _showAddEditDialog({SubCategory? existingSubCategory}) {
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
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isEmpty) return;

              if (existingSubCategory == null) {
                await _budgetManager.addSubCategory(
                  name: textController.text,
                  mainCategoryId: widget.mainCategory,
                );
              } else {
                await _budgetManager.updateSubCategory(
                  id: existingSubCategory.id,
                  newName: textController.text,
                  mainCategoryId: widget.mainCategory,
                );
              }
              _loadSubCategories();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryName =
        widget.mainCategory.name[0].toUpperCase() +
        widget.mainCategory.name.substring(1);
    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName Sub-categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add Sub-category',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = _subCategories[index];
          return Dismissible(
            key: ValueKey(subCategory.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              await _budgetManager.deleteSubCategory(id: subCategory.id);
              _loadSubCategories();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subCategory.name} deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: ListTile(
              title: Text(subCategory.name),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () =>
                    _showAddEditDialog(existingSubCategory: subCategory),
                tooltip: 'Edit Sub-category',
              ),
            ),
          );
        },
      ),
    );
  }
}
