import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../models/notification_model.dart';

/// Notification repository.
class NotificationRepository {
  /// Creates notification repository.
  const NotificationRepository(this._api);

  final ApiService _api;

  /// Fetches notifications.
  Future<List<NotificationModel>> fetchNotifications({int page = 1, int limit = 20}) async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return [
        NotificationModel(
          id: 'n1',
          notificationType: 'TRANSACTION',
          title: 'Purchase approved',
          message: 'You spent MWK 850 at Club House A. Balance: MWK 10,650',
          referenceId: 't1',
          isRead: false,
          createdAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        ),
        NotificationModel(
          id: 'n2',
          notificationType: 'SYSTEM',
          title: 'Announcement',
          message: 'Club House A will be closed on 18 March 2026.',
          isRead: true,
          createdAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ),
      ];
    }

    final resp = await _api.dio.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = (resp.data?['data'] as List?) ?? const [];
    return data
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Marks a notification as read.
  Future<void> markRead(String id) async {
    if (_api.dio.options.baseUrl.isEmpty) return;
    await _api.dio.post<Map<String, dynamic>>(ApiEndpoints.notificationRead(id));
  }

  /// Marks all as read.
  Future<void> markAllRead() async {
    if (_api.dio.options.baseUrl.isEmpty) return;
    await _api.dio.post<Map<String, dynamic>>(ApiEndpoints.notificationsReadAll);
  }
}

