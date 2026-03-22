import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/transaction_model.dart';

/// Clean transaction row inspired by native wallet lists.
class TransactionListItem extends ConsumerWidget {
  /// Creates a transaction list item.
  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDivider = true,
  });

  /// Transaction.
  final TransactionModel transaction;

  /// Tap handler.
  final VoidCallback? onTap;

  /// Whether to render the bottom divider.
  final bool showDivider;

  bool _isCredit(TransactionModel t) {
    final type = t.transactionType.toUpperCase();
    return type.contains('ALLOCATION') ||
        type.contains('CREDIT') ||
        type.contains('TOPUP');
  }

  Color _avatarColor(String value) {
    final seed = value.trim().isEmpty ? 0 : value.trim().codeUnitAt(0);
    final swatch = [
      AppColors.primaryBlue,
      AppColors.secondaryBlue,
      AppColors.warningOrange,
      AppColors.successGreen,
      const Color(0xFF4F6DB8),
    ];
    return swatch[seed % swatch.length];
  }

  String _subtitle(TransactionModel t) {
    final local = t.occurredAt.toLocal();
    final time = DateFormat('HH:mm').format(local);
    final status = t.status.trim().isEmpty ? 'Pending' : t.status;
    return '$time • $status';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isCredit = _isCredit(transaction);
    final amountColor = isCredit
        ? AppColors.successGreen
        : AppColors.textPrimary;
    final sign = isCredit ? '+' : '-';
    final amountText = settings.amountMasking
        ? '$sign MWK ******'
        : '$sign ${CurrencyFormatter.formatTransaction(transaction.amount)}';
    final merchant = transaction.merchant.trim().isEmpty
        ? 'Transaction'
        : transaction.merchant.trim();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.borderGray))
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: _avatarColor(merchant).withValues(alpha: 0.14),
              child: Text(
                merchant.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _avatarColor(merchant),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(transaction),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amountText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inactive,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
