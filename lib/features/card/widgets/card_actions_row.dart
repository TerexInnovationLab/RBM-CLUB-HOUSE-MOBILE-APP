import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';

/// Virtual card actions.
class CardActionsRow extends StatelessWidget {
  /// Creates card actions row.
  const CardActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => context.go(RouteNames.fullscreenQr),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text('View Full QR'),
      ),
    );
  }
}
