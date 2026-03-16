import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../providers/transaction_provider.dart';
import '../widgets/receipt_detail_widget.dart';
import '../models/receipt_model.dart';

/// Receipt screen.
class ReceiptScreen extends ConsumerWidget {
  /// Creates receipt screen.
  const ReceiptScreen({super.key, required this.receiptId});

  /// Receipt id.
  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.watch(receiptProvider(receiptId));

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Receipt'),
        body: receipt.when(
          data: (r) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ReceiptDetailWidget(receipt: r),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Printing.layoutPdf(onLayout: (_) => _buildPdf(r)),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Print / Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final bytes = await _buildPdf(r);
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [
                              XFile.fromData(
                                bytes,
                                mimeType: 'application/pdf',
                                name: 'receipt-${r.receiptNumber}.pdf',
                              ),
                            ],
                            subject: 'RBM Receipt ${r.receiptNumber}',
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load receipt: $e'),
        ),
      ),
    );
  }

  Future<Uint8List> _buildPdf(ReceiptModel receipt) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('RBM Club House Receipt', style: pw.TextStyle(fontSize: 18)),
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
