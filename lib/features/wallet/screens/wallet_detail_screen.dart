import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../providers/wallet_provider.dart';
import '../widgets/allocation_history_list.dart';
import '../widgets/mini_statement_widget.dart';
import '../widgets/spending_chart_widget.dart';
import '../widgets/wallet_cycle_card.dart';

/// Wallet detail screen.
class WalletDetailScreen extends ConsumerWidget {
  /// Creates a wallet detail screen.
  const WalletDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthly = ref.watch(walletMonthlySummaryProvider);
    final history = ref.watch(allocationHistoryProvider);

    return OfflineBanner(
      child: RbmTabScaffold(
        currentIndex: 3,
        appBar: const RbmAppBar(title: AppStrings.walletTitle),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            monthly.when(
              data: (m) => Column(
                children: [
                  WalletCycleCard(summary: m),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: SpendingChartWidget(
                      spent: m.spentAmount,
                      remaining: m.remainingAmount,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  AppErrorWidget(message: 'Failed to load wallet: $e'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: history.when(
                data: (items) => AllocationHistoryList(items: items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    AppErrorWidget(message: 'Failed to load history: $e'),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 72),
              child: MiniStatementWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
