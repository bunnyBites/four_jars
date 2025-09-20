// lib/screens/home/widgets/add_transaction_sheet.dart

import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';

class AddTransactionSheet extends StatefulWidget {
  final Future<void> Function(
    double amount,
    String description,
    MainCategoryType category,
  )
  onSave;
  final BudgetManager budgetManager;

  const AddTransactionSheet({
    super.key,
    required this.onSave,
    required this.budgetManager,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  MainCategoryType? _selectedCategory = MainCategoryType.wants;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_clearError);
    _descriptionController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitData() async {
    final enteredAmount = double.tryParse(_amountController.text);
    final enteredDescription = _descriptionController.text;

    if (enteredAmount == null ||
        enteredAmount <= 0 ||
        enteredDescription.trim().isEmpty ||
        _selectedCategory == null) {
      setState(() {
        _errorMessage = 'Please fill all the fields.';
      });
      return;
    }

    final category = widget.budgetManager.categories.firstWhere(
      (cat) => cat['type'] == _selectedCategory,
      orElse: () => {},
    );
    final remaining = category['allocated'] - category['spent'];

    if (enteredAmount > remaining) {
      setState(() {
        _errorMessage =
            'Amount exceeds remaining budget for ${category['name']}.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      try {
        await widget.onSave(
          enteredAmount,
          enteredDescription,
          _selectedCategory!,
        );
      } catch (e) {
        print(e);
        setState(() {
          _errorMessage = 'Failed to save transaction. Please try again.';
        });
        return;
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This padding dynamically adjusts based on what's covering the screen (like the keyboard)
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
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
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- Form fields are unchanged ---
            TextField(
              controller: _amountController,
              enabled: !_isSaving,
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
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MainCategoryType>(
              initialValue: _selectedCategory,
              items: MainCategoryType.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.name[0].toUpperCase() + category.name.substring(1),
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _submitData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.removeListener(_clearError);
    _descriptionController.removeListener(_clearError);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
