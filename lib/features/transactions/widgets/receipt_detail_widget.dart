import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../models/receipt_model.dart';

/// Receipt details widget.
class ReceiptDetailWidget extends StatelessWidget {
  /// Creates receipt details widget.
  const ReceiptDetailWidget({super.key, required this.receipt});

  /// Receipt.
  final ReceiptModel receipt;

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.primaryBlue,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Reserve Bank of Malawi'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  receipt.posLocation,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  receipt.receiptNumber,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatLocalDateTime(receipt.occurredAt),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(13, 10, 13, 10),
            child: _DashedDivider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaction ref', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inactive)),
                Text(
                  receipt.salesTransactionId,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: _DashedDivider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Item'.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.borderGray),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        'Qty'.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.borderGray),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: Text(
                        'Total'.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.borderGray),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final item in receipt.items) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '×${item.quantity}',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 64,
                        child: Text(
                          CurrencyFormatter.format(item.lineTotal).replaceFirst('MWK ', ''),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: _DashedDivider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: Column(
              children: [
                _row(context, 'Total charged', CurrencyFormatter.format(receipt.totalAmount), emphasize: true),
                const SizedBox(height: 8),
                _row(context, 'Balance before', CurrencyFormatter.format(receipt.balanceBefore)),
                _row(context, 'Balance after', CurrencyFormatter.format(receipt.balanceAfter)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool emphasize = false}) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inactive);
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: emphasize ? AppColors.primaryBlue : AppColors.textSecondary,
          fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
        );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedDividerPainter(color: AppColors.borderGray),
      child: const SizedBox(height: 1),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dashWidth).clamp(0, size.width), 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedDividerPainter oldDelegate) => oldDelegate.color != color;
}
