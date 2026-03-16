import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'rbm_badge.dart';

/// Standard RBM app bar with optional notification badge.
class RbmAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates the RBM app bar.
  const RbmAppBar({
    super.key,
    this.title = AppStrings.appName,
    this.unreadCount = 0,
    this.onNotificationsTap,
    this.actions,
  });

  /// Title.
  final String title;

  /// Unread notifications.
  final int unreadCount;

  /// Notification icon tap.
  final VoidCallback? onNotificationsTap;

  /// Extra actions.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (onNotificationsTap != null)
          IconButton(
            onPressed: onNotificationsTap,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  top: -4,
                  right: -4,
                  child: RbmBadge(count: unreadCount),
                ),
              ],
            ),
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

