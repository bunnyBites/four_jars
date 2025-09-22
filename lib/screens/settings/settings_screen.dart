import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/screens/settings/sub_category_list/sub_category_list_screen.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _incomeController = TextEditingController();
  final BudgetManager _budgetManager = BudgetManager();

  // State variables for our sliders
  late double _needsPerc;
  late double _wantsPerc;
  late double _savingsPerc;
  late double _investmentsPerc;

  @override
  void initState() {
    super.initState();
    // Load existing settings to initialize the form
    final box = Hive.box('budgetBox');
    final currentIncome = box.get('totalIncome', defaultValue: 100000.0);
    _incomeController.text = currentIncome.toStringAsFixed(0);

    _needsPerc = box.get('needsPercentage', defaultValue: 50).toDouble();
    _wantsPerc = box.get('wantsPercentage', defaultValue: 30).toDouble();
    _savingsPerc = box.get('savingsPercentage', defaultValue: 10).toDouble();
    _investmentsPerc = box
        .get('investmentsPercentage', defaultValue: 10)
        .toDouble();
  }

  // Logic to adjust sliders while keeping the total at 100%
  void _updatePercentages(MainCategoryType changedCategory, double value) {
    setState(() {
      double total = 100.0;
      // Temporarily store current values
      double needs = _needsPerc;
      double wants = _wantsPerc;
      double savings = _savingsPerc;
      double investments = _investmentsPerc;

      // Update the slider that was changed
      switch (changedCategory) {
        case MainCategoryType.needs:
          needs = value;
          break;
        case MainCategoryType.wants:
          wants = value;
          break;
        case MainCategoryType.savings:
          savings = value;
          break;
        case MainCategoryType.investments:
          investments = value;
          break;
      }

      // Distribute the remaining percentage among the other sliders
      double remaining = total - value;
      double otherSlidersTotal = 0;
      if (changedCategory != MainCategoryType.needs) otherSlidersTotal += needs;
      if (changedCategory != MainCategoryType.wants) otherSlidersTotal += wants;
      if (changedCategory != MainCategoryType.savings) {
        otherSlidersTotal += savings;
      }
      if (changedCategory != MainCategoryType.investments) {
        otherSlidersTotal += investments;
      }

      if (otherSlidersTotal > 0) {
        double factor = remaining / otherSlidersTotal;
        if (changedCategory != MainCategoryType.needs) needs *= factor;
        if (changedCategory != MainCategoryType.wants) wants *= factor;
        if (changedCategory != MainCategoryType.savings) savings *= factor;
        if (changedCategory != MainCategoryType.investments) {
          investments *= factor;
        }
      }

      // Assign the final, rounded values
      _needsPerc = needs.roundToDouble();
      _wantsPerc = wants.roundToDouble();
      _savingsPerc = savings.roundToDouble();
      _investmentsPerc = investments.roundToDouble();

      // Final check to ensure it sums to 100 due to rounding
      double finalTotal =
          _needsPerc + _wantsPerc + _savingsPerc + _investmentsPerc;
      if (finalTotal != 100) {
        _needsPerc += (100 - finalTotal);
      }
    });
  }

  void _saveSettings() {
    final income = double.tryParse(_incomeController.text);
    if (income == null) return;

    final percentages = {
      'needs': _needsPerc.toInt(),
      'wants': _wantsPerc.toInt(),
      'savings': _savingsPerc.toInt(),
      'investments': _investmentsPerc.toInt(),
    };

    _budgetManager.saveSettings(totalIncome: income, percentages: percentages);
    Navigator.pop(context);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Budget Settings')),
      // Use a ListView instead of a Column to ensure it's always scrollable
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'My Total Monthly Income',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Allocation Percentages',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          _buildPercentageSlider(
            title: 'Needs',
            value: _needsPerc,
            color: Colors.green,
            onChanged: (val) => _updatePercentages(MainCategoryType.needs, val),
          ),
          _buildPercentageSlider(
            title: 'Wants',
            value: _wantsPerc,
            color: Colors.blue,
            onChanged: (val) => _updatePercentages(MainCategoryType.wants, val),
          ),
          _buildPercentageSlider(
            title: 'Savings',
            value: _savingsPerc,
            color: Colors.purple,
            onChanged: (val) =>
                _updatePercentages(MainCategoryType.savings, val),
          ),
          _buildPercentageSlider(
            title: 'Investments',
            value: _investmentsPerc,
            color: Colors.orange,
            onChanged: (val) =>
                _updatePercentages(MainCategoryType.investments, val),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Manage Sub-categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...MainCategoryType.values.map((category) {
            return ListTile(
              title: Text(
                category.name[0].toUpperCase() + category.name.substring(1),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SubCategoryListScreen(mainCategory: category),
                  ),
                );
              },
            );
          }).toList(),
          const SizedBox(height: 32), // Replaced Spacer with a fixed SizedBox
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  // Helper widget to avoid repeating code for each slider
  Widget _buildPercentageSlider({
    required String title,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${value.round()}%',
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
        Text(
          '${value.round()}%',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
