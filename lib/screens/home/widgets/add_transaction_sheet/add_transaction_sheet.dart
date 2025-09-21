import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/screens/home/widgets/add_transaction_sheet/add_transaction_sheet_controller.dart';
import 'package:provider/provider.dart';

class AddTransactionSheet extends StatelessWidget {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddTransactionController>(
      builder: (context, controller, child) {
        final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  controller.isEditing
                      ? 'Edit Transaction'
                      : 'Add New Transaction',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: controller.amountController,
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
                  controller: controller.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<MainCategoryType>(
                  initialValue: controller.selectedMainCategory,
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
                  onChanged: controller.onMainCategoryChanged,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: controller.selectedSubCategoryId,
                  hint: const Text('Select Sub-category'),
                  items: controller.availableSubCategories.map((subCategory) {
                    return DropdownMenuItem(
                      value: subCategory.id,
                      child: Text(subCategory.name),
                    );
                  }).toList(),
                  onChanged: controller.availableSubCategories.isEmpty
                      ? null
                      : controller.onSubCategoryChanged,
                  decoration: const InputDecoration(
                    labelText: 'Sub-category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    final transaction = controller.submitData();
                    if (transaction != null) {
                      // Pop with a result that the calling screen can use
                      Navigator.pop(context, transaction);
                    }
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
      },
    );
  }
}
