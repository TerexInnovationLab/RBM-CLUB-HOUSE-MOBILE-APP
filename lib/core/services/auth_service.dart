import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage_service.dart';

/// Authentication session helpers (token access/clearing).
class AuthService {
  /// Creates an auth service.
  const AuthService(this._storage);

  final SecureStorageService _storage;

  /// Returns current access token (if any).
  Future<String?> getAccessToken() => _storage.readAccessToken();

  /// Returns current refresh token (if any).
  Future<String?> getRefreshToken() => _storage.readRefreshToken();

  /// Clears stored session.
  Future<void> clearSession() async {
    await _storage.clearTokens();
    await _storage.clearStaffProfileJson();
  }
}

/// Provider for auth service.
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.read(secureStorageServiceProvider);
  return AuthService(storage);
});

