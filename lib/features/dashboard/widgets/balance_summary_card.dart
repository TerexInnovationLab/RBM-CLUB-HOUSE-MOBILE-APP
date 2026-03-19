import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../profile/providers/app_settings_provider.dart';
import 'monthly_progress_bar.dart';

/// Balance summary card.
class BalanceSummaryCard extends ConsumerStatefulWidget {
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
  ConsumerState<BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends ConsumerState<BalanceSummaryCard> {
  bool _isBalanceVisible = false;
  bool _initializedFromSettings = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    if (!_initializedFromSettings) {
      _isBalanceVisible =
          !settings.hideBalancesByDefault && !settings.amountMasking;
      _initializedFromSettings = true;
    }

    final hasRemaining = widget.remainingAmount >= 0;
    final remainingPrefix = hasRemaining ? '+' : '-';
    final shouldMask = !_isBalanceVisible;
    final allocationValue = shouldMask
        ? 'MWK ******'
        : CurrencyFormatter.formatTransaction(widget.monthlyAllocation);
    final mainBalance = shouldMask
        ? 'MWK ******'
        : CurrencyFormatter.format(widget.currentBalance);
    final remainingValue = shouldMask
        ? 'MWK ******'
        : '$remainingPrefix${CurrencyFormatter.formatTransaction(widget.remainingAmount.abs())}';
    final spentValue = shouldMask
        ? 'MWK ******'
        : CurrencyFormatter.formatTransaction(widget.spentAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Monthly Allocation $allocationValue',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.secondaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _isBalanceVisible = !_isBalanceVisible),
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.secondaryBlue,
                ),
                splashRadius: 18,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              mainBalance,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 48,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$remainingValue available this cycle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: hasRemaining
                  ? AppColors.successGreen
                  : AppColors.dangerRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          MonthlyProgressBar(
            spentAmount: widget.spentAmount,
            allocatedAmount: widget.monthlyAllocation,
          ),
          const SizedBox(height: 8),
          Text(
            '$spentValue spent | resets ${Formatters.formatDate(widget.nextReset)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
