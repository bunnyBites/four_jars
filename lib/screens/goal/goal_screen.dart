import 'package:flutter/material.dart';
import 'package:four_jars/models/goal/goal.dart';
import 'package:four_jars/screens/goal/goal_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  void _showAddGoalDialog(BuildContext context, GoalsController controller) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
              autofocus: true,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text;
              final amount = double.tryParse(amountController.text);
              if (name.isNotEmpty && amount != null && amount > 0) {
                controller.addGoal(name: name, targetAmount: amount);
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
    // Use a Consumer to get the controller and rebuild on changes
    return Consumer<GoalsController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Savings Goals')),
          body: controller.goals.isEmpty
              ? const Center(
                  child: Text('No savings goals yet. Tap + to add one!'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.goals.length,
                  itemBuilder: (context, index) {
                    final goal = controller.goals[index];
                    return GoalCard(goal: goal);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddGoalDialog(context, controller),
            tooltip: 'Add Goal',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// reusable card widget for displaying a single goal
class GoalCard extends StatelessWidget {
  final Goal goal;
  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (goal.targetAmount > 0)
        ? goal.savedAmount / goal.targetAmount
        : 0.0;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${currencyFormat.format(goal.savedAmount)} / ${currencyFormat.format(goal.targetAmount)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
