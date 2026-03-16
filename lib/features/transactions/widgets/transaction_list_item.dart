import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../../shared/widgets/rbm_pill.dart';
import '../models/transaction_model.dart';

/// Transaction list item tile.
class TransactionListItem extends StatelessWidget {
  /// Creates a transaction list item.
  const TransactionListItem({super.key, required this.transaction, this.onTap});

  /// Transaction.
  final TransactionModel transaction;

  /// Tap handler.
  final VoidCallback? onTap;

  bool _isCredit(TransactionModel t) {
    final type = t.transactionType.toUpperCase();
    return type.contains('ALLOCATION') || type.contains('CREDIT') || type.contains('TOPUP');
  }

  String _badgeLabel(TransactionModel t) {
    if (_isCredit(t)) return 'Credited';
    final s = t.status.toUpperCase();
    return switch (s) {
      'APPROVED' => 'Approved',
      'DECLINED' => 'Declined',
      'REVERSED' => 'Reversed',
      _ => t.status.isEmpty ? 'Pending' : t.status,
    };
  }

  RbmPillTone _badgeTone(TransactionModel t) {
    if (_isCredit(t)) return RbmPillTone.info;
    final s = t.status.toUpperCase();
    return switch (s) {
      'APPROVED' => RbmPillTone.success,
      'DECLINED' => RbmPillTone.danger,
      'REVERSED' => RbmPillTone.warning,
      _ => RbmPillTone.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = _isCredit(transaction);
    final amountColor = isCredit ? AppColors.successGreen : AppColors.dangerRed;
    final sign = isCredit ? '+' : '-';

    return RbmCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCredit ? Icons.check_circle_outline : Icons.credit_card,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.merchant,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatDateTimeDot(transaction.occurredAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign ${CurrencyFormatter.formatTransaction(transaction.amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: amountColor),
              ),
              const SizedBox(height: 6),
              RbmPill(label: _badgeLabel(transaction), tone: _badgeTone(transaction)),
            ],
          ),
        ],
      ),
    );
  }
}
