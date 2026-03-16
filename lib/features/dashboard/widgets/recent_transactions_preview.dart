import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/route_names.dart';
import '../../transactions/models/transaction_model.dart';

/// Recent transactions preview widget.
class RecentTransactionsPreview extends StatelessWidget {
  /// Creates the widget.
  const RecentTransactionsPreview({super.key, required this.transactions});

  /// Transactions (last 3).
  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go(RouteNames.transactions),
                  child: const Text('View all →'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final t in transactions.take(3))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(t.merchant),
                subtitle: Text(Formatters.formatDate(t.occurredAt)),
                trailing: Text(CurrencyFormatter.format(t.amount)),
                onTap: () => context.go('${RouteNames.transactions}/${t.id}'),
              ),
          ],
        ),
      ),
    );
  }
}

