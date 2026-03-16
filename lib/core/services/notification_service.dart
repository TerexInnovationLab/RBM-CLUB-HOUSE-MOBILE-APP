import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

/// Initializes Firebase Cloud Messaging and registers devices with the backend.
class NotificationService {
  /// Creates a notification service.
  NotificationService(this._api, this._storage);

  final ApiService _api;
  final SecureStorageService _storage;

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Initializes notification permissions, token registration and handlers.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerDevice(token: token);
      }

      _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
        await _registerDevice(token: newToken);
      });

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('FCM foreground message: ${message.messageId}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('FCM opened message: ${message.messageId}');
      });
    } catch (e) {
      debugPrint('NotificationService.init() skipped/failed: $e');
    }
  }

  /// Disposes refresh listeners.
  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }

  Future<void> _registerDevice({required String token}) async {
    final deviceIdentifier = await _storage.readOrCreateDeviceIdentifier();
    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

    try {
      await _api.dio.post<Map<String, dynamic>>(
        ApiEndpoints.devicesRegister,
        data: {
          'fcmToken': token,
          'platform': platform,
          'deviceIdentifier': deviceIdentifier,
        },
      );
    } catch (e) {
      debugPrint('Device registration failed: $e');
    }
  }
}

/// Provider for notification service.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final api = ref.read(apiServiceProvider);
  final storage = ref.read(secureStorageServiceProvider);
  final service = NotificationService(api, storage);
  ref.onDispose(service.dispose);
  return service;
});

