import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/theme/app_theme.dart';

class SpendingChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Map<String, Color> colorMap;

  const SpendingChart({
    super.key,
    required this.categories,
    required this.colorMap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the total spending to determine percentages
    final totalSpent = categories.fold(0.0, (sum, item) => sum + item['spent']);
    if (totalSpent == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceXL),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spaceM),
              Text(
                'No spending data yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Pie Chart
        AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: categories.map((category) {
                final double percentage =
                    (category['spent'] / totalSpent) * 100;
                final color =
                    AppTheme.categoryColors[(category['type']
                            as MainCategoryType)
                        .index] ??
                    Colors.grey;

                return PieChartSectionData(
                  color: color,
                  value: category['spent'],
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 55,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceL),
        // Legend
        Wrap(
          spacing: AppTheme.spaceM,
          runSpacing: AppTheme.spaceS,
          alignment: WrapAlignment.center,
          children: categories.map((category) {
            final color =
                AppTheme.categoryColors[(category['type'] as MainCategoryType)
                    .index] ??
                Colors.grey;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  category['name'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
