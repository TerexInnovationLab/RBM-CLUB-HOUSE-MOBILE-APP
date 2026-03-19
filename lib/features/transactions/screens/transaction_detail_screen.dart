import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../profile/models/app_settings_model.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../providers/transaction_provider.dart';

/// Transaction detail screen.
class TransactionDetailScreen extends ConsumerWidget {
  /// Creates transaction detail screen.
  const TransactionDetailScreen({super.key, required this.transactionId});

  /// Transaction id.
  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(transactionDetailProvider(transactionId));
    final settings = ref.watch(appSettingsProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Transaction'),
        body: tx.when(
          data: (t) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RbmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.merchant,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      settings.amountMasking
                          ? 'Amount: MWK ******'
                          : 'Amount: ${CurrencyFormatter.format(t.amount)}',
                    ),
                    Text('Status: ${t.status}'),
                    Text('Type: ${t.transactionType}'),
                    Text(
                      'Occurred: ${Formatters.formatLocalDateTime(t.occurredAt)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  if (settings.confirmationPrompts) {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => const ConfirmationDialog(
                        title: 'Open receipt',
                        message: 'Do you want to continue to receipt details?',
                        confirmLabel: 'Open',
                      ),
                    );
                    if (ok != true || !context.mounted) return;
                  }

                  final modeQuery = switch (settings.receiptBehavior) {
                    ReceiptBehavior.ask => '',
                    ReceiptBehavior.download => '?mode=download',
                    ReceiptBehavior.share => '?mode=share',
                  };
                  context.go('/receipts/${t.id}$modeQuery');
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Receipt'),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load: $e'),
        ),
      ),
    );
  }
}
