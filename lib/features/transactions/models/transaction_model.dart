/// Transaction model.
class TransactionModel {
  /// Creates a transaction.
  const TransactionModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.transactionType,
    required this.status,
    required this.occurredAt,
  });

  /// Transaction id.
  final String id;

  /// Merchant / location.
  final String merchant;

  /// Amount.
  final double amount;

  /// Transaction type (e.g., TRANSACTION, ALLOCATION).
  final String transactionType;

  /// Status (e.g., APPROVED, DECLINED).
  final String status;

  /// Occurred at (UTC).
  final DateTime occurredAt;

  /// Parses JSON.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      merchant: (json['merchant'] ?? json['posLocation'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      transactionType: (json['transactionType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      occurredAt: DateTime.tryParse((json['occurredAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

