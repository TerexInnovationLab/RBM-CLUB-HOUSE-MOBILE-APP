import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../../card/providers/card_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/mini_statement_widget.dart';
import '../widgets/spending_chart_widget.dart';
import '../widgets/wallet_payment_card.dart';

/// Wallet detail screen.
class WalletDetailScreen extends ConsumerWidget {
  /// Creates a wallet detail screen.
  const WalletDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthly = ref.watch(walletMonthlySummaryProvider);
    final balance = ref.watch(walletBalanceProvider);
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
                  WalletPaymentCard(
                    summary: m,
                    currentBalance:
                        balance.asData?.value.currentBalance ??
                        m.remainingAmount,
                    profile: auth.staffProfile,
                    card: virtualCard.asData?.value,
                  ),
                  const SizedBox(height: 12),
                  SpendingChartWidget(
                    spent: m.spentAmount,
                    remaining: m.remainingAmount,
                  ),
                  const SizedBox(height: 12),
                  const _UpcomingReservationsSection(),
                  const SizedBox(height: 12),
                  const _ClubNoticesSupportSection(),
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

class _UpcomingReservationsSection extends StatelessWidget {
  const _UpcomingReservationsSection();

  List<_ClubReservation> _items() {
    final now = DateTime.now();
    return [
      _ClubReservation(
        title: 'Lunch Table',
        location: 'Main Dining Hall',
        startAt: DateTime(now.year, now.month, now.day, 12, 30),
        status: 'Confirmed',
        icon: Icons.restaurant_rounded,
      ),
      _ClubReservation(
        title: 'Tennis Court 2',
        location: 'Sports Wing',
        startAt: DateTime(now.year, now.month, now.day + 1, 17, 30),
        status: 'Reserved',
        icon: Icons.sports_tennis_rounded,
      ),
      _ClubReservation(
        title: 'Family Pool Slot',
        location: 'Aquatics Deck',
        startAt: DateTime(now.year, now.month, now.day + 3, 10, 0),
        status: 'Upcoming',
        icon: Icons.pool_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming reservations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your next clubhouse bookings and facility slots.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            _ReservationTile(item: items[i]),
            if (i != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ClubNoticesSupportSection extends StatelessWidget {
  const _ClubNoticesSupportSection();

  List<_ClubNotice> _items() {
    final today = DateTime.now();
    return [
      _ClubNotice(
        title: 'Pool maintenance window',
        message:
            'The pool deck closes ${DateFormat('dd MMM').format(today.add(const Duration(days: 1)))} from 14:00 to 16:00 for routine servicing.',
        icon: Icons.pool_rounded,
        accent: AppColors.warningOrange,
      ),
      const _ClubNotice(
        title: 'Guest access reminder',
        message:
            'Guest visits should be registered at reception before entry to the clubhouse facilities.',
        icon: Icons.groups_rounded,
        accent: AppColors.secondaryBlue,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Club notices and support',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Stay informed and reach clubhouse help quickly.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            _NoticeTile(item: items[i]),
            if (i != items.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Open support or browse common clubhouse questions.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(RouteNames.help),
                        icon: const Icon(Icons.support_agent_rounded, size: 18),
                        label: const Text('Help Desk'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.go(RouteNames.faq),
                        icon: const Icon(Icons.quiz_outlined, size: 18),
                        label: const Text('FAQ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  const _ReservationTile({required this.item});

  final _ClubReservation item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.location,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.inactive,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${Formatters.formatDate(item.startAt)} at ${DateFormat('HH:mm').format(item.startAt.toLocal())}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(label: item.status, color: AppColors.successGreen),
        ],
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.item});

  final _ClubNotice item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: item.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClubReservation {
  const _ClubReservation({
    required this.title,
    required this.location,
    required this.startAt,
    required this.status,
    required this.icon,
  });

  final String title;
  final String location;
  final DateTime startAt;
  final String status;
  final IconData icon;
}

class _ClubNotice {
  const _ClubNotice({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accent;
}
