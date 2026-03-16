import 'package:flutter/material.dart';

import '../../../shared/widgets/rbm_card.dart';

/// Mini-statement placeholder.
class MiniStatementWidget extends StatelessWidget {
  /// Creates a mini statement widget.
  const MiniStatementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const RbmCard(
      child: Text('Mini statement will appear here.'),
    );
  }
}
