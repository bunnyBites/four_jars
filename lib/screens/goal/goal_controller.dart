import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/goal/goal.dart';
import 'package:uuid/uuid.dart';

class GoalsController extends ChangeNotifier {
  final BudgetManager _budgetManager;

  List<Goal> get goals => _budgetManager.goals;

  GoalsController(this._budgetManager) {
    // The BudgetManager passed in is already loaded
  }

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
}
