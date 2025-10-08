import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
      return const Center(child: Text('No spending data yet.'));
    }

    return AspectRatio(
      aspectRatio: 1.5, // Make it wider than it is tall
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: categories.map((category) {
            final double percentage = (category['spent'] / totalSpent) * 100;
            final color = colorMap[category['colorName']] ?? Colors.grey;

            return PieChartSectionData(
              color: color,
              value: category['spent'],
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
