import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric authentication wrapper.
class BiometricService {
  /// Creates a biometric service.
  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  /// Returns true if biometrics can be used.
  Future<bool> isSupported() => _localAuth.isDeviceSupported();

  /// Prompts for biometric authentication.
  Future<bool> authenticate({required String reason}) async {
    return _localAuth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}

/// Provider for biometric service.
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

