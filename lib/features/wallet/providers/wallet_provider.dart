import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../data/wallet_repository.dart';
import '../models/allocation_history_model.dart';
import '../models/monthly_summary_model.dart';
import '../models/wallet_balance_model.dart';

/// Wallet repository provider.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return WalletRepository(api);
});

/// Wallet balance provider.
final walletBalanceProvider = FutureProvider<WalletBalanceModel>((ref) async {
  return ref.read(walletRepositoryProvider).fetchBalance();
});

/// Monthly summary provider.
final walletMonthlySummaryProvider = FutureProvider<MonthlySummaryModel>((ref) async {
  return ref.read(walletRepositoryProvider).fetchMonthlySummary();
});

/// Allocation history provider.
final allocationHistoryProvider = FutureProvider<List<AllocationHistoryItemModel>>((ref) async {
  return ref.read(walletRepositoryProvider).fetchAllocationHistory();
});

