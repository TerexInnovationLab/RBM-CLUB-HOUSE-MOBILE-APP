import 'package:flutter/material.dart';

/// Mini-statement placeholder.
class MiniStatementWidget extends StatelessWidget {
  /// Creates a mini statement widget.
  const MiniStatementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Mini statement will appear here.'),
      ),
    );
  }
}

