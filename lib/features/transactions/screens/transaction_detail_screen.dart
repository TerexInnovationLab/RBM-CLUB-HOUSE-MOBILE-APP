import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../profile/models/app_settings_model.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

/// Transaction detail screen.
class TransactionDetailScreen extends ConsumerWidget {
  /// Creates transaction detail screen.
  const TransactionDetailScreen({super.key, required this.transactionId});

  /// Transaction id.
  final String transactionId;

  bool _isCredit(TransactionModel t) {
    final type = t.transactionType.toUpperCase();
    return type.contains('ALLOCATION') ||
        type.contains('CREDIT') ||
        type.contains('TOPUP');
  }

  String _statusLabel(String status) {
    final normalized = status.trim().toUpperCase();
    if (normalized.isEmpty) return 'Pending';
    return switch (normalized) {
      'APPROVED' => 'Approved',
      'DECLINED' => 'Declined',
      'REVERSED' => 'Reversed',
      _ => '${normalized[0]}${normalized.substring(1).toLowerCase()}',
    };
  }

  Color _statusColor(String status) {
    final normalized = status.trim().toUpperCase();
    return switch (normalized) {
      'APPROVED' => AppColors.successGreen,
      'DECLINED' => AppColors.dangerRed,
      'REVERSED' => AppColors.warningOrange,
      _ => AppColors.textSecondary,
    };
  }

  String _typeLabel(String type) {
    final normalized = type.trim().toUpperCase();
    if (normalized.isEmpty) return 'Transaction';
    if (normalized.contains('ALLOCATION')) return 'Allocation';
    if (normalized.contains('TOPUP')) return 'Top Up';
    if (normalized.contains('CREDIT')) return 'Credit';
    return 'Purchase';
  }

  IconData _typeIcon(String type) {
    final normalized = type.trim().toUpperCase();
    if (normalized.contains('ALLOCATION') ||
        normalized.contains('TOPUP') ||
        normalized.contains('CREDIT')) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(transactionDetailProvider(transactionId));
    final settings = ref.watch(appSettingsProvider);

    return OfflineBanner(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: const RbmAppBar(title: 'Transaction', centerTitle: true),
        body: tx.when(
          data: (t) {
            final isCredit = _isCredit(t);
            final merchant = t.merchant.trim().isEmpty
                ? 'Transaction'
                : t.merchant.trim();
            final amount = settings.amountMasking
                ? 'MWK ******'
                : CurrencyFormatter.format(t.amount);
            final signedAmount = '${isCredit ? '+' : '-'} $amount';
            final statusLabel = _statusLabel(t.status);
            final statusColor = _statusColor(t.status);
            final typeLabel = _typeLabel(t.transactionType);
            final typeIcon = _typeIcon(t.transactionType);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                _TransactionHeroCard(
                  merchant: merchant,
                  dateTimeLabel: Formatters.formatLocalDateTime(t.occurredAt),
                  statusLabel: statusLabel,
                  statusColor: statusColor,
                  amountLabel: signedAmount,
                  amountColor: isCredit
                      ? const Color(0xFF96F5A9)
                      : Colors.white,
                  typeLabel: typeLabel,
                  typeIcon: typeIcon,
                ),
                const SizedBox(height: 14),
                RbmCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(label: 'Transaction ID', value: t.id),
                      const _DetailDivider(),
                      _DetailRow(label: 'Merchant', value: merchant),
                      const _DetailDivider(),
                      _DetailRow(label: 'Type', value: typeLabel),
                      const _DetailDivider(),
                      _DetailRow(label: 'Status', value: statusLabel),
                      const _DetailDivider(),
                      _DetailRow(
                        label: 'Date & Time',
                        value: Formatters.formatLocalDateTime(t.occurredAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                RbmCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Open the full receipt to view item breakdown and save or share it.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            if (settings.confirmationPrompts) {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => const ConfirmationDialog(
                                  title: 'Open receipt',
                                  message:
                                      'Do you want to continue to receipt details?',
                                  confirmLabel: 'Open',
                                ),
                              );
                              if (ok != true || !context.mounted) return;
                            }

                            final modeQuery =
                                switch (settings.receiptBehavior) {
                                  ReceiptBehavior.ask => '',
                                  ReceiptBehavior.download => '?mode=download',
                                  ReceiptBehavior.share => '?mode=share',
                                };
                            context.push('/receipts/${t.id}$modeQuery');
                          },
                          icon: const Icon(Icons.receipt_long_rounded),
                          label: const Text('View Receipt'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load: $e'),
        ),
      ),
    );
  }
}

class _TransactionHeroCard extends StatelessWidget {
  const _TransactionHeroCard({
    required this.merchant,
    required this.dateTimeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.amountLabel,
    required this.amountColor,
    required this.typeLabel,
    required this.typeIcon,
  });

  final String merchant;
  final String dateTimeLabel;
  final String statusLabel;
  final Color statusColor;
  final String amountLabel;
  final Color amountColor;
  final String typeLabel;
  final IconData typeIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A003A8F),
            blurRadius: 20,
            offset: Offset(0, 12),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateTimeLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            amountLabel,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
              fontSize: 31,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            typeLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, color: AppColors.borderGray),
    );
  }
}
