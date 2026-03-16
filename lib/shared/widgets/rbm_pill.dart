import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum RbmPillTone { success, danger, warning, info, neutral }

/// Filled pill badge (20px radius) with semantic colors.
class RbmPill extends StatelessWidget {
  const RbmPill({
    super.key,
    required this.label,
    this.tone = RbmPillTone.neutral,
    this.dense = true,
  });

  final String label;
  final RbmPillTone tone;
  final bool dense;

  Color _fg() => switch (tone) {
        RbmPillTone.success => AppColors.successGreen,
        RbmPillTone.danger => AppColors.dangerRed,
        RbmPillTone.warning => AppColors.warningOrange,
        RbmPillTone.info => AppColors.secondaryBlue,
        RbmPillTone.neutral => AppColors.textSecondary,
      };

  Color _bg() {
    final fg = _fg();
    return fg.withAlpha(36);
  }

  @override
  Widget build(BuildContext context) {
    final fg = _fg();
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: fg);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: dense ? 4 : 6),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: textStyle),
    );
  }
}
