import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';

class BarData {
  final String subCategoryName;
  final double amount;
  final String subCategoryId;

  BarData(this.subCategoryName, this.amount, this.subCategoryId);
}

class ReportsController extends ChangeNotifier {
  final BudgetManager _budgetManager;

  // State for the controller
  DateTime _selectedMonth = DateTime.now();
  List<BarData> _monthlySpending = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  DateTime get selectedMonth => _selectedMonth;
  List<BarData> get monthlySpending => _monthlySpending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReportsController(this._budgetManager) {
    generateReport();
  }

  /// Navigate to the previous month
  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    generateReport();
  }

  /// Navigate to the next month
  void goToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);

    // Don't allow navigation beyond current month
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      _selectedMonth = nextMonth;
      generateReport();
    }
  }

  /// Set a specific month
  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    generateReport();
  }

  /// Check if we can navigate to next month
  bool canGoToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    return nextMonth.isBefore(DateTime(now.year, now.month + 1));
  }

  /// Generate the spending report for the selected month
  void generateReport() {
    _setLoading(true);
    _clearError();

    try {
      // Get all transactions from the manager
      final allTransactions = _budgetManager.transactions;

      // Filter for transactions in the currently selected month
      final monthTransactions = allTransactions.where((t) {
        return t.date.month == _selectedMonth.month &&
            t.date.year == _selectedMonth.year;
      }).toList();

      // Group transactions by sub-category ID and sum their amounts
      final Map<String, double> spendingBySubCategory = {};
      for (var transaction in monthTransactions) {
        final subCategoryId = transaction.subCategoryId;
        spendingBySubCategory.update(
          subCategoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }

      // Convert the grouped data into our BarData class for the UI
      _monthlySpending = spendingBySubCategory.entries.map((entry) {
        final subCategoryName = _budgetManager.getSubCategoryNameById(
          entry.key,
        );
        return BarData(subCategoryName, entry.value, entry.key);
      }).toList();

      // Sort the list so the highest spending is first
      _monthlySpending.sort((a, b) => b.amount.compareTo(a.amount));

      // Limit to top 10 categories for better chart readability
      if (_monthlySpending.length > 10) {
        final topCategories = _monthlySpending.take(9).toList();
        final othersAmount = _monthlySpending
            .skip(9)
            .fold(0.0, (sum, item) => sum + item.amount);

        if (othersAmount > 0) {
          topCategories.add(BarData('Others', othersAmount, 'others'));
        }

        _monthlySpending = topCategories;
      }
    } catch (e) {
      _setError('Failed to generate report: ${e.toString()}');
      _monthlySpending = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Get total spending for the selected month
  double getTotalSpending() {
    return _monthlySpending.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Get the category with highest spending
  BarData? getTopSpendingCategory() {
    return _monthlySpending.isNotEmpty ? _monthlySpending.first : null;
  }

  /// Get spending for a specific category in the selected month
  double getSpendingForCategory(String subCategoryId) {
    final categoryData = _monthlySpending.firstWhere(
      (item) => item.subCategoryId == subCategoryId,
      orElse: () => BarData('', 0.0, ''),
    );
    return categoryData.amount;
  }

  /// Check if the selected month has any spending data
  bool hasSpendingData() {
    return _monthlySpending.isNotEmpty;
  }

  /// Get month name in readable format
  String getMonthName() {
    final monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[_selectedMonth.month]} ${_selectedMonth.year}';
  }

  /// Refresh the report data
  void refreshReport() {
    generateReport();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
