/// Allocation history item.
class AllocationHistoryItemModel {
  /// Creates an allocation history item.
  const AllocationHistoryItemModel({
    required this.id,
    required this.amount,
    required this.allocatedAt,
    required this.periodLabel,
  });

  /// Id.
  final String id;

  /// Amount.
  final double amount;

  /// Allocation timestamp (UTC).
  final DateTime allocatedAt;

  /// Period label (e.g., "March 2026").
  final String periodLabel;

  /// Parses JSON.
  factory AllocationHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return AllocationHistoryItemModel(
      id: (json['id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      allocatedAt: DateTime.tryParse((json['allocatedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      periodLabel: (json['periodLabel'] ?? '').toString(),
    );
  }
}

