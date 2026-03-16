import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../models/notification_model.dart';

/// Notification list item tile.
class NotificationListItem extends StatelessWidget {
  /// Creates a notification list item.
  const NotificationListItem({super.key, required this.notification, this.onTap});

  /// Notification.
  final NotificationModel notification;

  /// Tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = notification.isRead ? null : AppColors.primaryBlue.withValues(alpha: 0.08);
    final border = notification.isRead ? null : AppColors.primaryBlue;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: border == null ? null : Border(left: BorderSide(color: border, width: 4)),
      ),
      child: ListTile(
        title: Text(notification.title),
        subtitle: Text('${notification.message}\n${Formatters.formatLocalDateTime(notification.createdAt)}'),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
