import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/route_names.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/widgets/transaction_list_item.dart';

/// Recent transactions preview widget.
class RecentTransactionsPreview extends StatelessWidget {
  /// Creates the widget.
  const RecentTransactionsPreview({super.key, required this.transactions});

  /// Transactions (last 3).
  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.go(RouteNames.transactions),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final t in transactions.take(3)) ...[
          TransactionListItem(
            transaction: t,
            onTap: () => context.go('${RouteNames.transactions}/${t.id}'),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
