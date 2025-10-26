import 'package:flutter/material.dart';
import 'package:four_jars/models/goal/goal.dart';
import 'package:four_jars/screens/goal/goals_controller.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:provider/provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  void _showAddEditGoalDialog(
    BuildContext context,
    GoalsController controller, {
    Goal? existingGoal,
  }) {
    final bool isEditing = existingGoal != null;
    final nameController = TextEditingController(
      text: isEditing ? existingGoal.name : '',
    );
    final amountController = TextEditingController(
      text: isEditing ? existingGoal.targetAmount.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Goal' : 'Add New Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g., New Laptop',
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppTheme.spaceM),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: '₹ ',
                hintText: '0',
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
          FilledButton(
            onPressed: () {
              final name = nameController.text;
              final amount = double.tryParse(amountController.text);
              if (name.isNotEmpty && amount != null && amount > 0) {
                if (isEditing) {
                  controller.updateGoal(
                    goal: existingGoal,
                    newName: name,
                    newTargetAmount: amount,
                  );
                } else {
                  controller.addGoal(name: name, targetAmount: amount);
                }
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
            hintText: '0',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                controller.addFundsToGoal(goalId: goal.id, amount: amount);
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: Colors.white,
            ),
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
          appBar: AppBar(title: const Text('Goals')),
          body: controller.goals.isEmpty
              ? _buildEmptyState(context, controller)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spaceM),
                  itemCount: controller.goals.length,
                  itemBuilder: (context, index) {
                    final goal = controller.goals[index];
                    return Dismissible(
                      key: ValueKey(goal.id),
                      background: _buildDismissibleBackground(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        final goalToDelete = goal;
                        controller.temporaryDeleteGoal(index);

                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                              SnackBar(
                                content: Text('${goalToDelete.name} deleted'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusM,
                                  ),
                                ),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    controller.undoDeleteGoal(
                                      index,
                                      goalToDelete,
                                    );
                                  },
                                ),
                              ),
                            )
                            .closed
                            .then((reason) {
                              if (reason != SnackBarClosedReason.action) {
                                controller.deleteGoal(goalToDelete);
                              }
                            });
                      },
                      child: GestureDetector(
                        onTap: () => _showAddEditGoalDialog(
                          context,
                          controller,
                          existingGoal: goal,
                        ),
                        child: GoalCard(
                          goal: goal,
                          onAddFunds: () {
                            _showAddFundsDialog(context, controller, goal);
                          },
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditGoalDialog(context, controller),
            tooltip: 'Add Goal',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, GoalsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            'No goals yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            'Tap + to create your first goal',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onAddFunds;
  const GoalCard({super.key, required this.goal, required this.onAddFunds});

  @override
  Widget build(BuildContext context) {
    final progress = (goal.targetAmount > 0)
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final bool isCompleted = progress >= 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spaceS),
            Text(
              '₹${goal.savedAmount.toStringAsFixed(0)} / ₹${goal.targetAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spaceM),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.dividerColor,
                color: isCompleted ? Colors.green : AppTheme.lavender,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppTheme.spaceM),
            Align(
              alignment: Alignment.centerRight,
              child: isCompleted
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    )
                  : OutlinedButton(
                      onPressed: onAddFunds,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.sageGray),
                        foregroundColor: AppTheme.textPrimary,
                      ),
                      child: const Text('Add Funds'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
