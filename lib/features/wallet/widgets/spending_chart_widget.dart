import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/rbm_card.dart';

/// Simple weekly spending chart widget (UI-only).
class SpendingChartWidget extends StatelessWidget {
  /// Creates a spending chart.
  const SpendingChartWidget({super.key, required this.spent, required this.remaining});

  /// Amount spent.
  final double spent;

  /// Amount remaining.
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now();
    final label = '${_monthName(month.month)} ${month.year}';

    // We don't currently have week-level data from the backend; distribute spent
    // deterministically so the UI matches the design reference.
    final weights = const [0.28, 0.24, 0.32, 0.16];
    final weeks = weights.map((w) => spent * w).toList(growable: false);
    final maxV = (weeks.isEmpty ? 1.0 : weeks.reduce((a, b) => a > b ? a : b)).clamp(1.0, double.infinity);

    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly spending — $label', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            child: SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < weeks.length; i++) ...[
                    Expanded(
                      child: _WeekBar(
                        label: 'W${i + 1}',
                        value: weeks[i],
                        maxValue: maxV,
                        highlight: i == weeks.length - 1,
                      ),
                    ),
                    if (i != weeks.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][(month - 1).clamp(0, 11)];
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.highlight,
  });

  final String label;
  final double value;
  final double maxValue;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    final barColor = highlight ? AppColors.warningOrange : AppColors.primaryBlue.withValues(alpha: 0.8);
    final textColor = highlight ? AppColors.warningOrange : AppColors.primaryBlue;

    String compact() {
      if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
      return value.toStringAsFixed(0);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          compact(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 3),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: highlight ? AppColors.warningOrange : AppColors.inactive,
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
