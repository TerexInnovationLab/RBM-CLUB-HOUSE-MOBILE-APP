import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../data/transaction_repository.dart';
import '../models/receipt_model.dart';
import '../models/transaction_model.dart';

/// Transaction repository provider.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return TransactionRepository(api);
});

/// Transactions list provider.
final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  return ref.read(transactionRepositoryProvider).fetchTransactions();
});

/// Transaction detail provider.
final transactionDetailProvider =
    FutureProvider.family<TransactionModel, String>((ref, id) async {
  return ref.read(transactionRepositoryProvider).fetchTransactionDetail(id);
});

/// Receipt provider.
final receiptProvider = FutureProvider.family<ReceiptModel, String>((ref, receiptId) async {
  return ref.read(transactionRepositoryProvider).fetchReceipt(receiptId);
});

