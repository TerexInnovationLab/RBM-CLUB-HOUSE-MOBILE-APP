import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/route_names.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../../transactions/models/transaction_model.dart';

/// Recent transactions preview widget.
class RecentTransactionsPreview extends ConsumerWidget {
  /// Creates the widget.
  const RecentTransactionsPreview({super.key, required this.transactions});

  /// Transactions (last 3).
  final List<TransactionModel> transactions;

  bool _isCredit(TransactionModel t) {
    final type = t.transactionType.toUpperCase();
    return type.contains('ALLOCATION') ||
        type.contains('CREDIT') ||
        type.contains('TOPUP');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = transactions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latest Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1D2B1F),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.transactions),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF576A59),
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (preview.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'No transactions yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          Column(
            children: [
              for (final tx in preview) ...[
                _CompactTransactionTile(
                  transaction: tx,
                  isCredit: _isCredit(tx),
                  onTap: () =>
                      context.go('${RouteNames.transactions}/${tx.id}'),
                ),
                if (tx != preview.last) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

class _CompactTransactionTile extends ConsumerWidget {
  const _CompactTransactionTile({
    required this.transaction,
    required this.isCredit,
    required this.onTap,
  });

  final TransactionModel transaction;
  final bool isCredit;
  final VoidCallback onTap;

  String _relativeTime(DateTime occurredAt) {
    final diff = DateTime.now().difference(occurredAt.toLocal());

    if (diff.inMinutes <= 0) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return Formatters.formatDate(occurredAt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final sign = isCredit ? '+' : '-';
    final amountColor = isCredit ? AppColors.successGreen : AppColors.dangerRed;
    final amountText = settings.amountMasking
        ? '$sign MWK ******'
        : '$sign${CurrencyFormatter.formatTransaction(transaction.amount)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCredit
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    size: 19,
                    color: const Color(0xFF2D4131),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.merchant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: const Color(0xFF1D2B1F)),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _relativeTime(transaction.occurredAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  amountText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
