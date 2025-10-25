import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/screens/settings/custom_slider_shapes/custom_slider_shapes.dart';
import 'package:four_jars/screens/settings/recurring_transactions/recurring_transactions_controller.dart';
import 'package:four_jars/screens/settings/recurring_transactions/recurring_transactions_screen.dart';
import 'package:four_jars/screens/settings/settings_controller.dart';
import 'package:four_jars/screens/settings/sub_category_list/sub_category_list_screen.dart';
import 'package:four_jars/theme/theme_controller.dart';
import 'package:provider/provider.dart';

class IconWithClickTooltip extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  const IconWithClickTooltip({
    super.key,
    required this.icon,
    required this.tooltip,
  });

  @override
  State<IconWithClickTooltip> createState() => IconWithClickTooltipState();
}

class IconWithClickTooltipState extends State<IconWithClickTooltip> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showTooltip() {
    if (_overlayEntry != null) return;
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy - 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.tooltip,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 2), () => _hideTooltip());
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _showTooltip,
      child: Icon(widget.icon, size: 28),
    );
  }
}

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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allocation Percentages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildPercentageSlider(
              context: context,
              title: 'Needs',
              value: controller.getPercentage(MainCategoryType.needs),
              color: Colors.green,
              onChanged: (val) =>
                  controller.updatePercentages(MainCategoryType.needs, val),
            ),
            _buildPercentageSlider(
              context: context,
              title: 'Wants',
              value: controller.getPercentage(MainCategoryType.wants),
              color: Colors.blue,
              onChanged: (val) =>
                  controller.updatePercentages(MainCategoryType.wants, val),
            ),
            _buildPercentageSlider(
              context: context,
              title: 'Savings',
              value: controller.getPercentage(MainCategoryType.savings),
              color: Colors.purple,
              onChanged: (val) =>
                  controller.updatePercentages(MainCategoryType.savings, val),
            ),
            _buildPercentageSlider(
              context: context,
              title: 'Investments',
              value: controller.getPercentage(MainCategoryType.investments),
              color: Colors.orange,
              onChanged: (val) => controller.updatePercentages(
                MainCategoryType.investments,
                val,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoriesSection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        child: Column(
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
        ),
      ),
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
            builder: (_) => ChangeNotifierProvider(
              create: (ctx) =>
                  RecurringTransactionsController(ctx.read<BudgetManager>()),
              child: const RecurringTransactionsScreen(),
            ),
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

  // helper widget for slider
  Widget _buildPercentageSlider({
    required BuildContext context,
    required String title,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    final Map<String, IconData> titleIcons = {
      'Needs': Icons.home,
      'Wants': Icons.shopping_cart,
      'Savings': Icons.savings,
      'Investments': Icons.trending_up,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconWithClickTooltip(
            icon: titleIcons[title] ?? Icons.tune,
            tooltip: title,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: SliderTheme(
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
                label: '${value.round()}%',
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 6,
                  backgroundColor: color.withAlpha((255 * 0.18).round()),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Padding(
                padding: value == 100
                    ? const EdgeInsets.only(
                        left: 2.0,
                        right: 2.0,
                        top: 4.0,
                        bottom: 4.0,
                      )
                    : const EdgeInsets.all(4.0),
                child: Text(
                  '${value.round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
