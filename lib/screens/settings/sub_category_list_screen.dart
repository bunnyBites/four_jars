import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';
import 'package:provider/provider.dart';

class SubCategoryListScreen extends StatefulWidget {
  final MainCategoryType mainCategory;
  const SubCategoryListScreen({super.key, required this.mainCategory});

  @override
  State<SubCategoryListScreen> createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  late BudgetManager _budgetManager;
  late List<SubCategory> _subCategories;

  @override
  void initState() {
    super.initState();
    _budgetManager = context.read<BudgetManager>();
    _loadSubCategories();
  }

  void _loadSubCategories() {
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
            onPressed: () {
              if (mounted) {
                Navigator.pop(ctx);
              }
            },
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
              if (mounted) {
                _loadSubCategories();
                Navigator.pop(ctx);
              }
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
            onPressed: () {
              if (mounted) {
                _showAddEditDialog();
              }
            },
            tooltip: 'Add Sub-category',
          ),
        ],
      ),
      body: _subCategories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Sub-categories Yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first sub-category',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (mounted) {
                        _showAddEditDialog();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Sub-category'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
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
                    // Remove from local state first to prevent tree issues
                    final deletedSubCategory = subCategory;
                    setState(() {
                      _subCategories.removeAt(index);
                    });

                    // Then delete from database
                    await _budgetManager.deleteSubCategory(
                      id: deletedSubCategory.id,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${deletedSubCategory.name} deleted'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(subCategory.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        if (mounted) {
                          _showAddEditDialog(existingSubCategory: subCategory);
                        }
                      },
                      tooltip: 'Edit Sub-category',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
