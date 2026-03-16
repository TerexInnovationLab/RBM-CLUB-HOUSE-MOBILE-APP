import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../models/staff_profile_model.dart';
import '../models/trusted_device_model.dart';

/// Profile repository.
class ProfileRepository {
  /// Creates profile repository.
  const ProfileRepository(this._api);

  final ApiService _api;

  /// Fetches staff profile.
  Future<StaffProfileModel> fetchProfile() async {
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.profile);
    return StaffProfileModel.fromJson(resp.data ?? const {});
  }

  /// Fetches trusted devices.
  Future<List<TrustedDeviceModel>> fetchTrustedDevices() async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return [
        TrustedDeviceModel(
          deviceId: 'd1',
          deviceName: 'This device',
          platform: 'android',
          lastSeenAt: DateTime.now().toUtc(),
        ),
      ];
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.trustedDevices);
    final data = (resp.data?['data'] as List?) ?? const [];
    return data
        .whereType<Map>()
        .map((e) => TrustedDeviceModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}

