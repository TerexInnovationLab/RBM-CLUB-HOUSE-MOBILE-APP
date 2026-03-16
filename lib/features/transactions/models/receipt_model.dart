import 'transaction_item_model.dart';

/// Digital receipt model.
class ReceiptModel {
  /// Creates a receipt model.
  const ReceiptModel({
    required this.receiptId,
    required this.receiptNumber,
    required this.salesTransactionId,
    required this.items,
    required this.totalAmount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.posLocation,
    required this.occurredAt,
  });

  /// Receipt id.
  final String receiptId;

  /// Receipt number.
  final String receiptNumber;

  /// Sales transaction id.
  final String salesTransactionId;

  /// Line items.
  final List<TransactionItemModel> items;

  /// Total amount.
  final double totalAmount;

  /// Balance before.
  final double balanceBefore;

  /// Balance after.
  final double balanceAfter;

  /// POS location.
  final String posLocation;

  /// Timestamp (UTC).
  final DateTime occurredAt;

  /// Parses JSON.
  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?) ?? const [];
    return ReceiptModel(
      receiptId: (json['receiptId'] ?? json['id'] ?? '').toString(),
      receiptNumber: (json['receiptNumber'] ?? '').toString(),
      salesTransactionId: (json['salesTransactionId'] ?? '').toString(),
      items: items
          .whereType<Map>()
          .map((e) => TransactionItemModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
      posLocation: (json['posLocation'] ?? '').toString(),
      occurredAt: DateTime.tryParse((json['occurredAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

