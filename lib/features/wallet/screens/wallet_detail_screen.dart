import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../../card/providers/card_provider.dart';
import '../../card/widgets/club_card_widget.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/monthly_summary_model.dart';
import '../providers/wallet_provider.dart';
import '../widgets/allocation_history_list.dart';
import '../widgets/mini_statement_widget.dart';
import '../widgets/spending_chart_widget.dart';

/// Wallet detail screen.
class WalletDetailScreen extends ConsumerWidget {
  /// Creates a wallet detail screen.
  const WalletDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthly = ref.watch(walletMonthlySummaryProvider);
    final history = ref.watch(allocationHistoryProvider);
    final virtualCard = ref.watch(virtualCardProvider);
    final auth = ref.watch(authProvider);

    return OfflineBanner(
      child: RbmTabScaffold(
        currentIndex: 3,
        appBar: const RbmAppBar(
          title: AppStrings.walletTitle,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFF9FBFF),
                      AppColors.backgroundLight,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE8FF).withValues(alpha: 0.38),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            monthly.when(
              data: (m) => ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 84),
                children: [
                  virtualCard.when(
                    data: (card) => ClubCardWidget(
                      card: card,
                      staffDepartment: auth.staffProfile?.department,
                      staffGrade: auth.staffProfile?.grade,
                      availableBalance: m.remainingAmount,
                      showQrPanel: false,
                      showRbmLogo: true,
                    ),
                    loading: () => const _WalletHeroLoading(),
                    error: (_, _) => _WalletFallbackHero(summary: m),
                  ),
                  const SizedBox(height: 12),
                  _WalletSummaryPanel(summary: m),
                  const SizedBox(height: 12),
                  SpendingChartWidget(
                    spent: m.spentAmount,
                    remaining: m.remainingAmount,
                  ),
                  const SizedBox(height: 12),
                  history.when(
                    data: (items) => AllocationHistoryList(items: items),
                    loading: () => const _HistoryLoading(),
                    error: (e, _) =>
                        AppErrorWidget(message: 'Failed to load history: $e'),
                  ),
                  const SizedBox(height: 12),
                  const MiniStatementWidget(),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  AppErrorWidget(message: 'Failed to load wallet: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletSummaryPanel extends ConsumerWidget {
  const _WalletSummaryPanel({required this.summary});

  final MonthlySummaryModel summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maskAmounts = ref.watch(appSettingsProvider).amountMasking;
    final usageRatio = summary.allocatedAmount <= 0
        ? 0.0
        : (summary.spentAmount / summary.allocatedAmount).clamp(0.0, 1.0);
    final daysRemaining = summary.periodEnd
        .toLocal()
        .difference(DateTime.now())
        .inDays;

    String money(double value) {
      if (maskAmounts) return 'MWK ******';
      return CurrencyFormatter.format(value).replaceFirst('.00', '');
    }

    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Allocated',
                  value: money(summary.allocatedAmount),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Spent',
                  value: money(summary.spentAmount),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Remaining',
                  value: money(summary.remainingAmount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usage this cycle',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(usageRatio * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warningOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usageRatio,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EDF6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.warningOrange,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Resets on ${Formatters.formatDate(summary.periodEnd)} | '
            '${daysRemaining < 0 ? 0 : daysRemaining} days remaining',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WalletHeroLoading extends StatelessWidget {
  const _WalletHeroLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _WalletFallbackHero extends ConsumerWidget {
  const _WalletFallbackHero({required this.summary});

  final MonthlySummaryModel summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).staffProfile;
    final maskAmounts = ref.watch(appSettingsProvider).amountMasking;

    final balance = maskAmounts
        ? 'MWK ******'
        : CurrencyFormatter.format(
            summary.remainingAmount,
          ).replaceFirst('.00', '');
    final title = (profile?.fullName ?? 'Staff Member').trim();
    final subtitle = (profile?.employeeNumber ?? 'EMP-00000').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reserve Bank of Malawi'.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 10,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            balance,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 30,
            ),
          ),
          Text(
            'Available balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
