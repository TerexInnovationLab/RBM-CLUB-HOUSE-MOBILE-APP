import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
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
        appBar: const RbmAppBar(title: AppStrings.notificationsTitle),
        body: items.when(
          data: (list) {
            if (list.isEmpty) {
              return const EmptyStateWidget(
                title: 'No notifications',
                subtitle: 'You are all caught up.',
              );
            }
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
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
