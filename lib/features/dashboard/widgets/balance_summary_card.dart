import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../../shared/widgets/masked_text_widget.dart';
import 'monthly_progress_bar.dart';

/// Balance summary card.
class BalanceSummaryCard extends StatelessWidget {
  /// Creates a balance summary card.
  const BalanceSummaryCard({
    super.key,
    required this.currentBalance,
    required this.monthlyAllocation,
    required this.spentAmount,
    required this.remainingAmount,
    required this.nextReset,
  });

  final double currentBalance;
  final double monthlyAllocation;
  final double spentAmount;
  final double remainingAmount;
  final DateTime nextReset;

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT BALANCE', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          MaskedTextWidget(
            text: CurrencyFormatter.format(currentBalance),
            mask: 'MWK ••••••',
            textStyle: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
            iconColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metric(context, 'MONTHLY ALLOCATION', CurrencyFormatter.format(monthlyAllocation))),
              const SizedBox(width: 12),
              Expanded(
                child: _metric(context, 'AMOUNT SPENT', CurrencyFormatter.format(spentAmount), isDebit: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.warningOrange),
              const SizedBox(width: 8),
              Text(
                'Next reset: ${Formatters.formatDate(nextReset)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MonthlyProgressBar(spentAmount: spentAmount, allocatedAmount: monthlyAllocation),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value, {bool isDebit = false}) {
    final valueColor = isDebit ? AppColors.dangerRed : AppColors.successGreen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: valueColor)),
      ],
    );
  }
}
