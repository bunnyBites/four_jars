import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/screens/settings/custom_slider_shapes/custom_slider_shapes.dart';
import 'package:four_jars/screens/settings/recurring_transactions/recurring_transactions_controller.dart';
import 'package:four_jars/screens/settings/recurring_transactions/recurring_transactions_screen.dart';
import 'package:four_jars/screens/settings/settings_controller.dart';
import 'package:four_jars/screens/settings/sub_category_list/sub_category_management_screen.dart';
import 'package:four_jars/theme/app_theme.dart';
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
    return AppBar(title: const Text('Settings'));
  }

  Widget _buildBody(BuildContext context, SettingsController controller) {
    final themeController = Provider.of<ThemeController>(context);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      children: [
        _buildThemeCard(context, themeController),
        const SizedBox(height: AppTheme.spaceS),
        _buildIncomeCard(context, controller),
        const SizedBox(height: AppTheme.spaceS),
        _buildAllocationCard(context, controller),
        const SizedBox(height: AppTheme.spaceS),
        _buildNavigationCard(context),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.spaceM),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ],
              selected: {themeController.themeMode},
              onSelectionChanged: (newSelection) {
                themeController.setThemeMode(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Income',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceM),
            TextField(
              controller: controller.incomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationCard(
    BuildContext context,
    SettingsController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Allocation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceM),
            _buildAllocationSlider(
              context: context,
              controller: controller,
              title: 'Needs',
              categoryType: MainCategoryType.needs,
              color: AppTheme.peachCream,
            ),
            _buildAllocationSlider(
              context: context,
              controller: controller,
              title: 'Wants',
              categoryType: MainCategoryType.wants,
              color: AppTheme.skyBlue,
            ),
            _buildAllocationSlider(
              context: context,
              controller: controller,
              title: 'Savings',
              categoryType: MainCategoryType.savings,
              color: AppTheme.lavender,
            ),
            _buildAllocationSlider(
              context: context,
              controller: controller,
              title: 'Investments',
              categoryType: MainCategoryType.investments,
              color: AppTheme.lightMint,
            ),
            const Divider(height: AppTheme.spaceL),
            Text(
              'Total: ${(controller.getPercentage(MainCategoryType.needs) + controller.getPercentage(MainCategoryType.wants) + controller.getPercentage(MainCategoryType.savings) + controller.getPercentage(MainCategoryType.investments)).toStringAsFixed(0)}%',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationSlider({
    required BuildContext context,
    required SettingsController controller,
    required String title,
    required MainCategoryType categoryType,
    required Color color,
  }) {
    final value = controller.getPercentage(categoryType);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${value.round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceS),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 20,
              trackShape: const PillSliderTrackShape(),
              thumbShape: const VerticalBarSliderThumbShape(
                width: 4,
                height: 32,
              ),
              overlayShape: const VerticalBarSliderOverlayShape(
                width: 8,
                height: 40,
              ),
              activeTrackColor: color,
              inactiveTrackColor: color.withAlpha((255 * 0.18).round()),
              thumbColor: color,
              overlayColor: color.withAlpha((255 * 0.10).round()),
              valueIndicatorColor: color,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (val) =>
                  controller.updatePercentages(categoryType, val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Manage Sub-Categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubCategoryManagementScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Recurring Transactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (ctx) => RecurringTransactionsController(
                      ctx.read<BudgetManager>(),
                    ),
                    child: const RecurringTransactionsScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
