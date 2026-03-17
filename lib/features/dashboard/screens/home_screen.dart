import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
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
      child: RbmTabScaffold(
        currentIndex: 0,
        appBar: _HomeAppBar(
          fullName: auth.staffProfile?.fullName ?? 'Staff',
          onNotificationsTap: () => context.go(RouteNames.notifications),
          onProfileTap: () => context.go(RouteNames.profile),
        ),
        body: summary.when(
          data: (data) => RefreshIndicator(
            onRefresh: () async => ref.refresh(dashboardProvider.future),
            child: Container(
              color: AppColors.backgroundLight,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 350),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 20,
                          offset: Offset(0, 12),
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BalanceSummaryCard(
                          currentBalance: data.currentBalance,
                          monthlyAllocation: data.monthlyAllocation,
                          spentAmount: data.spentAmount,
                          remainingAmount: data.remainingAmount,
                          nextReset: data.nextReset,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                        const SizedBox(height: 14),
                        const QuickActionsRow(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  RecentTransactionsPreview(
                    transactions: data.recentTransactions,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
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

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar({
    required this.fullName,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final String fullName;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 16,
      backgroundColor: AppColors.primaryBlue,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      title: _HomeHeaderContent(
        fullName: fullName,
        onNotificationsTap: onNotificationsTap,
        onProfileTap: onProfileTap,
      ),
    );
  }
}

class _HomeHeaderContent extends StatelessWidget {
  const _HomeHeaderContent({
    required this.fullName,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final String fullName;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  String get _firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get _initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'RB';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: Colors.white,
          child: Text(
            _initials,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Hi, $_firstName!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(icon: Icons.tune_rounded, onTap: onProfileTap),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}
