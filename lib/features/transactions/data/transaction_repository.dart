import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../models/receipt_model.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

/// Transaction repository.
class TransactionRepository {
  /// Creates transaction repository.
  const TransactionRepository(this._api);

  final ApiService _api;

  /// Fetches transactions list.
  Future<List<TransactionModel>> fetchTransactions({int page = 1, int limit = 20}) async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return List.generate(
        10,
        (i) => TransactionModel(
          id: 'tx_$i',
          merchant: i.isEven ? 'Club House A' : 'Club House B',
          amount: 200 + (i * 50),
          transactionType: 'TRANSACTION',
          status: 'APPROVED',
          occurredAt: DateTime.now().toUtc().subtract(Duration(days: i)),
        ),
      );
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(
      ApiEndpoints.transactions,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = (resp.data?['data'] as List?) ?? const [];
    return data
        .whereType<Map>()
        .map((e) => TransactionModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Fetches transaction detail.
  Future<TransactionModel> fetchTransactionDetail(String id) async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return TransactionModel(
        id: id,
        merchant: 'Club House A',
        amount: 850,
        transactionType: 'TRANSACTION',
        status: 'APPROVED',
        occurredAt: DateTime.now().toUtc().subtract(const Duration(hours: 6)),
      );
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.transactionById(id));
    return TransactionModel.fromJson(resp.data ?? const {});
  }

  /// Fetches a receipt.
  Future<ReceiptModel> fetchReceipt(String receiptId) async {
    if (_api.dio.options.baseUrl.isEmpty) {
      return ReceiptModel(
        receiptId: receiptId,
        receiptNumber: 'RBM-${receiptId.toUpperCase()}',
        salesTransactionId: 'sale_$receiptId',
        items: const [
          TransactionItemModel(itemName: 'Meal', quantity: 1, unitPrice: 500, lineTotal: 500),
          TransactionItemModel(itemName: 'Drink', quantity: 1, unitPrice: 350, lineTotal: 350),
        ],
        totalAmount: 850,
        balanceBefore: 13350,
        balanceAfter: 12500,
        posLocation: 'Club House A',
        occurredAt: DateTime.now().toUtc().subtract(const Duration(hours: 6)),
      );
    }
    final resp = await _api.dio.get<Map<String, dynamic>>(ApiEndpoints.receiptById(receiptId));
    return ReceiptModel.fromJson(resp.data ?? const {});
  }
}

