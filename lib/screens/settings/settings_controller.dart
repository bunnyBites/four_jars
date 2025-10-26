import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:hive/hive.dart';

class SettingsController extends ChangeNotifier {
  final _incomeController = TextEditingController();
  final BudgetManager _budgetManager = BudgetManager();

  // state variables for our sliders
  late double _needsPerc;
  late double _wantsPerc;
  late double _savingsPerc;
  late double _investmentsPerc;

  TextEditingController get incomeController => _incomeController;

  double getPercentage(MainCategoryType categoryType) {
    switch (categoryType) {
      case MainCategoryType.needs:
        return _needsPerc;
      case MainCategoryType.wants:
        return _wantsPerc;
      case MainCategoryType.savings:
        return _savingsPerc;
      case MainCategoryType.investments:
        return _investmentsPerc;
    }
  }

  // Individual getters for convenience
  double get needsPercentage => _needsPerc;
  double get wantsPercentage => _wantsPerc;
  double get savingsPercentage => _savingsPerc;
  double get investmentsPercentage => _investmentsPerc;

  SettingsController() {
    // Load existing settings to initialize the form
    final box = Hive.box('budgetBox');
    final currentIncome = box.get('totalIncome', defaultValue: 100000.0);
    _incomeController.text = currentIncome.toStringAsFixed(0);

    _needsPerc = box.get('needsPercentage', defaultValue: 50).toDouble();
    _wantsPerc = box.get('wantsPercentage', defaultValue: 30).toDouble();
    _savingsPerc = box.get('savingsPercentage', defaultValue: 10).toDouble();
    _investmentsPerc = box
        .get('investmentsPercentage', defaultValue: 10)
        .toDouble();

    // Listen to income changes and auto-save
    _incomeController.addListener(_autoSaveIncome);
  }

  void _autoSaveIncome() {
    final income = double.tryParse(_incomeController.text);
    if (income != null && income > 0) {
      _saveIncomeOnly(income);
    }
  }

  void _saveIncomeOnly(double income) async {
    final box = Hive.box('budgetBox');
    await box.put('totalIncome', income);
    _budgetManager.loadData();
  }

  @override
  void dispose() {
    _incomeController.removeListener(_autoSaveIncome);
    _incomeController.dispose();
    super.dispose();
  }

  // logic to adjust sliders while keeping the total at 100%
  void updatePercentages(MainCategoryType changedCategory, double value) {
    double total = 100.0;
    // temporarily store current values
    double needs = _needsPerc;
    double wants = _wantsPerc;
    double savings = _savingsPerc;
    double investments = _investmentsPerc;

    // update the slider that was changed
    switch (changedCategory) {
      case MainCategoryType.needs:
        needs = value;
        break;
      case MainCategoryType.wants:
        wants = value;
        break;
      case MainCategoryType.savings:
        savings = value;
        break;
      case MainCategoryType.investments:
        investments = value;
        break;
    }

    // Distribute the remaining percentage among the other sliders
    double remaining = total - value;
    double otherSlidersTotal = 0;
    if (changedCategory != MainCategoryType.needs) otherSlidersTotal += needs;
    if (changedCategory != MainCategoryType.wants) otherSlidersTotal += wants;
    if (changedCategory != MainCategoryType.savings) {
      otherSlidersTotal += savings;
    }
    if (changedCategory != MainCategoryType.investments) {
      otherSlidersTotal += investments;
    }

    if (otherSlidersTotal > 0) {
      double factor = remaining / otherSlidersTotal;
      if (changedCategory != MainCategoryType.needs) needs *= factor;
      if (changedCategory != MainCategoryType.wants) wants *= factor;
      if (changedCategory != MainCategoryType.savings) savings *= factor;
      if (changedCategory != MainCategoryType.investments) {
        investments *= factor;
      }
    }

    // assign the final, rounded values
    _needsPerc = needs.roundToDouble();
    _wantsPerc = wants.roundToDouble();
    _savingsPerc = savings.roundToDouble();
    _investmentsPerc = investments.roundToDouble();

    // final check to ensure it sums to 100 due to rounding
    double finalTotal =
        _needsPerc + _wantsPerc + _savingsPerc + _investmentsPerc;
    if (finalTotal != 100) {
      _needsPerc += (100 - finalTotal);
    }

    notifyListeners();

    // Auto-save the percentages
    _autoSavePercentages();
  }

  void _autoSavePercentages() async {
    final percentages = {
      'needs': _needsPerc.toInt(),
      'wants': _wantsPerc.toInt(),
      'savings': _savingsPerc.toInt(),
      'investments': _investmentsPerc.toInt(),
    };

    final box = Hive.box('budgetBox');
    await box.put('needsPercentage', percentages['needs']);
    await box.put('wantsPercentage', percentages['wants']);
    await box.put('savingsPercentage', percentages['savings']);
    await box.put('investmentsPercentage', percentages['investments']);
    _budgetManager.loadData();
  }

  void saveSettings() {
    final income = double.tryParse(_incomeController.text);
    if (income == null) return;

    final percentages = {
      'needs': _needsPerc.toInt(),
      'wants': _wantsPerc.toInt(),
      'savings': _savingsPerc.toInt(),
      'investments': _investmentsPerc.toInt(),
    };

    _budgetManager.saveSettings(totalIncome: income, percentages: percentages);
  }
}
