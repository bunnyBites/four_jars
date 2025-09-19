// lib/screens/home/widgets/add_transaction_sheet.dart

import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  MainCategoryType? _selectedCategory = MainCategoryType.wants;

  @override
  Widget build(BuildContext context) {
    // This padding dynamically adjusts based on what's covering the screen (like the keyboard)
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      // 1. WRAP with SingleChildScrollView
      child: Padding(
        // 2. UPDATE the padding to include keyboard space
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

            // --- Form fields are unchanged ---
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
              value: _selectedCategory,
              items: MainCategoryType.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.name[0].toUpperCase() + category.name.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
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
              onPressed: () {
                print('Amount: ${_amountController.text}');
                print('Description: ${_descriptionController.text}');
                print('Category: ${_selectedCategory?.name}');
                Navigator.pop(context);
              },
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
    );
  }
}
