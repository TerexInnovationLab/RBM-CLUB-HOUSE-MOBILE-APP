import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Small badge used for counts (e.g., unread notifications).
class RbmBadge extends StatelessWidget {
  /// Creates a badge.
  const RbmBadge({super.key, required this.count});

  /// Badge count.
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningOrange,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
