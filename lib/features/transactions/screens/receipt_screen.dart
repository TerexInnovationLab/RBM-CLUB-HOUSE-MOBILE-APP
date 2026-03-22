import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
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
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Receipt'),
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.transactions);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Back',
          ),
        ),
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

            return Stack(
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
                  right: -90,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE8FF).withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 146),
                        children: [
                          _ReceiptInfoBanner(receipt: r),
                          const SizedBox(height: 12),
                          ReceiptDetailWidget(receipt: r),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: _ReceiptActionPanel(
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
                    ),
                  ],
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
    final occurredAt = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(receipt.occurredAt.toLocal());
    final subtotal = receipt.items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );
    final totalItems = receipt.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    pw.Widget infoRow(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                label,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              flex: 5,
              child: pw.Text(
                value,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget tableCell(
      String value, {
      pw.TextAlign align = pw.TextAlign.left,
      bool header = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: pw.Text(
          value,
          textAlign: align,
          style: pw.TextStyle(
            fontSize: 8.8,
            fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: header ? PdfColors.grey900 : PdfColors.grey800,
          ),
        ),
      );
    }

    pw.Widget summaryRow(String label, String value, {bool emphasize = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 9.3,
                  fontWeight: emphasize
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9.3,
                fontWeight: emphasize
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        build: (context) => [
          pw.Center(
            child: pw.Container(
              width: 310,
              padding: const pw.EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'RBM CLUB HOUSE',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    receipt.posLocation,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 9.5,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'OFFICIAL RECEIPT',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.8,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.grey400, thickness: 0.8),
                  infoRow('Receipt No.', receipt.receiptNumber),
                  infoRow('Transaction Ref', receipt.salesTransactionId),
                  infoRow('Date', occurredAt),
                  pw.Divider(color: PdfColors.grey400, thickness: 0.8),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(4.2),
                      1: const pw.FlexColumnWidth(1.4),
                      2: const pw.FlexColumnWidth(2.2),
                      3: const pw.FlexColumnWidth(2.8),
                    },
                    border: pw.TableBorder(
                      horizontalInside: const pw.BorderSide(
                        color: PdfColors.grey300,
                        width: 0.6,
                      ),
                      top: const pw.BorderSide(
                        color: PdfColors.grey400,
                        width: 0.8,
                      ),
                      bottom: const pw.BorderSide(
                        color: PdfColors.grey400,
                        width: 0.8,
                      ),
                    ),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey100,
                        ),
                        children: [
                          tableCell('ITEM', header: true),
                          tableCell(
                            'QTY',
                            align: pw.TextAlign.right,
                            header: true,
                          ),
                          tableCell(
                            'PRICE',
                            align: pw.TextAlign.right,
                            header: true,
                          ),
                          tableCell(
                            'TOTAL',
                            align: pw.TextAlign.right,
                            header: true,
                          ),
                        ],
                      ),
                      if (receipt.items.isEmpty)
                        pw.TableRow(
                          children: [
                            tableCell('No items'),
                            tableCell('-', align: pw.TextAlign.right),
                            tableCell('-', align: pw.TextAlign.right),
                            tableCell('-', align: pw.TextAlign.right),
                          ],
                        )
                      else
                        for (final item in receipt.items)
                          pw.TableRow(
                            children: [
                              tableCell(item.itemName),
                              tableCell(
                                '${item.quantity}',
                                align: pw.TextAlign.right,
                              ),
                              tableCell(
                                CurrencyFormatter.format(
                                  item.unitPrice,
                                ).replaceFirst('MWK ', ''),
                                align: pw.TextAlign.right,
                              ),
                              tableCell(
                                CurrencyFormatter.format(
                                  item.lineTotal,
                                ).replaceFirst('MWK ', ''),
                                align: pw.TextAlign.right,
                              ),
                            ],
                          ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  summaryRow('Items', '$totalItems'),
                  summaryRow('Subtotal', CurrencyFormatter.format(subtotal)),
                  summaryRow(
                    'Total Charged',
                    CurrencyFormatter.format(receipt.totalAmount),
                    emphasize: true,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(color: PdfColors.grey400, thickness: 0.8),
                  summaryRow(
                    'Balance Before',
                    CurrencyFormatter.format(receipt.balanceBefore),
                  ),
                  summaryRow(
                    'Balance After',
                    CurrencyFormatter.format(receipt.balanceAfter),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.grey300, thickness: 0.6),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Thank you for visiting RBM Club House.',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 8.8,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'This receipt is system generated.',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return doc.save();
  }
}

class _ReceiptInfoBanner extends StatelessWidget {
  const _ReceiptInfoBanner({required this.receipt});

  final ReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A003A8F),
            blurRadius: 18,
            offset: Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.receiptNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatLocalDateTime(receipt.occurredAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Official',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptActionPanel extends StatelessWidget {
  const _ReceiptActionPanel({
    required this.defaultAction,
    required this.onSave,
    required this.onShare,
  });

  final ReceiptBehavior defaultAction;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receipt Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Save as PDF or share this receipt.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          _ReceiptActionBar(
            defaultAction: defaultAction,
            onSave: onSave,
            onShare: onShare,
          ),
        ],
      ),
    );
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
    final radius = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return Row(
      children: [
        Expanded(
          child: saveIsPrimary
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: radius,
                  ),
                  onPressed: onSave,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Print / Save'),
                )
              : OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: radius,
                    side: const BorderSide(color: AppColors.borderGray),
                    foregroundColor: AppColors.primaryBlue,
                  ),
                  onPressed: onSave,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Print / Save'),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: shareIsPrimary
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: radius,
                  ),
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                )
              : OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: radius,
                    side: const BorderSide(color: AppColors.borderGray),
                    foregroundColor: AppColors.primaryBlue,
                  ),
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
        ),
      ],
    );
  }
}
