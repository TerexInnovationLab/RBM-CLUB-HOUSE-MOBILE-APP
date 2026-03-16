import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../models/allocation_history_model.dart';
import '../models/monthly_summary_model.dart';
import '../models/wallet_balance_model.dart';

/// Wallet repository.
class WalletRepository {
  /// Creates wallet repository.
  const WalletRepository(this._api);

  final ApiService _api;

  /// Fetches wallet balance.
  Future<WalletBalanceModel> fetchBalance() async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return const WalletBalanceModel(currentBalance: 12500);
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.walletBalance);
    return WalletBalanceModel.fromJson(resp.data ?? const {});
  }

  /// Fetches monthly summary.
  Future<MonthlySummaryModel> fetchMonthlySummary() async {
    if (_api.dio.options.baseUrl.isEmpty) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1).toUtc();
      final end = DateTime(now.year, now.month + 1, 0).toUtc();
      return MonthlySummaryModel(
        allocatedAmount: 20000,
        spentAmount: 7500,
        remainingAmount: 12500,
        periodStart: start,
        periodEnd: end,
      );
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.walletMonthlySummary);
    return MonthlySummaryModel.fromJson(resp.data ?? const {});
  }

  /// Fetches allocation history.
  Future<List<AllocationHistoryItemModel>> fetchAllocationHistory() async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return [
        AllocationHistoryItemModel(
          id: 'a1',
          amount: 20000,
          allocatedAt: DateTime.now().toUtc().subtract(const Duration(days: 30)),
          periodLabel: 'Last month',
        ),
        AllocationHistoryItemModel(
          id: 'a2',
          amount: 20000,
          allocatedAt: DateTime.now().toUtc().subtract(const Duration(days: 60)),
          periodLabel: '2 months ago',
        ),
      ];
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.walletAllocationHistory);
    final data = (resp.data?['data'] as List?) ?? const [];
    return data
        .whereType<Map>()
        .map((e) => AllocationHistoryItemModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}

