import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/dashboard_summary_model.dart';

/// Dashboard repository.
class DashboardRepository {
  /// Creates a dashboard repository.
  const DashboardRepository(this._api);

  final ApiService _api;

  /// Fetches dashboard summary.
  Future<DashboardSummaryModel> fetchSummary() async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return DashboardSummaryModel(
        currentBalance: 12500,
        monthlyAllocation: 20000,
        spentAmount: 7500,
        remainingAmount: 12500,
        nextReset: DateTime(DateTime.now().year, DateTime.now().month + 1, 1),
        recentTransactions: [
          TransactionModel(
            id: 't1',
            merchant: 'Club House A',
            amount: 850,
            transactionType: 'TRANSACTION',
            status: 'APPROVED',
            occurredAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
          ),
          TransactionModel(
            id: 't2',
            merchant: 'Club House B',
            amount: 1200,
            transactionType: 'TRANSACTION',
            status: 'APPROVED',
            occurredAt: DateTime.now().toUtc().subtract(const Duration(days: 2)),
          ),
          TransactionModel(
            id: 't3',
            merchant: 'Monthly Credit',
            amount: 20000,
            transactionType: 'ALLOCATION',
            status: 'APPROVED',
            occurredAt: DateTime.now().toUtc().subtract(const Duration(days: 10)),
          ),
        ],
      );
    }

    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.dashboardSummary);
    return DashboardSummaryModel.fromJson(resp.data ?? const {});
  }
}

