import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/goal/goal.dart';
import 'package:uuid/uuid.dart';

class GoalsController extends ChangeNotifier {
  final BudgetManager _budgetManager;

  List<Goal> get goals => _budgetManager.goals;

  GoalsController(this._budgetManager);

  Future<void> addGoal({
    required String name,
    required double targetAmount,
  }) async {
    final newGoal = Goal(
      id: const Uuid().v4(),
      name: name,
      targetAmount: targetAmount,
      creationDate: DateTime.now(),
    );
    await _budgetManager.addGoal(newGoal);
    // reload the data in the manager and notify listeners
    _budgetManager.loadData();
    notifyListeners();
  }

  Future<void> addFundsToGoal({
    required String goalId,
    required double amount,
  }) async {
    final goal = goals.firstWhere((g) => g.id == goalId);
    goal.savedAmount += amount;

    // ensure saved amount doesn't exceed the target
    if (goal.savedAmount > goal.targetAmount) {
      goal.savedAmount = goal.targetAmount;
    }

    await _budgetManager.updateGoal(goal);
    notifyListeners();
  }

  Future<void> updateGoal({
    required Goal goal,
    required String newName,
    required double newTargetAmount,
  }) async {
    goal.name = newName;
    goal.targetAmount = newTargetAmount;
    await _budgetManager.updateGoal(goal);
    notifyListeners();
  }

  Future<void> deleteGoal(Goal goal) async {
    await _budgetManager.deleteGoal(goal.id);
    // reload data to ensure consistency after deletion
    _budgetManager.loadData();
    notifyListeners();
  }

  void temporaryDeleteGoal(int index) {
    goals.removeAt(index);
    notifyListeners();
  }

  void undoDeleteGoal(int index, Goal goalToDelete) {
    goals.insert(index, goalToDelete);
    notifyListeners();
  }
}
