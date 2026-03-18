import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../profile/models/staff_profile_model.dart';
import '../data/auth_repository.dart';
import '../models/auth_request_model.dart';

/// Immutable auth state.
class AuthState {
  /// Creates an auth state.
  const AuthState({
    required this.isBootstrapping,
    required this.isAuthenticated,
    this.staffProfile,
    required this.biometricEnabled,
    required this.failedAttempts,
    this.errorMessage,
  });

  /// True while reading persisted session.
  final bool isBootstrapping;

  /// True if JWT is present.
  final bool isAuthenticated;

  /// Staff profile (if available).
  final StaffProfileModel? staffProfile;

  /// Whether biometric login is enabled.
  final bool biometricEnabled;

  /// Consecutive failed attempts (max 5 before lock).
  final int failedAttempts;

  /// Last error message (user-friendly).
  final String? errorMessage;

  /// Remaining attempts before lock.
  int get remainingAttempts => (5 - failedAttempts).clamp(0, 5);

  /// True if locked due to failures.
  bool get isLocked => failedAttempts >= 5;

  /// Copies state.
  AuthState copyWith({
    bool? isBootstrapping,
    bool? isAuthenticated,
    StaffProfileModel? staffProfile,
    bool? biometricEnabled,
    int? failedAttempts,
    String? errorMessage,
  }) {
    return AuthState(
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      staffProfile: staffProfile ?? this.staffProfile,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      errorMessage: errorMessage,
    );
  }

  /// Initial state.
  static const AuthState initial = AuthState(
    isBootstrapping: true,
    isAuthenticated: false,
    biometricEnabled: false,
    failedAttempts: 0,
  );
}

/// Provider for the auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return AuthRepository(api);
});

/// Auth state notifier.
class AuthNotifier extends StateNotifier<AuthState> {
  /// Creates an auth notifier.
  AuthNotifier(this._repository, this._storage, this._biometric)
    : super(AuthState.initial) {
    _bootstrap();
  }

  static const Duration _minimumSplashDuration = Duration(seconds: 5);

  final AuthRepository _repository;
  final SecureStorageService _storage;
  final BiometricService _biometric;

  Future<void> _bootstrap() async {
    final startedAt = DateTime.now();
    try {
      // On Web, secure storage can sometimes hang if there's a configuration issue.
      // Only apply a timeout on Web to avoid leaving pending timers in widget tests.
      final bootstrapFuture = Future.wait([
        _storage.readAccessToken(),
        _storage.readStaffProfileJson(),
        _storage.readBiometricEnabled(),
      ]);
      final results = kIsWeb
          ? await bootstrapFuture.timeout(const Duration(seconds: 2))
          : await bootstrapFuture;

      final access = results[0] as String?;
      final profileJson = results[1] as String?;
      final biometricEnabled = (results[2] as bool?) ?? false;

      StaffProfileModel? profile;
      if (profileJson != null && profileJson.isNotEmpty) {
        try {
          profile = StaffProfileModel.fromJson(
            jsonDecode(profileJson) as Map<String, dynamic>,
          );
        } catch (e) {
          debugPrint('Error decoding profile: $e');
        }
      }

      await _waitForMinimumSplashDuration(startedAt);
      state = state.copyWith(
        isBootstrapping: false,
        isAuthenticated: access != null && access.isNotEmpty,
        staffProfile: profile,
        biometricEnabled: biometricEnabled,
        errorMessage: null,
        failedAttempts: 0,
      );
    } catch (e) {
      debugPrint('Auth bootstrap failed: $e');
      // Always set isBootstrapping to false so the user can reach the login screen
      await _waitForMinimumSplashDuration(startedAt);
      state = state.copyWith(isBootstrapping: false, isAuthenticated: false);
    }
  }

  Future<void> _waitForMinimumSplashDuration(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  /// Logs in using a local demo profile (no backend required).
  Future<void> loginDemo({String? employeeNumber}) async {
    final emp = (employeeNumber ?? '').trim().isEmpty
        ? 'EMP-00123'
        : employeeNumber!.trim();
    final profile = StaffProfileModel(
      id: 'demo_staff_1',
      employeeNumber: emp,
      fullName: 'John Banda',
      department: 'Operations',
      grade: 'G3',
      email: 'john.banda@rbm.mw',
      phoneMasked: '+265 ** *** ****',
      status: 'ACTIVE',
    );

    await _persistAuth('demo_access_$emp', 'demo_refresh_$emp', profile);
    state = state.copyWith(
      isBootstrapping: false,
      isAuthenticated: true,
      staffProfile: profile,
      biometricEnabled: false,
      failedAttempts: 0,
      errorMessage: null,
    );
  }

  /// Performs activation (step 1) which validates staff identity.
  Future<void> activateStep1({
    required String employeeNumber,
    required String temporaryPin,
  }) async {
    if (AppConfig.isDemo) return;
    state = state.copyWith(errorMessage: null);
    await _repository.activate(
      AuthActivateRequestModel(
        employeeNumber: employeeNumber,
        temporaryPin: temporaryPin,
      ),
    );
  }

  /// Performs activation (step 2) which sets the new PIN and returns tokens.
  Future<void> activateStep2({
    required String employeeNumber,
    required String temporaryPin,
    required String newPin,
  }) async {
    if (AppConfig.isDemo) {
      await loginDemo(employeeNumber: employeeNumber);
      return;
    }
    state = state.copyWith(errorMessage: null);
    final resp = await _repository.activate(
      AuthActivateRequestModel(
        employeeNumber: employeeNumber,
        temporaryPin: temporaryPin,
        newPin: newPin,
      ),
    );
    await _persistAuth(resp.accessToken, resp.refreshToken, resp.staffProfile);
    state = state.copyWith(
      isAuthenticated: true,
      staffProfile: resp.staffProfile,
      failedAttempts: 0,
      errorMessage: null,
    );
  }

  /// Logs in via PIN.
  Future<void> loginPin({
    required String employeeNumber,
    required String pin,
  }) async {
    if (AppConfig.isDemo) {
      await loginDemo(employeeNumber: employeeNumber);
      return;
    }
    if (state.isLocked) {
      state = state.copyWith(
        errorMessage: 'Account locked — contact HR to unlock.',
      );
      return;
    }

    state = state.copyWith(errorMessage: null);
    try {
      final resp = await _repository.login(
        AuthLoginRequestModel(employeeNumber: employeeNumber, pin: pin),
      );
      await _persistAuth(
        resp.accessToken,
        resp.refreshToken,
        resp.staffProfile,
      );
      state = state.copyWith(
        isAuthenticated: true,
        staffProfile: resp.staffProfile,
        failedAttempts: 0,
        errorMessage: null,
      );
    } catch (e) {
      final nextAttempts = state.failedAttempts + 1;
      state = state.copyWith(
        failedAttempts: nextAttempts,
        errorMessage: nextAttempts >= 5
            ? 'Account locked — contact HR to unlock.'
            : 'Invalid credentials. ${5 - nextAttempts} attempts remaining.',
      );
    }
  }

  /// Attempts biometric login.
  Future<void> loginBiometric({
    required String employeeNumber,
    required String pinFallback,
  }) async {
    final supported = await _biometric.isSupported();
    if (!supported || !state.biometricEnabled) return;

    final ok = await _biometric.authenticate(reason: 'Authenticate to log in');
    if (!ok) return;

    final resp = await _repository.login(
      AuthLoginRequestModel(
        employeeNumber: employeeNumber,
        pin: pinFallback,
        biometric: true,
      ),
    );
    await _persistAuth(resp.accessToken, resp.refreshToken, resp.staffProfile);
    state = state.copyWith(
      isAuthenticated: true,
      staffProfile: resp.staffProfile,
      failedAttempts: 0,
      errorMessage: null,
    );
  }

  /// Enables/disables biometric.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.writeBiometricEnabled(enabled);
    state = state.copyWith(biometricEnabled: enabled, errorMessage: null);
  }

  /// Logs out locally (and best-effort remote).
  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _repository.logout(refreshToken: refresh);
      } catch (_) {}
    }
    await _storage.clearTokens();
    await _storage.clearStaffProfileJson();
    state = state.copyWith(
      isAuthenticated: false,
      staffProfile: null,
      failedAttempts: 0,
      errorMessage: null,
    );
  }

  Future<void> _persistAuth(
    String accessToken,
    String refreshToken,
    StaffProfileModel profile,
  ) async {
    await _storage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _storage.writeStaffProfileJson(jsonEncode(profile.toJson()));
  }
}

/// Provider for auth state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final storage = ref.read(secureStorageServiceProvider);
  final biometric = ref.read(biometricServiceProvider);
  return AuthNotifier(repo, storage, biometric);
});
