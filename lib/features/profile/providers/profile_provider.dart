import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';
import '../models/staff_profile_model.dart';
import '../models/trusted_device_model.dart';

/// Profile repository provider.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return ProfileRepository(api);
});

/// Staff profile provider (from auth storage, fallback to API).
final staffProfileProvider = Provider<StaffProfileModel?>((ref) {
  return ref.watch(authProvider).staffProfile;
});

/// Trusted devices provider.
final trustedDevicesProvider = FutureProvider<List<TrustedDeviceModel>>((ref) async {
  return ref.read(profileRepositoryProvider).fetchTrustedDevices();
});

