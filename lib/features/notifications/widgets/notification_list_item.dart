import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../models/notification_model.dart';

/// Notification list item tile.
class NotificationListItem extends StatelessWidget {
  /// Creates a notification list item.
  const NotificationListItem({
    super.key,
    required this.notification,
    required this.isRead,
    this.onTap,
  });

  /// Notification.
  final NotificationModel notification;

  /// Effective read state (can include local optimistic updates).
  final bool isRead;

  /// Tap handler.
  final VoidCallback? onTap;

  IconData _icon(NotificationModel n) {
    final t = n.notificationType.toUpperCase();
    if (t.contains('ALLOCATION') || t.contains('CREDIT')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (t.contains('ALERT') || t.contains('LOW')) {
      return Icons.warning_amber_rounded;
    }
    if (t.contains('SECURITY')) {
      return Icons.shield_outlined;
    }
    if (t.contains('PURCHASE') || t.contains('TRANSACTION')) {
      return Icons.receipt_long_outlined;
    }
    return Icons.notifications_outlined;
  }

  Color _iconBackground(NotificationModel n) {
    final t = n.notificationType.toUpperCase();
    if (t.contains('ALLOCATION') || t.contains('CREDIT')) {
      return const Color(0xFFD6EFFA);
    }
    if (t.contains('ALERT') || t.contains('LOW')) {
      return const Color(0xFFFCEBC9);
    }
    if (t.contains('SECURITY')) {
      return const Color(0xFFE8E9FF);
    }
    if (t.contains('PURCHASE') || t.contains('TRANSACTION')) {
      return const Color(0xFFFFE1E1);
    }
    return const Color(0xFFE9EEFF);
  }

  Color _iconColor(NotificationModel n) {
    final t = n.notificationType.toUpperCase();
    if (t.contains('ALERT') || t.contains('LOW')) {
      return AppColors.warningOrange;
    }
    if (t.contains('PURCHASE') || t.contains('TRANSACTION')) {
      return AppColors.dangerRed;
    }
    return AppColors.secondaryBlue;
  }

  String _title(NotificationModel n) {
    final title = n.title.trim();
    if (title.isNotEmpty) {
      return title;
    }

    final rawType = n.notificationType.trim();
    if (rawType.isEmpty) {
      return 'Notification';
    }

    final parts = rawType
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    return parts
        .map((e) => '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime.toLocal());

    if (diff.inMinutes <= 0) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return Formatters.formatDate(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final unread = !isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE6E8EE), width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _iconBackground(notification),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon(notification),
                  size: 24,
                  color: _iconColor(notification),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(notification),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: unread
                            ? const Color(0xFF4B5361)
                            : AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: unread
                        ? Container(
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryBlue,
                              shape: BoxShape.circle,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _relativeTime(notification.createdAt),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
