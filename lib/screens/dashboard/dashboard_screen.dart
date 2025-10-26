import 'package:flutter/material.dart';
import 'package:four_jars/screens/category_details/category_details_controller.dart';
import 'package:four_jars/screens/category_details/category_details_screen.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/screens/dashboard/dashboard_controller.dart';
import 'package:four_jars/screens/main/widgets/spending_chart.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    return Scaffold(
      appBar: _buildAppBar(context, controller),
      body: _buildBody(context, controller),
      floatingActionButton: _buildFloatingActionButton(context, controller),
    );
  }

  AppBar _buildAppBar(BuildContext context, DashboardController controller) {
    return AppBar(
      title: const Text('Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart_outlined),
          onPressed: () => controller.openReportsScreen(context),
          tooltip: 'Reports',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => controller.openSettings(context),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DashboardController controller) {
    return FutureBuilder(
      future: controller.initFuture,
      builder: (context, snapshot) {
        // while the future is running, show a loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // if there was an error, show an error message
        if (snapshot.hasError) {
          return const Center(child: Text('Error initializing app.'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildSpendingChart(controller),
              _buildCategoriesGrid(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendingChart(DashboardController controller) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: SpendingChart(
          categories: controller.categories,
          colorMap: controller.colorMap,
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(
    BuildContext context,
    DashboardController controller,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceM),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spaceM,
        mainAxisSpacing: AppTheme.spaceM,
        childAspectRatio: 1,
      ),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildCategoryGridItem(context, controller, category, index);
      },
    );
  }

  Widget _buildCategoryGridItem(
    BuildContext context,
    DashboardController controller,
    Map<String, dynamic> category,
    int index,
  ) {
    return GestureDetector(
      onTap: () async {
        final categoryTransactions = controller.transactions
            .where((t) => t.mainCategoryId == category['type'])
            .toList();

        // 'await' here will pause until the details screen is closed
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => CategoryDetailsController(
                budgetManager: context.read<BudgetManager>(),
                existingTransactions: categoryTransactions,
              ),
              child: CategoryDetailsScreen(categoryName: category['name']),
            ),
          ),
        );

        // When we come back, call the new refresh method
        await controller.refreshData();
      },
      child: CategoryCard(
        name: category['name'],
        allocated: category['allocated'],
        spent: category['spent'],
        color:
            AppTheme.categoryColors[(category['type'] as MainCategoryType)
                .index] ??
            Colors.grey,
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    DashboardController controller,
  ) {
    return FloatingActionButton(
      onPressed: () => controller.openAddTransactionSheet(context),
      tooltip: 'Add Transaction',
      child: const Icon(Icons.add),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final double allocated;
  final double spent;
  final Color color;

  const CategoryCard({
    super.key,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // The target progress value. Can be from 0.0 to 1.0.
    final double progress = (allocated > 0) ? spent / allocated : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon at top
            Icon(Icons.savings_outlined, color: color, size: 28),
            const SizedBox(height: AppTheme.spaceS),
            // Category name
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Amount spent
            Text(
              '₹${spent.toStringAsFixed(0)}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            // Amount allocated
            Text(
              'of ₹${allocated.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceM),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, animatedValue, child) {
                  return LinearProgressIndicator(
                    value: animatedValue,
                    minHeight: 6.0,
                    backgroundColor: AppTheme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
