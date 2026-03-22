import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/virtual_card_model.dart';

/// Club virtual card widget.
class ClubCardWidget extends StatelessWidget {
  /// Creates a club card widget.
  const ClubCardWidget({
    super.key,
    required this.card,
    this.staffDepartment,
    this.staffGrade,
    this.availableBalance,
    this.showQrPanel = true,
    this.showRbmLogo = false,
  });

  /// Virtual card.
  final VirtualCardModel card;

  final String? staffDepartment;
  final String? staffGrade;
  final double? availableBalance;
  final bool showQrPanel;
  final bool showRbmLogo;

  String _maskedToken() {
    final src = card.cardId.isEmpty ? card.qrPayload : card.cardId;
    final last4 = src.length >= 4 ? src.substring(src.length - 4) : src;
    return 'TKN-********$last4'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final deptGrade = [
      if ((staffGrade ?? '').trim().isNotEmpty) staffGrade!.trim(),
      if ((staffDepartment ?? '').trim().isNotEmpty) staffDepartment!.trim(),
    ].join(' - ');

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.primaryBlue,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reserve Bank of Malawi'.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'MyClub Card',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: showRbmLogo
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.asset(
                                      'assets/images/rbm_emblem.jpeg',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text(
                                                'RBM',
                                                style: TextStyle(
                                                  color: AppColors.primaryBlue,
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                    ),
                                  )
                                : const Text(
                                    'RBM',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      card.cardholderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.employeeNumber,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                    if (deptGrade.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        deptGrade,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: AppColors.successGreen,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (availableBalance != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(availableBalance!),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Available balance',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showQrPanel) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGray),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  'Present to POS attendant for scanning',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGray, width: 1.5),
                  ),
                  child: QrImageView(
                    data: card.qrPayload,
                    size: 104,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Token: ${_maskedToken()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.borderGray,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
