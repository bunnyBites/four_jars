import 'package:four_jars/constants/app_data.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetManager {
  // Get our opened Hive box
  final _budgetBox = Hive.box('budgetBox');
  List<Map<String, dynamic>> categories = [];

  // NEW: Load data from the database
  void loadData() {
    // Check if the box has data (i.e., not the first time opening the app)
    final savedData = _budgetBox.get('CATEGORIES');

    if (savedData != null) {
      // If there is saved data, load it
      categories = List<Map<String, dynamic>>.from(
        savedData.map((item) => Map<String, dynamic>.from(item)),
      );
    } else {
      // Otherwise, it's the first launch, so load the initial constant data
      categories = List.from(initialCategoriesData);
    }
  }

  // NEW: Save data to the database
  Future<void> _saveData() async {
    await _budgetBox.put('CATEGORIES', categories);
  }

  // UPDATED: The addTransaction method now saves its changes
  Future<void> addTransaction({
    required double amount,
    required MainCategoryType categoryType,
  }) async {
    final categoryIndex = categories.indexWhere(
      (cat) => cat['type'] == categoryType,
    );

    if (categoryIndex != -1) {
      categories[categoryIndex]['spent'] += amount;
      await _saveData(); // Save the updated list to Hive
    }
  }
}
