import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:uuid/uuid.dart';

class AddTransactionController extends ChangeNotifier {
  final BudgetManager _budgetManager = BudgetManager();
  final Transaction? existingTransaction;

  // Form state is now managed here
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  MainCategoryType? selectedMainCategory;
  String? selectedSubCategoryId;
  List<SubCategory> availableSubCategories = [];

  bool get isEditing => existingTransaction != null;

  AddTransactionController({this.existingTransaction}) {
    _initialize();
  }

  void _initialize() {
    _budgetManager.loadData();
    if (isEditing) {
      amountController.text = existingTransaction!.amount.toString();
      descriptionController.text = existingTransaction!.description;
      selectedMainCategory = existingTransaction!.mainCategoryId;
      availableSubCategories = _budgetManager.getSubCategoriesFor(
        selectedMainCategory!,
      );
      selectedSubCategoryId = existingTransaction!.subCategoryId;
    }
  }

  void onMainCategoryChanged(MainCategoryType? newValue) {
    if (newValue == null || newValue == selectedMainCategory) return;

    selectedMainCategory = newValue;
    availableSubCategories = _budgetManager.getSubCategoriesFor(newValue);
    if (availableSubCategories.length == 1) {
      selectedSubCategoryId = availableSubCategories.first.id;
    } else {
      selectedSubCategoryId = null; // Reset sub-category selection
    }

    notifyListeners();
  }

  void onSubCategoryChanged(String? newValue) {
    selectedSubCategoryId = newValue;
    notifyListeners();
  }

  Transaction? submitData() {
    final enteredAmount = double.tryParse(amountController.text);
    final enteredDescription = descriptionController.text.trim().isEmpty
        ? 'Transaction'
        : descriptionController.text;

    if (enteredAmount == null ||
        enteredAmount <= 0 ||
        selectedMainCategory == null ||
        selectedSubCategoryId == null) {
      return null; // Return null if validation fails
    }

    return Transaction(
      id: isEditing ? existingTransaction!.id : const Uuid().v4(),
      amount: enteredAmount,
      description: enteredDescription,
      date: isEditing ? existingTransaction!.date : DateTime.now(),
      mainCategoryId: selectedMainCategory!,
      subCategoryId: selectedSubCategoryId!,
    );
  }
}
