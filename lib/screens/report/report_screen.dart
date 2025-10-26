import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:four_jars/screens/report/report_screen_controller.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReportsController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthSelector(context, controller),
            controller.isLoading
                ? _buildLoadingState(context)
                : controller.error != null
                ? _buildErrorState(context, controller)
                : controller.monthlySpending.isEmpty
                ? _buildEmptyState(context)
                : Column(
                    children: [
                      _buildChart(context, controller),
                      const SizedBox(height: AppTheme.spaceM),
                      _buildSummaryCard(context, controller),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    ReportsController controller,
  ) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spaceM),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceS,
          vertical: AppTheme.spaceM,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => controller.goToPreviousMonth(),
            ),
            Text(
              DateFormat('MMMM yyyy').format(controller.selectedMonth),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: controller.canGoToNextMonth()
                  ? () => controller.goToNextMonth()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceM),
      height: 300,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(BuildContext context, ReportsController controller) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spaceM),
              Text(
                'Error loading data',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spaceM),
              FilledButton(
                onPressed: () => controller.refreshReport(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL * 2),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 64,
                color: AppTheme.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppTheme.spaceM),
              Text(
                'No data for this month',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, ReportsController controller) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spaceL),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      controller.monthlySpending
                          .map((d) => d.amount)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppTheme.textPrimary,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex < controller.monthlySpending.length) {
                          final data = controller.monthlySpending[groupIndex];
                          return BarTooltipItem(
                            '${data.subCategoryName}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '₹${data.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            '₹${(value / 1000).toStringAsFixed(0)}k',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() <
                              controller.monthlySpending.length) {
                            final text = controller
                                .monthlySpending[value.toInt()]
                                .subCategoryName;
                            final displayText = text.length > 8
                                ? '${text.substring(0, 8)}...'
                                : text;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                displayText,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: controller.monthlySpending
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.amount,
                              color: _getBarColor(entry.key),
                              width: 32,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      AppTheme.peachCream,
      AppTheme.skyBlue,
      AppTheme.lavender,
      AppTheme.lightMint,
    ];
    return colors[index % colors.length];
  }

  Widget _buildSummaryCard(BuildContext context, ReportsController controller) {
    final totalSpent = controller.monthlySpending.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final highestCategory = controller.monthlySpending.first;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  'Total Spent',
                  '₹${totalSpent.toStringAsFixed(0)}',
                  Icons.account_balance_wallet_outlined,
                ),
                _buildSummaryItem(
                  context,
                  'Top Category',
                  highestCategory.subCategoryName,
                  Icons.trending_up,
                ),
                _buildSummaryItem(
                  context,
                  'Categories',
                  '${controller.monthlySpending.length}',
                  Icons.category_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.sageGray, size: 28),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
