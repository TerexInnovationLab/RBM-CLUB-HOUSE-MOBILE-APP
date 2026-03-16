import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';

/// Repository for authentication API calls.
class AuthRepository {
  /// Creates an auth repository.
  const AuthRepository(this._api);

  final ApiService _api;

  /// Activates a staff account (step 1 or 2 depending on `newPin`).
  Future<AuthResponseModel> activate(AuthActivateRequestModel request) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      ApiEndpoints.authActivate,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data ?? const {});
  }

  /// Logs in using PIN (or biometric flag).
  Future<AuthResponseModel> login(AuthLoginRequestModel request) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data ?? const {});
  }

  /// Logs out.
  Future<void> logout({required String refreshToken, bool logoutAllDevices = false}) async {
    try {
      await _api.dio.post<Map<String, dynamic>>(
        ApiEndpoints.authLogout,
        data: {
          'refreshToken': refreshToken,
          'logoutAllDevices': logoutAllDevices,
        },
      );
    } on DioException {
      rethrow;
    }
  }
}

