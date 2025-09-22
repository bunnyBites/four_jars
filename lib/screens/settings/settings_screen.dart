import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/screens/settings/settings_controller.dart';
import 'package:four_jars/screens/settings/sub_category_list/sub_category_list_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsController(),
      child: const _SettingsScreenState(),
    );
  }
}

class _SettingsScreenState extends StatelessWidget {
  const _SettingsScreenState();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Budget Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: controller.incomeController,
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
            value: controller.getPercentage(MainCategoryType.needs),
            color: Colors.green,
            onChanged: (val) =>
                controller.updatePercentages(MainCategoryType.needs, val),
          ),
          _buildPercentageSlider(
            title: 'Wants',
            value: controller.getPercentage(MainCategoryType.wants),
            color: Colors.blue,
            onChanged: (val) =>
                controller.updatePercentages(MainCategoryType.wants, val),
          ),
          _buildPercentageSlider(
            title: 'Savings',
            value: controller.getPercentage(MainCategoryType.savings),
            color: Colors.purple,
            onChanged: (val) =>
                controller.updatePercentages(MainCategoryType.savings, val),
          ),
          _buildPercentageSlider(
            title: 'Investments',
            value: controller.getPercentage(MainCategoryType.investments),
            color: Colors.orange,
            onChanged: (val) =>
                controller.updatePercentages(MainCategoryType.investments, val),
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
          }),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              controller.saveSettings();
              Navigator.pop(context);
            },
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

  // Helper widget for slider
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
