import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/monthly_summary_model.dart';

/// Displays the current wallet cycle.
class WalletCycleCard extends ConsumerWidget {
  /// Creates a wallet cycle card.
  const WalletCycleCard({super.key, required this.summary});

  /// Monthly summary.
  final MonthlySummaryModel summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final maskAmounts = settings.amountMasking;

    final used = summary.allocatedAmount <= 0
        ? 0.0
        : (summary.spentAmount / summary.allocatedAmount).clamp(0.0, 1.0);
    final daysRemaining = summary.periodEnd
        .toLocal()
        .difference(DateTime.now())
        .inDays;

    final available = maskAmounts
        ? 'MWK ******'
        : CurrencyFormatter.format(
            summary.remainingAmount,
          ).replaceFirst('.00', '');
    final allocated = maskAmounts
        ? 'MWK ******'
        : CurrencyFormatter.format(summary.allocatedAmount);
    final spent = maskAmounts
        ? 'MWK ******'
        : CurrencyFormatter.format(summary.spentAmount);

    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available balance'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: available),
                    if (!maskAmounts)
                      const TextSpan(
                        text: '.00',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _metric(label: 'Allocated', value: allocated),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(label: 'Spent', value: spent),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly usage',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${(used * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppColors.warningOrange,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: used,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.warningOrange,
                  ),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Next reset: ${Formatters.formatDate(summary.periodEnd)} | '
                '${daysRemaining < 0 ? 0 : daysRemaining} days remaining',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
