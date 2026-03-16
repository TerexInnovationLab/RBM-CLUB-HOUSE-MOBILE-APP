import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../models/allocation_history_model.dart';

/// Allocation history list.
class AllocationHistoryList extends StatelessWidget {
  /// Creates allocation history list.
  const AllocationHistoryList({super.key, required this.items});

  /// Allocation items.
  final List<AllocationHistoryItemModel> items;

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Allocation History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.periodLabel),
              subtitle: Text(Formatters.formatDate(item.allocatedAt)),
              trailing: Text(CurrencyFormatter.format(item.amount)),
            ),
        ],
      ),
    );
  }
}
