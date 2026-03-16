import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/route_names.dart';

/// Virtual card actions.
class CardActionsRow extends StatelessWidget {
  /// Creates card actions row.
  const CardActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => context.go(RouteNames.fullscreenQr),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Full-screen QR'),
          ),
        ),
      ],
    );
  }
}

