// lib/logic/budget_manager.dart

import 'package:four_jars/constants/app_data.dart';
import 'package:four_jars/models/main_category_type.dart';

class BudgetManager {
  // The manager holds the current state of the categories.
  // It's initialized with a copy of our constant data.
  final List<Map<String, dynamic>> categories = List.from(
    initialCategoriesData,
  );

  // This method contains the pure logic for adding a transaction.
  // It knows how to find a category and update its 'spent' value.
  void addTransaction({
    required double amount,
    required MainCategoryType categoryType,
  }) {
    final categoryIndex = categories.indexWhere(
      (cat) => cat['type'] == categoryType,
    );

    if (categoryIndex != -1) {
      categories[categoryIndex]['spent'] += amount;
    }
  }
}
