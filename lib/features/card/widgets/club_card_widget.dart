import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/virtual_card_model.dart';

/// Club virtual card widget styled as an electronic ID.
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
    this.staffEmail,
    this.staffPhoneMasked,
  });

  /// Virtual card.
  final VirtualCardModel card;
  final String? staffDepartment;
  final String? staffGrade;
  final double? availableBalance;
  final bool showQrPanel;
  final bool showRbmLogo;
  final String? staffEmail;
  final String? staffPhoneMasked;

  String _maskedToken() {
    final src = card.cardId.isEmpty ? card.qrPayload : card.cardId;
    final last4 = src.length >= 4 ? src.substring(src.length - 4) : src;
    return 'TKN-********$last4'.toUpperCase();
  }

  String _fallback(String? value) {
    final v = (value ?? '').trim();
    return v.isEmpty ? '--' : v;
  }

  String _firstName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Staff';
    return parts.first;
  }

  String _lastName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length <= 1) return '--';
    return parts.sublist(1).join(' ');
  }

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'RB';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final holder = card.cardholderName.trim().isEmpty
        ? 'Staff Member'
        : card.cardholderName.trim();
    final firstName = _firstName(holder);
    final lastName = _lastName(holder);
    final expiryDate = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.now().add(const Duration(days: 1825)));

    final fields = <_IdentityField>[
      _IdentityField(label: 'First Name', value: firstName),
      _IdentityField(label: 'Last Name', value: lastName),
      _IdentityField(
        label: 'Employee ID',
        value: _fallback(card.employeeNumber),
      ),
      _IdentityField(label: 'Department', value: _fallback(staffDepartment)),
      _IdentityField(label: 'Grade', value: _fallback(staffGrade)),
      _IdentityField(label: 'Valid Until', value: expiryDate),
      _IdentityField(label: 'Email', value: _fallback(staffEmail)),
      _IdentityField(label: 'Mobile', value: _fallback(staffPhoneMasked)),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E003A8F),
            blurRadius: 24,
            offset: Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -28,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reserve Bank of Malawi'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Electronic ID',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.74),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _BrandBadge(showRbmLogo: showRbmLogo),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDEE7F6)),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileBlock(
                            fullName: holder,
                            initials: _initials(holder),
                          ),
                          const SizedBox(width: 10),
                          if (showQrPanel)
                            _QrBlock(qrPayload: card.qrPayload)
                          else
                            Expanded(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'VALID',
                                    style: TextStyle(
                                      color: AppColors.successGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = (constraints.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              for (final field in fields)
                                SizedBox(
                                  width: width,
                                  child: _FieldTile(
                                    label: field.label,
                                    value: field.value,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Token: ${_maskedToken()}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (availableBalance != null)
                        Text(
                          CurrencyFormatter.format(availableBalance!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
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

class _IdentityField {
  const _IdentityField({required this.label, required this.value});

  final String label;
  final String value;
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.showRbmLogo});

  final bool showRbmLogo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: showRbmLogo
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/rbm_emblem.jpeg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _RbmWordmark(),
                ),
              )
            : const _RbmWordmark(),
      ),
    );
  }
}

class _RbmWordmark extends StatelessWidget {
  const _RbmWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'RBM',
      style: TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 7.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.fullName, required this.initials});

  final String fullName;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5DEEE)),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QrBlock extends StatelessWidget {
  const _QrBlock({required this.qrPayload});

  final String qrPayload;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: QrImageView(
              data: qrPayload,
              size: 76,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.verified_rounded,
                color: AppColors.successGreen,
                size: 13,
              ),
              SizedBox(width: 3),
              Text(
                'VALID',
                style: TextStyle(
                  color: AppColors.successGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
