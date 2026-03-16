import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_transactions_preview.dart';

/// Home dashboard screen.
class HomeScreen extends ConsumerWidget {
  /// Creates a home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final summary = ref.watch(dashboardProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: RbmAppBar(
          title: AppStrings.dashboardTitle,
          unreadCount: 0,
          onNotificationsTap: () => context.go(RouteNames.notifications),
          actions: [
            IconButton(
              onPressed: () => context.go(RouteNames.profile),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: summary.when(
          data: (data) => RefreshIndicator(
            onRefresh: () async => ref.refresh(dashboardProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Welcome, ${auth.staffProfile?.fullName ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${auth.staffProfile?.employeeNumber ?? ''} · ${auth.staffProfile?.grade ?? ''} · ${auth.staffProfile?.department ?? ''}',
                ),
                const SizedBox(height: 16),
                BalanceSummaryCard(
                  currentBalance: data.currentBalance,
                  monthlyAllocation: data.monthlyAllocation,
                  spentAmount: data.spentAmount,
                  remainingAmount: data.remainingAmount,
                  nextReset: data.nextReset,
                ),
                const SizedBox(height: 12),
                const QuickActionsRow(),
                const SizedBox(height: 12),
                RecentTransactionsPreview(transactions: data.recentTransactions),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: 'Failed to load dashboard: $e',
            onRetry: () => ref.refresh(dashboardProvider),
          ),
        ),
      ),
    );
  }
}

