/// Monthly allocation summary model.
class MonthlySummaryModel {
  /// Creates a monthly summary.
  const MonthlySummaryModel({
    required this.allocatedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Allocated amount.
  final double allocatedAmount;

  /// Spent amount.
  final double spentAmount;

  /// Remaining amount.
  final double remainingAmount;

  /// Period start (UTC).
  final DateTime periodStart;

  /// Period end (UTC).
  final DateTime periodEnd;

  /// Parses JSON.
  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      allocatedAmount: (json['allocatedAmount'] as num?)?.toDouble() ?? 0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      periodStart: DateTime.tryParse((json['periodStart'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      periodEnd: DateTime.tryParse((json['periodEnd'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

