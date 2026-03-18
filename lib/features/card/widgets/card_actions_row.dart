import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/top_snackbar.dart';

/// Virtual card actions.
class CardActionsRow extends StatelessWidget {
  /// Creates card actions row.
  const CardActionsRow({super.key});

  void _comingSoon(BuildContext context, String label) {
    TopSnackBar.show(
      context,
      message: '$label coming soon.',
      tone: TopSnackBarTone.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: 'Full QR',
            icon: Icons.qr_code_2,
            iconBg: AppColors.secondaryBlue.withValues(alpha: 0.1),
            iconColor: AppColors.secondaryBlue,
            onTap: () => context.go(RouteNames.fullscreenQr),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            label: 'Lock card',
            icon: Icons.lock_outline,
            iconBg: AppColors.warningOrange.withValues(alpha: 0.12),
            iconColor: AppColors.warningOrange,
            onTap: () => _comingSoon(context, 'Lock card'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            label: 'History',
            icon: Icons.receipt_long_outlined,
            iconBg: AppColors.successGreen.withValues(alpha: 0.1),
            iconColor: AppColors.successGreen,
            onTap: () => context.go(RouteNames.transactions),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            label: 'Reissue',
            icon: Icons.close,
            iconBg: AppColors.dangerRed.withValues(alpha: 0.08),
            iconColor: AppColors.dangerRed,
            onTap: () => _comingSoon(context, 'Reissue'),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderGray),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
