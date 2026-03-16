import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Monthly usage progress bar with color logic.
class MonthlyProgressBar extends StatelessWidget {
  /// Creates a monthly progress bar.
  const MonthlyProgressBar({
    super.key,
    required this.spentAmount,
    required this.allocatedAmount,
  });

  /// Amount spent.
  final double spentAmount;

  /// Allocated amount.
  final double allocatedAmount;

  @override
  Widget build(BuildContext context) {
    final used = allocatedAmount <= 0 ? 0.0 : (spentAmount / allocatedAmount).clamp(0.0, 1.0);
    final remainingRatio = 1.0 - used;

    Color color;
    if (remainingRatio > 0.5) {
      color = AppColors.successGreen;
    } else if (remainingRatio > 0.2) {
      color = AppColors.warningOrange;
    } else {
      color = AppColors.dangerRed;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly usage',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${(used * 100).toStringAsFixed(1)}% used',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warningOrange),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: used,
          color: color,
          backgroundColor: AppColors.borderGray.withAlpha(89),
          minHeight: 8,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}
