import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/screens/settings/recurring_transactions/recurring_transactions_screen.dart';
import 'package:four_jars/screens/settings/settings_controller.dart';
import 'package:four_jars/screens/settings/sub_category_list/sub_category_list_screen.dart';
import 'package:four_jars/theme/theme_controller.dart';
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
      appBar: _buildAppBar(),
      body: _buildBody(context, controller),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(title: const Text('My Budget Settings'));
  }

  Widget _buildBody(BuildContext context, SettingsController controller) {
    final themeController = Provider.of<ThemeController>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildIncomeField(controller),
        const SizedBox(height: 24),
        _buildAllocationSection(context, controller),
        const SizedBox(height: 16),
        _buildThemeSwitcher(context, themeController),
        const Divider(),
        const SizedBox(height: 16),
        _buildSubCategoriesSection(context),
        const Divider(),
        _buildRecurringTransactions(context),
        const SizedBox(height: 32),
        _buildSaveButton(controller),
      ],
    );
  }

  Widget _buildThemeSwitcher(
    BuildContext context,
    ThemeController themeController,
  ) {
    return (Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.wb_sunny),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.nightlight_round),
            ),
          ],
          selected: {themeController.themeMode},
          onSelectionChanged: (newSelection) {
            themeController.setThemeMode(newSelection.first);
          },
        ),
      ],
    ));
  }

  Widget _buildIncomeField(SettingsController controller) {
    return TextField(
      controller: controller.incomeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'My Total Monthly Income',
        prefixText: '₹ ',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAllocationSection(
    BuildContext context,
    SettingsController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildSubCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Sub-categories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...MainCategoryType.values.map(
          (category) => _buildCategoryListTile(context, category),
        ),
      ],
    );
  }

  Widget _buildCategoryListTile(
    BuildContext context,
    MainCategoryType category,
  ) {
    return ListTile(
      title: Text(category.name[0].toUpperCase() + category.name.substring(1)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoryListScreen(mainCategory: category),
          ),
        );
      },
    );
  }

  Widget _buildRecurringTransactions(BuildContext context) {
    return ListTile(
      title: const Text('Recurring Transactions'),
      subtitle: const Text('Manage automatic monthly bills & subscriptions'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RecurringTransactionsScreen(),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(SettingsController controller) {
    return Builder(
      builder: (context) => ElevatedButton(
        onPressed: () {
          controller.saveSettings();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Save Settings'),
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
