import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../../profile/models/staff_profile_model.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';

/// Repository for authentication API calls.
class AuthRepository {
  /// Creates an auth repository.
  const AuthRepository(this._api);

  final ApiService _api;

  AuthResponseModel _demoAuth(String employeeNumber) {
    final emp = employeeNumber.trim().isEmpty ? 'EMP-00123' : employeeNumber.trim();
    return AuthResponseModel(
      accessToken: 'demo_access_$emp',
      refreshToken: 'demo_refresh_$emp',
      staffProfile: StaffProfileModel(
        id: 'demo_staff_1',
        employeeNumber: emp,
        fullName: 'John Banda',
        department: 'Operations',
        grade: 'G3',
        email: 'john.banda@rbm.mw',
        phoneMasked: '+265 ** *** ****',
        status: 'ACTIVE',
      ),
    );
  }

  /// Activates a staff account (step 1 or 2 depending on `newPin`).
  Future<AuthResponseModel> activate(AuthActivateRequestModel request) async {
    if (AppConfig.isDemo || _api.dio.options.baseUrl.isEmpty) {
      return _demoAuth(request.employeeNumber);
    }
    final response = await _api.dio.post<Map<String, dynamic>>(
      ApiEndpoints.authActivate,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data ?? const {});
  }

  /// Logs in using PIN (or biometric flag).
  Future<AuthResponseModel> login(AuthLoginRequestModel request) async {
    if (AppConfig.isDemo || _api.dio.options.baseUrl.isEmpty) {
      return _demoAuth(request.employeeNumber);
    }
    final response = await _api.dio.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data ?? const {});
  }

  /// Logs out.
  Future<void> logout({required String refreshToken, bool logoutAllDevices = false}) async {
    try {
      if (AppConfig.isDemo || _api.dio.options.baseUrl.isEmpty) return;
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
