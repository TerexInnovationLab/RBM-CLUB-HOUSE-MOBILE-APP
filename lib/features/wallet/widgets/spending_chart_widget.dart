import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Simple spending chart widget (placeholder).
class SpendingChartWidget extends StatelessWidget {
  /// Creates a spending chart.
  const SpendingChartWidget({super.key, required this.spent, required this.remaining});

  /// Amount spent.
  final double spent;

  /// Amount remaining.
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final total = (spent + remaining).clamp(0.0, double.infinity);
    final spentValue = total == 0 ? 0.0 : spent;
    final remainingValue = total == 0 ? 1.0 : remaining;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: [
                    PieChartSectionData(
                      value: spentValue,
                      color: AppColors.warningOrange,
                      title: 'Spent',
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: remainingValue,
                      color: AppColors.successGreen,
                      title: 'Remaining',
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

