import 'package:flutter/material.dart';
import 'package:four_jars/models/goal/goal.dart';
import 'package:four_jars/screens/goal/goals_controller.dart';
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

  void _showAddFundsDialog(
    BuildContext context,
    GoalsController controller,
    Goal goal,
  ) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Funds to "${goal.name}"'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                controller.addFundsToGoal(goalId: goal.id, amount: amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    return GoalCard(
                      goal: goal,
                      onAddFunds: () =>
                          _showAddFundsDialog(context, controller, goal),
                    );
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

@override
class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onAddFunds;
  const GoalCard({super.key, required this.goal, required this.onAddFunds});

  @override
  Widget build(BuildContext context) {
    final progress = (goal.targetAmount > 0)
        ? goal.savedAmount / goal.targetAmount
        : 0.0;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final bool isCompleted = progress >= 1.0;

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
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isCompleted
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : OutlinedButton.icon(
                        onPressed: onAddFunds,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Funds'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
