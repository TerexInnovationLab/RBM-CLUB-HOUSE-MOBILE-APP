import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_list_item.dart';

/// Notification list screen.
class NotificationListScreen extends ConsumerWidget {
  /// Creates notification list screen.
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);

    return OfflineBanner(
      child: Scaffold(
        body: items.when(
          data: (list) {
            if (list.isEmpty) {
              return const EmptyStateWidget(
                title: 'No notifications',
                subtitle: 'You are all caught up.',
              );
            }
            final unread = list.where((n) => !n.isRead).length;
            return Column(
              children: [
                _NotificationsHeader(unreadCount: unread),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(13, 10, 13, 72),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = list[index];
                      return Dismissible(
                        key: ValueKey(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {},
                        child: NotificationListItem(notification: n),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: 'Failed to load notifications: $e',
            onRetry: () => ref.refresh(notificationsProvider),
          ),
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '$unreadCount unread',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10),
                ),
              ],
            ),
            Text(
              'Mark all read',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
