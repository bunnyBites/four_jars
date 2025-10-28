import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/models/recurring_transaction/recurring_transaction.dart';
import 'package:four_jars/models/sub_category/sub_category.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddEditRecurringTransactionScreen extends StatefulWidget {
  const AddEditRecurringTransactionScreen({super.key});

  @override
  State<AddEditRecurringTransactionScreen> createState() =>
      _AddEditRecurringTransactionScreenState();
}

class _AddEditRecurringTransactionScreenState
    extends State<AddEditRecurringTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  // Form state
  MainCategoryType? _selectedMainCategory;
  String? _selectedSubCategoryId;
  RecurrenceFrequency _selectedFrequency = RecurrenceFrequency.monthly;
  DateTime _selectedDate = DateTime.now();
  List<SubCategory> _availableSubCategories = [];

  @override
  Widget build(BuildContext context) {
    final budgetManager = context.read<BudgetManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Recurring Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceM),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Netflix subscription',
              ),
              validator: (val) =>
                  val!.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: AppTheme.spaceM),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  (double.tryParse(val!) == null || double.parse(val) <= 0)
                  ? 'Please enter a valid amount'
                  : null,
            ),
            const SizedBox(height: AppTheme.spaceM),
            DropdownButtonFormField<MainCategoryType>(
              value: _selectedMainCategory,
              hint: const Text('Select Category'),
              items: MainCategoryType.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.name[0].toUpperCase() + c.name.substring(1),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMainCategory = val;
                  _availableSubCategories = budgetManager.getSubCategoriesFor(
                    val!,
                  );
                  _selectedSubCategoryId = null;
                });
              },
              decoration: const InputDecoration(labelText: 'Main Category'),
              validator: (val) =>
                  val == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: AppTheme.spaceM),
            DropdownButtonFormField<String>(
              value: _selectedSubCategoryId,
              hint: const Text('Select Sub-category'),
              items: _availableSubCategories
                  .map(
                    (sc) =>
                        DropdownMenuItem(value: sc.id, child: Text(sc.name)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedSubCategoryId = val),
              decoration: const InputDecoration(labelText: 'Sub-category'),
              validator: (val) =>
                  val == null ? 'Please select a sub-category' : null,
            ),
            const SizedBox(height: AppTheme.spaceM),
            DropdownButtonFormField<RecurrenceFrequency>(
              value: _selectedFrequency,
              items: RecurrenceFrequency.values
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(
                        f.name[0].toUpperCase() + f.name.substring(1),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedFrequency = val!),
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            const SizedBox(height: AppTheme.spaceM),
            Card(
              child: ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(
                  Icons.calendar_today,
                  color: AppTheme.sageGray,
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: AppTheme.spaceXL),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newRecurringTx = RecurringTransaction(
                      id: const Uuid().v4(),
                      amount: double.parse(_amountController.text),
                      description: _descriptionController.text,
                      mainCategoryId: _selectedMainCategory!,
                      subCategoryId: _selectedSubCategoryId!,
                      frequency: _selectedFrequency,
                      startDate: _selectedDate,
                    );
                    Navigator.pop(context, newRecurringTx);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spaceM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
                child: const Text('Save Recurring Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
