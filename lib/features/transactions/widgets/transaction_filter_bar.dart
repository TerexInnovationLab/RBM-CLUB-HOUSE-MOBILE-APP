import 'package:flutter/material.dart';

/// Transaction filter bar (placeholder).
class TransactionFilterBar extends StatelessWidget {
  /// Creates a transaction filter bar.
  const TransactionFilterBar({super.key, this.onChanged});

  /// Called when filter changes.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.filter_list),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search (merchant, amount, date)…',
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

