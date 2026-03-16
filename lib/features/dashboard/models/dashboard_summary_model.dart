import '../../transactions/models/transaction_model.dart';

/// Dashboard summary model.
class DashboardSummaryModel {
  /// Creates a dashboard summary.
  const DashboardSummaryModel({
    required this.currentBalance,
    required this.monthlyAllocation,
    required this.spentAmount,
    required this.remainingAmount,
    required this.nextReset,
    required this.recentTransactions,
  });

  /// Current balance.
  final double currentBalance;

  /// Monthly allocation.
  final double monthlyAllocation;

  /// Spent amount.
  final double spentAmount;

  /// Remaining credit.
  final double remainingAmount;

  /// Next reset date (local).
  final DateTime nextReset;

  /// Recent transactions.
  final List<TransactionModel> recentTransactions;

  /// Parses JSON.
  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final list = (json['recentTransactions'] as List?) ?? const [];
    return DashboardSummaryModel(
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
      monthlyAllocation: (json['monthlyAllocation'] as num?)?.toDouble() ?? 0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      nextReset: DateTime.tryParse((json['nextReset'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      recentTransactions: list
          .whereType<Map>()
          .map((e) => TransactionModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

