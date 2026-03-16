/// Transaction item model.
class TransactionItemModel {
  /// Creates a transaction item.
  const TransactionItemModel({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  /// Item name.
  final String itemName;

  /// Quantity.
  final int quantity;

  /// Unit price.
  final double unitPrice;

  /// Line total.
  final double lineTotal;

  /// Parses JSON.
  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      itemName: (json['itemName'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

