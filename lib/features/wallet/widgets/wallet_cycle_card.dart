import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../models/monthly_summary_model.dart';

/// Displays the current wallet cycle.
class WalletCycleCard extends StatelessWidget {
  /// Creates a wallet cycle card.
  const WalletCycleCard({super.key, required this.summary});

  /// Monthly summary.
  final MonthlySummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Allocation Cycle', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Start: ${Formatters.formatDate(summary.periodStart)}'),
            Text('End: ${Formatters.formatDate(summary.periodEnd)}'),
            const SizedBox(height: 12),
            Text('Allocated: ${CurrencyFormatter.format(summary.allocatedAmount)}'),
            Text('Spent: ${CurrencyFormatter.format(summary.spentAmount)}'),
            Text('Remaining: ${CurrencyFormatter.format(summary.remainingAmount)}'),
          ],
        ),
      ),
    );
  }
}

