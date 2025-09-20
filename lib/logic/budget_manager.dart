import 'package:four_jars/constants/app_data.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class BudgetManager {
  final _budgetBox = Hive.box('budgetBox');
  final _transactionsBox = Hive.box<Transaction>('transactionsBox');
  final _subCategoriesBox = Hive.box<SubCategory>('subCategoriesBox');

  List<Map<String, dynamic>> categories = [];
  List<Transaction> transactions = [];
  List<SubCategory> subCategories = [];

  void loadData() {
    transactions = _transactionsBox.values.toList();
    subCategories = _subCategoriesBox.values.toList();

    // If it's the very first launch, populate sub-categories with defaults
    if (subCategories.isEmpty) {
      subCategories = List.from(initialSubCategories);
      _subCategoriesBox.addAll(subCategories);
    }

    final double totalIncome = _budgetBox.get(
      'totalIncome',
      defaultValue: 100000.0,
    );

    final Map<String, int> percentages = {
      'needs': _budgetBox.get('needsPercentage', defaultValue: 50),
      'wants': _budgetBox.get('wantsPercentage', defaultValue: 30),
      'savings': _budgetBox.get('savingsPercentage', defaultValue: 10),
      'investments': _budgetBox.get('investmentsPercentage', defaultValue: 10),
    };

    // 3. Re-calculate the budget based on the loaded data
    _calculateBudget(totalIncome: totalIncome, percentages: percentages);
  }

  void _calculateBudget({
    required double totalIncome,
    required Map<String, int> percentages,
  }) {
    final List<Map<String, dynamic>> freshCategories = List.from(
      initialCategoriesData,
    );

    for (var category in freshCategories) {
      final type = category['type'] as MainCategoryType;
      final percentage = percentages[type.name] ?? 0;

      category['allocated'] = totalIncome * (percentage / 100);

      final relevantTransactions = transactions.where(
        (t) => t.mainCategoryId == type,
      );
      category['spent'] = relevantTransactions.fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
    }
    categories = freshCategories;
  }

  Future<void> saveSettings({
    required double totalIncome,
    required Map<String, int> percentages,
  }) async {
    await _budgetBox.put('totalIncome', totalIncome);
    await _budgetBox.put('needsPercentage', percentages['needs']);
    await _budgetBox.put('wantsPercentage', percentages['wants']);
    await _budgetBox.put('savingsPercentage', percentages['savings']);
    await _budgetBox.put('investmentsPercentage', percentages['investments']);

    loadData();
  }

  Future<void> _saveTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  void addTransaction({
    required double amount,
    required String description,
    required MainCategoryType categoryType,
    required String subCategoryId,
  }) {
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      description: description,
      date: DateTime.now(),
      mainCategoryId: categoryType,
      subCategoryId: subCategoryId,
    );

    transactions.add(newTransaction);
    _saveTransaction(newTransaction);
    loadData();
  }

  List<SubCategory> getSubCategoriesFor(MainCategoryType mainCategory) {
    return subCategories
        .where((sc) => sc.mainCategoryId == mainCategory)
        .toList();
  }

  Future<void> addSubCategory({
    required String name,
    required MainCategoryType mainCategoryId,
  }) async {
    final newSubCategory = SubCategory(
      id: const Uuid().v4(),
      name: name,
      mainCategoryId: mainCategoryId,
    );
    await _subCategoriesBox.put(newSubCategory.id, newSubCategory);
    loadData();
  }

  Future<void> updateSubCategory({
    required String id,
    required String newName,
    required MainCategoryType mainCategoryId,
  }) async {
    final updatedSubCategory = SubCategory(
      id: id,
      name: newName,
      mainCategoryId: mainCategoryId,
    );
    await _subCategoriesBox.put(id, updatedSubCategory);
    loadData();
  }

  Future<void> deleteSubCategory({required String id}) async {
    await _subCategoriesBox.delete(id);
    loadData();
  }
}
