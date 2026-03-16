import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../data/notification_repository.dart';
import '../models/notification_model.dart';

/// Notification repository provider.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return NotificationRepository(api);
});

/// Notifications list provider.
final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  return ref.read(notificationRepositoryProvider).fetchNotifications();
});

