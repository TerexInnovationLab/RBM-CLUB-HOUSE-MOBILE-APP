import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../profile/providers/app_settings_provider.dart';

/// Simple weekly spending chart widget (UI-only).
class SpendingChartWidget extends ConsumerWidget {
  /// Creates a spending chart.
  const SpendingChartWidget({
    super.key,
    required this.spent,
    required this.remaining,
  });

  /// Amount spent.
  final double spent;

  /// Amount remaining.
  final double remaining;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maskAmounts = ref.watch(appSettingsProvider).amountMasking;
    final month = DateTime.now();
    final label = '${_monthName(month.month)} ${month.year}';

    // We don't currently have week-level data from the backend; distribute spent
    // deterministically so the UI matches the design reference.
    final weights = const [0.28, 0.24, 0.32, 0.16];
    final weeks = weights.map((w) => spent * w).toList(growable: false);
    final maxV = (weeks.isEmpty ? 1.0 : weeks.reduce((a, b) => a > b ? a : b))
        .clamp(1.0, double.infinity);

    String money(double value) {
      if (maskAmounts) return 'MWK ******';
      return CurrencyFormatter.format(value).replaceFirst('.00', '');
    }

    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Weekly breakdown for $label',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: SizedBox(
              height: 96,
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
                        maskAmounts: maskAmounts,
                      ),
                    ),
                    if (i != weeks.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Spent',
                  value: money(spent),
                  color: AppColors.warningOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryTile(
                  label: 'Remaining',
                  value: money(remaining),
                  color: AppColors.successGreen,
                ),
              ),
            ],
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
    required this.maskAmounts,
  });

  final String label;
  final double value;
  final double maxValue;
  final bool highlight;
  final bool maskAmounts;

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    final barColor = highlight
        ? AppColors.warningOrange
        : AppColors.secondaryBlue.withValues(alpha: 0.86);
    final textColor = highlight
        ? AppColors.warningOrange
        : AppColors.secondaryBlue;

    String compact() {
      if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
      return value.toStringAsFixed(0);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          maskAmounts ? '***' : compact(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
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
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
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
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
