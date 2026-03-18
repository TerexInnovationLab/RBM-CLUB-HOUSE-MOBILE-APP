import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'rbm_badge.dart';

/// Standard RBM app bar with optional notification badge.
class RbmAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates the RBM app bar.
  const RbmAppBar({
    super.key,
    this.title = AppStrings.appName,
    this.centerTitle = false,
    this.unreadCount = 0,
    this.onNotificationsTap,
    this.actions,
  });

  /// Title.
  final String title;

  /// Whether the title should be centered.
  final bool centerTitle;

  /// Unread notifications.
  final int unreadCount;

  /// Notification icon tap.
  final VoidCallback? onNotificationsTap;

  /// Extra actions.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      title: Text(title),
      actions: [
        if (onNotificationsTap != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: onNotificationsTap,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(41),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: RbmBadge(count: unreadCount),
                  ),
                ],
              ),
            ),
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
