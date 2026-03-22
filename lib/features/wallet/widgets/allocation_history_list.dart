import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/allocation_history_model.dart';

/// Allocation history list.
class AllocationHistoryList extends ConsumerWidget {
  /// Creates allocation history list.
  const AllocationHistoryList({super.key, required this.items});

  /// Allocation items.
  final List<AllocationHistoryItemModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maskAmounts = ref.watch(appSettingsProvider).amountMasking;

    String money(double value) {
      if (maskAmounts) return 'MWK ******';
      return CurrencyFormatter.format(value).replaceFirst('.00', '');
    }

    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allocation History',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Previous wallet allocation cycles',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Text(
                'No allocation history yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              _HistoryRow(item: items[i], amountText: money(items[i].amount)),
              if (i != items.length - 1) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.borderGray),
                const SizedBox(height: 8),
              ],
            ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.amountText});

  final AllocationHistoryItemModel item;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.secondaryBlue.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            size: 19,
            color: AppColors.secondaryBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.periodLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.formatDate(item.allocatedAt),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          amountText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
