import '../../profile/models/staff_profile_model.dart';

/// Auth response model.
class AuthResponseModel {
  /// Creates an auth response.
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.staffProfile,
  });

  /// JWT access token.
  final String accessToken;

  /// JWT refresh token.
  final String refreshToken;

  /// Staff profile.
  final StaffProfileModel staffProfile;

  /// Parses JSON.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      staffProfile: StaffProfileModel.fromJson(
        (json['staffProfile'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
      ),
    );
  }
}

