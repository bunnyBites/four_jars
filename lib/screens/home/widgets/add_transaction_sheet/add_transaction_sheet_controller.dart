import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/models/sub_category/sub_category.dart';
import 'package:four_jars/models/transaction/transaction.dart';
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

  Transaction? submitData(BuildContext context) {
    final enteredAmount = double.tryParse(amountController.text);

    // Perform validation checks
    if (enteredAmount == null || enteredAmount <= 0) {
      _showErrorDialog(
        context,
        'Invalid Amount',
        'Please enter a valid amount greater than zero.',
      );
      return null;
    }

    if (selectedMainCategory == null) {
      _showErrorDialog(
        context,
        'No Category Selected',
        'Please select a main category for this transaction.',
      );
      return null;
    }

    if (selectedSubCategoryId == null) {
      _showErrorDialog(
        context,
        'No Sub-category Selected',
        'Please select a sub-category.',
      );

      return null;
    }

    // If all checks pass, create and return the transaction
    final enteredDescription = descriptionController.text.trim().isEmpty
        ? 'Transaction'
        : descriptionController.text;
    return Transaction(
      id: isEditing ? existingTransaction!.id : const Uuid().v4(),
      amount: enteredAmount,
      description: enteredDescription,
      date: isEditing ? existingTransaction!.date : DateTime.now(),
      mainCategoryId: selectedMainCategory!,
      subCategoryId: selectedSubCategoryId!,
    );
  }

  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
