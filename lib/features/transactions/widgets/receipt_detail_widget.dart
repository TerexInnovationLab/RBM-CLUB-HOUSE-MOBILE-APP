import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../models/receipt_model.dart';

/// Receipt details widget.
class ReceiptDetailWidget extends StatelessWidget {
  /// Creates receipt details widget.
  const ReceiptDetailWidget({super.key, required this.receipt});

  /// Receipt.
  final ReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt ${receipt.receiptNumber}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Location: ${receipt.posLocation}'),
            Text('Date: ${Formatters.formatLocalDateTime(receipt.occurredAt)}'),
            const Divider(height: 24),
            for (final item in receipt.items)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${item.itemName} ×${item.quantity}')),
                  Text(CurrencyFormatter.format(item.lineTotal)),
                ],
              ),
            const Divider(height: 24),
            _row('Total', CurrencyFormatter.format(receipt.totalAmount)),
            _row('Balance before', CurrencyFormatter.format(receipt.balanceBefore)),
            _row('Balance after', CurrencyFormatter.format(receipt.balanceAfter)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

