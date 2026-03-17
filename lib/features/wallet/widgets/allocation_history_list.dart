import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../models/allocation_history_model.dart';

/// Allocation history list.
class AllocationHistoryList extends StatelessWidget {
  /// Creates allocation history list.
  const AllocationHistoryList({super.key, required this.items});

  /// Allocation items.
  final List<AllocationHistoryItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Allocation history', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in items) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.periodLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatDate(item.allocatedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inactive),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  CurrencyFormatter.format(item.amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
        ],
      ],
    );
  }
}
