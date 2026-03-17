import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Transaction filter bar (UI-first; filtering can be wired later).
class TransactionFilterBar extends StatelessWidget {
  /// Creates a transaction filter bar.
  const TransactionFilterBar({
    super.key,
    this.transactionCount,
    this.onChanged,
    this.onSortTap,
    this.selected = 'All',
  });

  /// Transactions in the current view (for display only).
  final int? transactionCount;

  /// Called when filter changes.
  final ValueChanged<String>? onChanged;

  /// Sort icon handler.
  final VoidCallback? onSortTap;

  /// Selected filter label.
  final String selected;

  @override
  Widget build(BuildContext context) {
    final options = const ['All', 'Purchases', 'Credits', 'Date'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final opt in options) ...[
                _FilterChip(
                  label: opt,
                  selected: opt == selected,
                  onTap: () => onChanged?.call(opt),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              transactionCount == null ? '' : '$transactionCount transactions this month',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            InkWell(
              onTap: onSortTap,
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: const Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderGray),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
