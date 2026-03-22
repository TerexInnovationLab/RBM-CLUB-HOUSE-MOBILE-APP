import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/receipt_model.dart';

/// Receipt details widget.
class ReceiptDetailWidget extends ConsumerWidget {
  /// Creates receipt details widget.
  const ReceiptDetailWidget({super.key, required this.receipt});

  /// Receipt.
  final ReceiptModel receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final maskAmounts = settings.amountMasking;
    final hasItems = receipt.items.isNotEmpty;
    final subtotal = receipt.items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    String money(double value) {
      return maskAmounts ? 'MWK ******' : CurrencyFormatter.format(value);
    }

    String lineTotal(double value) {
      return maskAmounts
          ? '******'
          : CurrencyFormatter.format(value).replaceFirst('MWK ', '');
    }

    return RbmCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Reserve Bank of Malawi'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  receipt.posLocation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _HeaderTag(label: receipt.receiptNumber),
                    _HeaderTag(
                      label: Formatters.formatLocalDateTime(receipt.occurredAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
            child: Row(
              children: [
                Text(
                  'Transaction ref',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.inactive),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    receipt.salesTransactionId,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        'Qty'.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 82,
                      child: Text(
                        'Total'.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!hasItems)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'No line items available.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  for (final item in receipt.items) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'x${item.quantity}',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 82,
                          child: Text(
                            lineTotal(item.lineTotal),
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: _DashedDivider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 12),
            child: Column(
              children: [
                _row(context, 'Subtotal', money(subtotal)),
                _row(
                  context,
                  'Total charged',
                  money(receipt.totalAmount),
                  emphasize: true,
                ),
                const SizedBox(height: 8),
                _row(context, 'Balance before', money(receipt.balanceBefore)),
                _row(context, 'Balance after', money(receipt.balanceAfter)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColors.inactive);
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

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.88),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
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
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
