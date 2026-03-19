import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import '../../../core/services/secure_storage_service.dart';
import '../models/app_settings_model.dart';

/// Provider for persisted app settings.
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsModel>((ref) {
      final storage = ref.read(secureStorageServiceProvider);
      return AppSettingsNotifier(storage);
    });

/// Manages app settings state and persistence.
class AppSettingsNotifier extends StateNotifier<AppSettingsModel> {
  /// Creates app settings notifier.
  AppSettingsNotifier(this._storage) : super(AppSettingsModel.defaults) {
    _hydrate();
  }

  static const String _settingsStorageKey = 'app.settings.v1';

  final SecureStorageService _storage;

  Future<void> _hydrate() async {
    try {
      final raw = await _storage.readString(_settingsStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = AppSettingsModel.fromJson(decoded);
      } else {
        state = AppSettingsModel.defaults;
        await _persist(state);
      }
    } catch (e) {
      debugPrint('Failed to load app settings: $e');
      state = AppSettingsModel.defaults;
      await _persist(state);
    }

    await _applyScreenshotProtection(state.screenshotProtection);
  }

  Future<void> _persist(AppSettingsModel value) async {
    try {
      final encoded = jsonEncode(value.toJson());
      await _storage.writeString(key: _settingsStorageKey, value: encoded);
    } catch (e) {
      debugPrint('Failed to persist app settings: $e');
    }
  }

  Future<void> _update(
    AppSettingsModel next, {
    bool applyScreenshotProtection = false,
  }) async {
    final previous = state;
    state = next;
    await _persist(next);

    if (applyScreenshotProtection ||
        previous.screenshotProtection != next.screenshotProtection) {
      await _applyScreenshotProtection(next.screenshotProtection);
    }
  }

  Future<void> _applyScreenshotProtection(bool enabled) async {
    if (kIsWeb) return;

    try {
      if (enabled) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    } catch (e) {
      debugPrint('Failed to update screenshot protection: $e');
    }
  }

  /// Clears in-memory image cache.
  Future<void> clearImageCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  Future<void> setNotificationPermission(bool value) =>
      _update(state.copyWith(notificationPermission: value));

  Future<void> setNotificationTransactions(bool value) =>
      _update(state.copyWith(notificationTransactions: value));

  Future<void> setNotificationLowBalance(bool value) =>
      _update(state.copyWith(notificationLowBalance: value));

  Future<void> setNotificationWalletCycle(bool value) =>
      _update(state.copyWith(notificationWalletCycle: value));

  Future<void> setNotificationSecurityAlerts(bool value) =>
      _update(state.copyWith(notificationSecurityAlerts: value));

  Future<void> setQuietHoursEnabled(bool value) =>
      _update(state.copyWith(quietHoursEnabled: value));

  Future<void> setQuietHoursRange({int? startHour, int? endHour}) {
    final start = (startHour ?? state.quietHoursStartHour).clamp(0, 23).toInt();
    final end = (endHour ?? state.quietHoursEndHour).clamp(0, 23).toInt();

    return _update(
      state.copyWith(quietHoursStartHour: start, quietHoursEndHour: end),
    );
  }

  Future<void> setNotificationSound(bool value) =>
      _update(state.copyWith(notificationSound: value));

  Future<void> setNotificationVibration(bool value) =>
      _update(state.copyWith(notificationVibration: value));

  Future<void> setHideBalancesByDefault(bool value) =>
      _update(state.copyWith(hideBalancesByDefault: value));

  Future<void> setScreenshotProtection(bool value) => _update(
    state.copyWith(screenshotProtection: value),
    applyScreenshotProtection: true,
  );

  Future<void> setBiometricPermission(bool value) =>
      _update(state.copyWith(biometricPermission: value));

  Future<void> setThemePreference(AppThemePreference value) =>
      _update(state.copyWith(themePreference: value));

  Future<void> setTextScale(double value) =>
      _update(state.copyWith(textScale: value.clamp(0.85, 1.25).toDouble()));

  Future<void> setCompactMode(bool value) =>
      _update(state.copyWith(compactMode: value));

  Future<void> setReceiptBehavior(ReceiptBehavior value) =>
      _update(state.copyWith(receiptBehavior: value));

  Future<void> setConfirmationPrompts(bool value) =>
      _update(state.copyWith(confirmationPrompts: value));

  Future<void> setAmountMasking(bool value) =>
      _update(state.copyWith(amountMasking: value));

  Future<void> setRefreshBehavior(RefreshBehavior value) =>
      _update(state.copyWith(refreshBehavior: value));

  Future<void> setOfflineDataControls(bool value) =>
      _update(state.copyWith(offlineDataControls: value));
}
