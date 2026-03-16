import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../models/transaction_model.dart';

/// Transaction list item tile.
class TransactionListItem extends StatelessWidget {
  /// Creates a transaction list item.
  const TransactionListItem({super.key, required this.transaction, this.onTap});

  /// Transaction.
  final TransactionModel transaction;

  /// Tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.merchant),
      subtitle: Text(Formatters.formatLocalDateTime(transaction.occurredAt)),
      trailing: Text(CurrencyFormatter.format(transaction.amount)),
      onTap: onTap,
    );
  }
}

