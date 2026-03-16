/// Trusted device model.
class TrustedDeviceModel {
  /// Creates a trusted device.
  const TrustedDeviceModel({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.lastSeenAt,
  });

  /// Device id.
  final String deviceId;

  /// Human readable device name.
  final String deviceName;

  /// Platform string.
  final String platform;

  /// Last seen timestamp.
  final DateTime lastSeenAt;

  /// Parses JSON.
  factory TrustedDeviceModel.fromJson(Map<String, dynamic> json) {
    return TrustedDeviceModel(
      deviceId: (json['deviceId'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? '').toString(),
      platform: (json['platform'] ?? '').toString(),
      lastSeenAt: DateTime.tryParse((json['lastSeenAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

