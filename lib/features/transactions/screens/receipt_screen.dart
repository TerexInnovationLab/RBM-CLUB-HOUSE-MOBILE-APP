import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/top_snackbar.dart';
import '../../profile/models/app_settings_model.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/receipt_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/receipt_detail_widget.dart';

/// Receipt screen.
class ReceiptScreen extends ConsumerStatefulWidget {
  /// Creates receipt screen.
  const ReceiptScreen({super.key, required this.receiptId, this.actionMode});

  /// Receipt id.
  final String receiptId;

  /// Optional default action mode from route query.
  final String? actionMode;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _didRunDefaultAction = false;

  @override
  Widget build(BuildContext context) {
    final receipt = ref.watch(receiptProvider(widget.receiptId));
    final settings = ref.watch(appSettingsProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Receipt'),
        body: receipt.when(
          data: (r) {
            final defaultAction = _resolveDefaultBehavior(settings);
            if (!_didRunDefaultAction && defaultAction != ReceiptBehavior.ask) {
              _didRunDefaultAction = true;
              Future<void>.microtask(
                () => _performAction(
                  r,
                  defaultAction,
                  confirm: settings.confirmationPrompts,
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ReceiptDetailWidget(receipt: r),
                const SizedBox(height: 12),
                _ReceiptActionBar(
                  defaultAction: defaultAction,
                  onSave: () => _performAction(
                    r,
                    ReceiptBehavior.download,
                    confirm: settings.confirmationPrompts,
                  ),
                  onShare: () => _performAction(
                    r,
                    ReceiptBehavior.share,
                    confirm: settings.confirmationPrompts,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              AppErrorWidget(message: 'Failed to load receipt: $e'),
        ),
      ),
    );
  }

  ReceiptBehavior _resolveDefaultBehavior(AppSettingsModel settings) {
    return switch (widget.actionMode) {
      'download' => ReceiptBehavior.download,
      'share' => ReceiptBehavior.share,
      _ => settings.receiptBehavior,
    };
  }

  Future<void> _performAction(
    ReceiptModel receipt,
    ReceiptBehavior behavior, {
    required bool confirm,
  }) async {
    if (confirm) {
      final actionLabel = switch (behavior) {
        ReceiptBehavior.download => 'Save',
        ReceiptBehavior.share => 'Share',
        ReceiptBehavior.ask => 'Continue',
      };

      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => ConfirmationDialog(
          title: '$actionLabel receipt',
          message: 'Do you want to $actionLabel this receipt now?',
          confirmLabel: actionLabel,
        ),
      );
      if (ok != true || !mounted) return;
    }

    if (behavior == ReceiptBehavior.download) {
      await Printing.layoutPdf(onLayout: (_) => _buildPdf(receipt));
      if (mounted) {
        TopSnackBar.show(
          context,
          message: 'Receipt export started.',
          tone: TopSnackBarTone.success,
        );
      }
      return;
    }

    if (behavior == ReceiptBehavior.share) {
      final bytes = await _buildPdf(receipt);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/pdf',
              name: 'receipt-${receipt.receiptNumber}.pdf',
            ),
          ],
          subject: 'RBM Receipt ${receipt.receiptNumber}',
        ),
      );
    }
  }

  Future<Uint8List> _buildPdf(ReceiptModel receipt) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'RBM Club House Receipt',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Receipt: ${receipt.receiptNumber}'),
            pw.Text('Location: ${receipt.posLocation}'),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: const ['Item', 'Qty', 'Total'],
              data: [
                for (final item in receipt.items)
                  [
                    item.itemName,
                    '${item.quantity}',
                    CurrencyFormatter.format(item.lineTotal),
                  ],
              ],
            ),
            pw.Divider(),
            pw.Text('Total: ${CurrencyFormatter.format(receipt.totalAmount)}'),
          ],
        ),
      ),
    );
    return doc.save();
  }
}

class _ReceiptActionBar extends StatelessWidget {
  const _ReceiptActionBar({
    required this.defaultAction,
    required this.onSave,
    required this.onShare,
  });

  final ReceiptBehavior defaultAction;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final saveIsPrimary = defaultAction == ReceiptBehavior.download;
    final shareIsPrimary = defaultAction == ReceiptBehavior.share;

    return Row(
      children: [
        Expanded(
          child: saveIsPrimary
              ? FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Print / Save'),
                )
              : OutlinedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Print / Save'),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: shareIsPrimary
              ? FilledButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                )
              : OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
        ),
      ],
    );
  }
}
