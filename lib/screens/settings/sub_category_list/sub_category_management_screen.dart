import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/models/sub_category/sub_category.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:provider/provider.dart';

class SubCategoryManagementScreen extends StatefulWidget {
  const SubCategoryManagementScreen({super.key});

  @override
  State<SubCategoryManagementScreen> createState() =>
      _SubCategoryManagementScreenState();
}

class _SubCategoryManagementScreenState
    extends State<SubCategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BudgetManager _budgetManager;
  Map<MainCategoryType, List<SubCategory>> _categorizedSubCategories = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _budgetManager = context.read<BudgetManager>();
    _loadSubCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSubCategories() {
    _categorizedSubCategories = {
      MainCategoryType.needs: _budgetManager.getSubCategoriesFor(
        MainCategoryType.needs,
      ),
      MainCategoryType.wants: _budgetManager.getSubCategoriesFor(
        MainCategoryType.wants,
      ),
      MainCategoryType.savings: _budgetManager.getSubCategoriesFor(
        MainCategoryType.savings,
      ),
      MainCategoryType.investments: _budgetManager.getSubCategoriesFor(
        MainCategoryType.investments,
      ),
    };
  }

  void _refreshData() {
    setState(() {
      _loadSubCategories();
    });
  }

  String _getCategoryName(MainCategoryType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  Color _getCategoryColor(MainCategoryType type) {
    return AppTheme.categoryColors[type.index] ?? AppTheme.sageGray;
  }

  void _showAddEditDialog(
    MainCategoryType categoryType, {
    SubCategory? existingSubCategory,
  }) {
    final textController = TextEditingController(
      text: existingSubCategory?.name,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existingSubCategory == null
              ? 'Add ${_getCategoryName(categoryType)} Sub-category'
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
                await _budgetManager.addSubCategory(
                  name: textController.text,
                  mainCategoryId: categoryType,
                );
              } else {
                await _budgetManager.updateSubCategory(
                  id: existingSubCategory.id,
                  newName: textController.text,
                  mainCategoryId: categoryType,
                );
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                _refreshData();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sub-Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Needs'),
            Tab(text: 'Wants'),
            Tab(text: 'Savings'),
            Tab(text: 'Investments'),
          ],
          indicatorColor: AppTheme.textPrimary,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryTab(MainCategoryType.needs),
          _buildCategoryTab(MainCategoryType.wants),
          _buildCategoryTab(MainCategoryType.savings),
          _buildCategoryTab(MainCategoryType.investments),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentCategory = MainCategoryType.values[_tabController.index];
          _showAddEditDialog(currentCategory);
        },
        tooltip: 'Add Sub-category',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryTab(MainCategoryType categoryType) {
    final subCategories = _categorizedSubCategories[categoryType] ?? [];

    if (subCategories.isEmpty) {
      return _buildEmptyState(categoryType);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        final subCategory = subCategories[index];
        return _buildSubCategoryCard(categoryType, subCategory);
      },
    );
  }

  Widget _buildEmptyState(MainCategoryType categoryType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
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

  Widget _buildSubCategoryCard(
    MainCategoryType categoryType,
    SubCategory subCategory,
  ) {
    return Dismissible(
      key: ValueKey(subCategory.id),
      background: _buildDismissibleBackground(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await _budgetManager.deleteSubCategory(id: subCategory.id);
        _refreshData();

        if (mounted) {
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
          leading: Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(categoryType),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                  categoryType,
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
