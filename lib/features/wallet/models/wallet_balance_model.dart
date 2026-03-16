/// Wallet balance model.
class WalletBalanceModel {
  /// Creates wallet balance.
  const WalletBalanceModel({required this.currentBalance});

  /// Current balance.
  final double currentBalance;

  /// Parses JSON.
  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}

