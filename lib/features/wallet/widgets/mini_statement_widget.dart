import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/rbm_card.dart';

/// Mini-statement placeholder.
class MiniStatementWidget extends StatelessWidget {
  /// Creates a mini statement widget.
  const MiniStatementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: AppColors.warningOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mini Statement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(RouteNames.transactions),
                child: const Text('Open'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Recent wallet transactions and cycle summaries will appear here.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
