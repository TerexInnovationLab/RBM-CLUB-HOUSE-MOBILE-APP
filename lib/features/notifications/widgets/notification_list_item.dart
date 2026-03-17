import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/rbm_pill.dart';
import '../models/notification_model.dart';

/// Notification list item tile.
class NotificationListItem extends StatelessWidget {
  /// Creates a notification list item.
  const NotificationListItem({super.key, required this.notification, this.onTap});

  /// Notification.
  final NotificationModel notification;

  /// Tap handler.
  final VoidCallback? onTap;

  RbmPillTone _tone(NotificationModel n) {
    final t = n.notificationType.toUpperCase();
    if (t.contains('PURCHASE')) return RbmPillTone.danger;
    if (t.contains('LOW') || t.contains('ALERT')) return RbmPillTone.warning;
    if (t.contains('ALLOCATION') || t.contains('CREDIT')) return RbmPillTone.success;
    if (t.contains('SECURITY')) return RbmPillTone.info;
    return RbmPillTone.neutral;
  }

  String _badgeLabel(NotificationModel n) {
    final raw = n.notificationType.trim();
    if (raw.isNotEmpty) return raw;
    return n.title.trim().isEmpty ? 'Notification' : n.title.trim();
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    final bg = unread ? const Color(0xFFF5F9FF) : Colors.white;
    final opacity = unread ? 1.0 : 0.72;

    final footer = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Formatters.formatLocalDateTime(notification.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.borderGray, fontSize: 10),
        ),
        if ((notification.referenceId ?? '').trim().isNotEmpty)
          Text(
            'View',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondaryBlue, fontSize: 10),
          ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: unread ? AppColors.primaryBlue : const Color(0xFFEFEFEF), width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: unread ? AppColors.primaryBlue : AppColors.borderGray,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RbmPill(label: _badgeLabel(notification), tone: _tone(notification)),
                    const SizedBox(height: 6),
                    if (notification.title.trim().isNotEmpty) ...[
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: unread ? const Color(0xFF444444) : AppColors.inactive,
                            fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 6),
                    footer,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
