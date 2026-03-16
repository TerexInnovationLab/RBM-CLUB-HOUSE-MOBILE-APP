import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage keys.
abstract final class _Keys {
  static const String accessToken = 'auth.accessToken';
  static const String refreshToken = 'auth.refreshToken';
  static const String biometricEnabled = 'auth.biometricEnabled';
  static const String staffProfileJson = 'profile.staffProfileJson';
  static const String deviceIdentifier = 'device.identifier';
}

/// Wrapper around `FlutterSecureStorage`.
class SecureStorageService {
  /// Creates a secure storage service.
  const SecureStorageService();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Reads access token.
  Future<String?> readAccessToken() => _storage.read(key: _Keys.accessToken);

  /// Reads refresh token.
  Future<String?> readRefreshToken() => _storage.read(key: _Keys.refreshToken);

  /// Writes tokens atomically.
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _Keys.accessToken, value: accessToken);
    await _storage.write(key: _Keys.refreshToken, value: refreshToken);
  }

  /// Clears tokens.
  Future<void> clearTokens() async {
    await _storage.delete(key: _Keys.accessToken);
    await _storage.delete(key: _Keys.refreshToken);
  }

  /// Reads biometric enabled flag.
  Future<bool> readBiometricEnabled() async =>
      (await _storage.read(key: _Keys.biometricEnabled)) == 'true';

  /// Writes biometric enabled flag.
  Future<void> writeBiometricEnabled(bool enabled) async =>
      _storage.write(key: _Keys.biometricEnabled, value: enabled.toString());

  /// Reads persisted staff profile JSON (if any).
  Future<String?> readStaffProfileJson() =>
      _storage.read(key: _Keys.staffProfileJson);

  /// Writes persisted staff profile JSON.
  Future<void> writeStaffProfileJson(String json) =>
      _storage.write(key: _Keys.staffProfileJson, value: json);

  /// Clears persisted profile.
  Future<void> clearStaffProfileJson() => _storage.delete(key: _Keys.staffProfileJson);

  /// Reads (or creates) a stable device identifier used for device registration.
  Future<String> readOrCreateDeviceIdentifier() async {
    final existing = await _storage.read(key: _Keys.deviceIdentifier);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = DateTime.now().microsecondsSinceEpoch.toString();
    await _storage.write(key: _Keys.deviceIdentifier, value: created);
    return created;
  }

  /// Writes an arbitrary secure key/value pair.
  Future<void> writeString({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  /// Reads an arbitrary secure value.
  Future<String?> readString(String key) => _storage.read(key: key);
}

/// Provider for secure storage.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService();
});
