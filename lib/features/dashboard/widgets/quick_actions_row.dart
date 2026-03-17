import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/route_names.dart';

/// Quick action shortcuts.
class QuickActionsRow extends StatelessWidget {
  /// Creates quick actions row.
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      _QuickActionData(
        label: 'Pay',
        icon: Icons.payments_outlined,
        route: RouteNames.fullscreenQr,
      ),
      _QuickActionData(
        label: 'My Card',
        icon: Icons.credit_card_outlined,
        route: RouteNames.card,
      ),
      _QuickActionData(
        label: 'Transaction',
        icon: Icons.receipt_long_outlined,
        route: RouteNames.transactions,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          Expanded(child: _QuickActionButton(data: actions[i])),
          if (i != actions.length - 1)
            Container(
              width: 1,
              height: 52,
              color: Colors.white.withValues(alpha: 0.28),
            ),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(data.route),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 18, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              data.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
