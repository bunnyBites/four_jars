import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';

class SubCategoryListController extends ChangeNotifier {
  final BudgetManager _budgetManager;
  List<SubCategory> _subCategories = [];
  final MainCategoryType _mainCategory;

  List<SubCategory> get subCategories => _subCategories;
  MainCategoryType get mainCategory => _mainCategory;

  String get categoryName =>
      _mainCategory.name[0].toUpperCase() + _mainCategory.name.substring(1);

  SubCategoryListController(this._budgetManager, this._mainCategory) {
    _loadSubCategories();
  }

  void _loadSubCategories() {
    _subCategories = _budgetManager.getSubCategoriesFor(_mainCategory);
    notifyListeners();
  }

  Future<void> addSubCategory(String name) async {
    if (name.trim().isEmpty) return;

    await _budgetManager.addSubCategory(
      name: name.trim(),
      mainCategoryId: _mainCategory,
    );
    _loadSubCategories();
  }

  Future<void> updateSubCategory(
    SubCategory existingSubCategory,
    String newName,
  ) async {
    if (newName.trim().isEmpty) return;

    await _budgetManager.updateSubCategory(
      id: existingSubCategory.id,
      newName: newName.trim(),
      mainCategoryId: _mainCategory,
    );
    _loadSubCategories();
  }

  Future<void> deleteSubCategory(SubCategory subCategory) async {
    // Update local state first
    _subCategories.remove(subCategory);
    notifyListeners();

    // Then delete from database
    await _budgetManager.deleteSubCategory(id: subCategory.id);
  }

  void refreshSubCategories() {
    _loadSubCategories();
  }
}
