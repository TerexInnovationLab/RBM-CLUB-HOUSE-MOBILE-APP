import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Balance', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            MaskedTextWidget(
              text: CurrencyFormatter.format(currentBalance),
              mask: 'MWK ••••••',
              textStyle: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
              iconColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            _row('Monthly Allocation', CurrencyFormatter.format(monthlyAllocation)),
            _row('Amount Spent', CurrencyFormatter.format(spentAmount)),
            _row('Remaining Credit', CurrencyFormatter.format(remainingAmount)),
            _row('Next Reset', Formatters.formatDate(nextReset)),
            const SizedBox(height: 12),
            MonthlyProgressBar(spentAmount: spentAmount, allocatedAmount: monthlyAllocation),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}

