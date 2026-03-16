import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_summary_model.dart';

/// Provider for dashboard repository.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return DashboardRepository(api);
});

/// Dashboard summary provider.
final dashboardProvider = FutureProvider<DashboardSummaryModel>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.fetchSummary();
});

