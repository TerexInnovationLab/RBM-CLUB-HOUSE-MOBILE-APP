import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Header controls for the transaction list screen.
class TransactionFilterBar extends StatelessWidget {
  /// Creates a transaction filter bar.
  const TransactionFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    this.transactionCount,
    this.selectedSegment = 'Transactions',
    this.onSegmentChanged,
    this.onFilterTap,
    this.filterActive = false,
    this.onSearchChanged,
    this.onClearSearch,
  });

  /// Search controller.
  final TextEditingController searchController;

  /// Current search query.
  final String searchQuery;

  /// Transactions count for helper text.
  final int? transactionCount;

  /// Current selected segmented item.
  final String selectedSegment;

  /// Called when segmented control changes.
  final ValueChanged<String>? onSegmentChanged;

  /// Filter action.
  final VoidCallback? onFilterTap;

  /// Whether any filter is currently active.
  final bool filterActive;

  /// Search callback.
  final ValueChanged<String>? onSearchChanged;

  /// Clear search callback.
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countText = transactionCount == null
        ? ''
        : '$transactionCount transactions';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.inputRadius,
                  ),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: 'Reports',
                        selected: selectedSegment == 'Reports',
                        onTap: () => onSegmentChanged?.call('Reports'),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Transactions',
                        selected: selectedSegment == 'Transactions',
                        onTap: () => onSegmentChanged?.call('Transactions'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onFilterTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: filterActive
                      ? AppColors.warningOrange
                      : AppColors.borderGray,
                ),
                foregroundColor: filterActive
                    ? AppColors.warningOrange
                    : AppColors.primaryBlue,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                ),
              ),
              child: Text(filterActive ? 'Filter On' : 'Filter'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search transactions',
            hintStyle: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.inactive,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: const Color(0xFFF1F3F8),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: AppColors.secondaryBlue,
                width: 1.1,
              ),
            ),
          ),
          textInputAction: TextInputAction.search,
        ),
        if (countText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            countText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
