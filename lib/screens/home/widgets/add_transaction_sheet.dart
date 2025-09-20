import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';

class AddTransactionSheet extends StatefulWidget {
  final void Function(
    double amount,
    String description,
    MainCategoryType category,
    String subCategoryId,
  )
  onSave;

  const AddTransactionSheet({super.key, required this.onSave});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  MainCategoryType? _selectedMainCategory;
  String? _selectedSubCategoryId;
  List<SubCategory> _availableSubCategories = [];

  final BudgetManager _budgetManager = BudgetManager();

  @override
  void initState() {
    super.initState();
    _budgetManager.loadData();
  }

  void _onMainCategoryChanged(MainCategoryType? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedMainCategory = newValue;
      _availableSubCategories = _budgetManager.getSubCategoriesFor(newValue);
      _selectedSubCategoryId = null;
    });
  }

  void _submitData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final enteredDescription = _descriptionController.text.trim().isEmpty
        ? 'Transaction'
        : _descriptionController.text;

    if (enteredAmount == null ||
        enteredAmount <= 0 ||
        _selectedMainCategory == null ||
        _selectedSubCategoryId == null) {
      return;
    }

    widget.onSave(
      enteredAmount,
      enteredDescription,
      _selectedMainCategory!,
      _selectedSubCategoryId!,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // This padding dynamically adjusts based on what's covering the screen (like the keyboard)
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: SingleChildScrollView(
          child: Padding(
            // UPDATE the padding to include keyboard space
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add New Transaction',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MainCategoryType>(
                  initialValue: _selectedMainCategory,
                  hint: const Text('Select Category'),
                  items: MainCategoryType.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category.name[0].toUpperCase() +
                            category.name.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: _onMainCategoryChanged,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSubCategoryId,
                  hint: const Text('Select Sub-category'),
                  items: _availableSubCategories.map((subCategory) {
                    return DropdownMenuItem(
                      value: subCategory.id,
                      child: Text(subCategory.name),
                    );
                  }).toList(),
                  onChanged: _availableSubCategories.isEmpty
                      ? null
                      : (newValue) {
                          setState(() {
                            _selectedSubCategoryId = newValue;
                          });
                        },
                  decoration: const InputDecoration(
                    labelText: 'Sub-category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
