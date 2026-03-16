/// In-app notification model.
class NotificationModel {
  /// Creates a notification.
  const NotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  /// Id.
  final String id;

  /// Notification type.
  final String notificationType;

  /// Title.
  final String title;

  /// Message.
  final String message;

  /// Optional reference id.
  final String? referenceId;

  /// Read state.
  final bool isRead;

  /// Timestamp (UTC).
  final DateTime createdAt;

  /// Parses JSON.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      notificationType: (json['notificationType'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      referenceId: json['referenceId']?.toString(),
      isRead: (json['isRead'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

