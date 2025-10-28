import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/screens/main/widgets/add_transaction_sheet/add_transaction_sheet_controller.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AddTransactionSheet extends StatelessWidget {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddTransactionController>(
      builder: (context, controller, child) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXL),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceL,
                    AppTheme.spaceS,
                    AppTheme.spaceL,
                    AppTheme.spaceL,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitle(context, controller),
                      const SizedBox(height: AppTheme.spaceL),
                      _buildAmountField(controller),
                      const SizedBox(height: AppTheme.spaceM),
                      _buildDescriptionField(controller),
                      const SizedBox(height: AppTheme.spaceM),
                      _buildMainCategoryDropdown(controller),
                      const SizedBox(height: AppTheme.spaceM),
                      _buildSubCategoryDropdown(controller),
                      const SizedBox(height: AppTheme.spaceL),
                      _buildSaveButton(context, controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spaceM),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    AddTransactionController controller,
  ) {
    return Text(
      controller.isEditing ? 'Edit Transaction' : 'Add Transaction',
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAmountField(AddTransactionController controller) {
    return TextField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autofocus: !controller.isEditing,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '₹ ',
        hintText: '0',
      ),
    );
  }

  Widget _buildDescriptionField(AddTransactionController controller) {
    return TextField(
      controller: controller.descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'e.g., Grocery shopping',
      ),
    );
  }

  Widget _buildMainCategoryDropdown(AddTransactionController controller) {
    return DropdownButtonFormField<MainCategoryType>(
      value: controller.selectedMainCategory,
      hint: const Text('Select Category'),
      items: MainCategoryType.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(
            category.name[0].toUpperCase() + category.name.substring(1),
          ),
        );
      }).toList(),
      onChanged: controller.isEditing ? null : controller.onMainCategoryChanged,
      decoration: InputDecoration(
        labelText: 'Main Category',
        enabled: !controller.isEditing,
      ),
    );
  }

  Widget _buildSubCategoryDropdown(AddTransactionController controller) {
    return DropdownButtonFormField<String>(
      value: controller.selectedSubCategoryId,
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
      decoration: const InputDecoration(labelText: 'Sub-category'),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddTransactionController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          final transaction = controller.submitData(context);
          if (transaction != null) {
            Navigator.pop(context, transaction);
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.textPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        child: Text(
          controller.isEditing ? 'Update Transaction' : 'Add Transaction',
        ),
      ),
    );
  }
}
