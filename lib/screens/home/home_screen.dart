import 'package:flutter/material.dart';
import 'package:four_jars/screens/category_details/category_details.dart';
import 'package:four_jars/screens/home/home_screen_controller.dart';
import 'package:four_jars/screens/home/widgets/spending_chart.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the controller
    final controller = Provider.of<HomeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Four Jars'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                controller.openSettings(context), // Call controller method
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            // Use the controller's data
            child: SpendingChart(
              categories: controller.categories,
              colorMap: controller.colorMap,
            ),
          ),
          const Divider(height: 1),
          Expanded(
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
                return GestureDetector(
                  onTap: () {
                    final categoryTransactions = controller.transactions
                        .where((t) => t.mainCategoryId == category['type'])
                        .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailsScreen(
                          categoryName: category['name'],
                          transactions: categoryTransactions,
                        ),
                      ),
                    );
                  },
                  child: CategoryCard(
                    name: category['name'],
                    allocated: category['allocated'],
                    spent: category['spent'],
                    color:
                        controller.colorMap[category['colorName']] ??
                        Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.openAddTransactionSheet(
          context,
        ), // Call controller method
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
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
            LinearProgressIndicator(
              value: progress,
              minHeight: 8.0,
              backgroundColor: color.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4.0),
            ),
          ],
        ),
      ),
    );
  }
}
