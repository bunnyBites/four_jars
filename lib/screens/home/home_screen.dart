import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:four_jars/screens/category_details/category_details_controller.dart';
import 'package:four_jars/screens/category_details/category_details_screen.dart';
import 'package:four_jars/screens/home/home_screen_controller.dart';
import 'package:four_jars/screens/home/widgets/spending_chart.dart';

import 'package:four_jars/logic/budget_manager.dart';

import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);

    return Scaffold(
      appBar: _buildAppBar(context, controller),
      body: _buildBody(context, controller),
      floatingActionButton: _buildFloatingActionButton(context, controller),
    );
  }

  AppBar _buildAppBar(BuildContext context, HomeController controller) {
    return AppBar(
      title: const Text('Four Jars'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => controller.openSettings(context),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, HomeController controller) {
    return Column(
      children: [
        _buildSpendingChart(controller),
        const Divider(height: 1),
        _buildCategoriesGrid(context, controller),
      ],
    );
  }

  Widget _buildSpendingChart(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SpendingChart(
        categories: controller.categories,
        colorMap: controller.colorMap,
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, HomeController controller) {
    return Expanded(
      child: AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return _buildCategoryGridItem(context, controller, category, index);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryGridItem(
    BuildContext context,
    HomeController controller,
    Map<String, dynamic> category,
    int index,
  ) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: 2,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: GestureDetector(
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
                    child: CategoryDetailsScreen(
                      categoryName: category['name'],
                    ),
                  ),
                ),
              );

              // When we come back, call the new refresh method
              controller.refreshData();
            },
            child: CategoryCard(
              name: category['name'],
              allocated: category['allocated'],
              spent: category['spent'],
              color: controller.colorMap[category['colorName']] ?? Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    HomeController controller,
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
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: color, size: 32),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '₹${spent.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'of ₹${allocated.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8.0),

            TweenAnimationBuilder<double>(
              // The tween defines the range. We only need to provide the target 'end' value.
              tween: Tween(end: progress),
              // Duration of the animation
              duration: const Duration(milliseconds: 400),
              // The builder gives us the animated value for each frame
              builder: (context, animatedValue, child) {
                return LinearProgressIndicator(
                  // The value is now the smoothly animated value from the builder
                  value: animatedValue,
                  minHeight: 8.0,
                  backgroundColor: color.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4.0),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
