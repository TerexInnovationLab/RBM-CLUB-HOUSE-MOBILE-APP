import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../card/models/virtual_card_model.dart';
import '../../profile/models/staff_profile_model.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../models/monthly_summary_model.dart';

/// Dedicated wallet card styled like an internal RBM wallet card.
class WalletPaymentCard extends ConsumerWidget {
  /// Creates a wallet payment card.
  const WalletPaymentCard({
    super.key,
    required this.summary,
    required this.currentBalance,
    this.profile,
    this.card,
  });

  /// Current monthly summary.
  final MonthlySummaryModel summary;

  /// Current wallet balance.
  final double currentBalance;

  /// Staff profile, if available.
  final StaffProfileModel? profile;

  /// Virtual card details, if available.
  final VirtualCardModel? card;

  String _holderName() {
    final candidates = [card?.cardholderName, profile?.fullName, 'RBM Staff'];
    for (final candidate in candidates) {
      final value = (candidate ?? '').trim();
      if (value.isNotEmpty) return value;
    }
    return 'RBM Staff';
  }

  String _employeeNumber() {
    final candidates = [card?.employeeNumber, profile?.employeeNumber];
    for (final candidate in candidates) {
      final value = (candidate ?? '').trim();
      if (value.isNotEmpty) return value;
    }
    return 'EMP-00000';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maskAmounts = ref.watch(appSettingsProvider).amountMasking;
    final usageRatio = summary.allocatedAmount <= 0
        ? 0.0
        : (summary.spentAmount / summary.allocatedAmount).clamp(0.0, 1.0);
    final holderName = _holderName().toUpperCase();
    final employeeNumber = _employeeNumber().toUpperCase();
    final descriptor = [
      employeeNumber,
      if ((profile?.grade ?? '').trim().isNotEmpty) profile!.grade.trim(),
      if ((profile?.department ?? '').trim().isNotEmpty)
        profile!.department.trim(),
    ].join('  |  ');
    final validThru = DateFormat('MM/yy').format(summary.periodEnd.toLocal());
    final balance = maskAmounts
        ? 'MWK ******'
        : CurrencyFormatter.format(currentBalance).replaceFirst('.00', '');
    final allocated = maskAmounts
        ? 'MWK ******'
        : CurrencyFormatter.format(
            summary.allocatedAmount,
          ).replaceFirst('.00', '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF08173A), Color(0xFF0E2C76), Color(0xFF1252B8)],
          stops: [0.02, 0.58, 1],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2200286B),
            blurRadius: 28,
            offset: Offset(0, 16),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -48,
            top: -36,
            child: Container(
              width: 154,
              height: 154,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -34,
            bottom: -78,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x55FFD269), Color(0x00FFD269)],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reserve Bank of Malawi'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Club Wallet',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _RbmLogoBadge(),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const _CardChip(),
                  const SizedBox(width: 12),
                  Transform.rotate(
                    angle: math.pi / 2,
                    child: Icon(
                      Icons.wifi_rounded,
                      color: Colors.white.withValues(alpha: 0.78),
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Available balance'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  balance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _CardMeta(label: 'CARD HOLDER', value: holderName),
                  ),
                  const SizedBox(width: 8),
                  _CardMeta(label: 'VALID THRU', value: validThru),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CardMeta(
                      label: 'ALLOCATED',
                      value: allocated,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: usageRatio,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFCE5B),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cycle ends ${Formatters.formatDate(summary.periodEnd)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${(usageRatio * 100).toStringAsFixed(0)}% used',
                    style: const TextStyle(
                      color: Color(0xFFFFD873),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (descriptor.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  descriptor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 10,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5D487), Color(0xFFC99A35)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 6,
            bottom: 6,
            child: Container(width: 2, color: const Color(0x805C4508)),
          ),
          Positioned(
            left: 20,
            top: 6,
            bottom: 6,
            child: Container(width: 2, color: const Color(0x805C4508)),
          ),
          Positioned(
            top: 14,
            left: 8,
            right: 8,
            child: Container(height: 2, color: const Color(0x805C4508)),
          ),
        ],
      ),
    );
  }
}

class _RbmLogoBadge extends StatelessWidget {
  const _RbmLogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/rbm_emblem.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const _RbmWordmark(),
        ),
      ),
    );
  }
}

class _RbmWordmark extends StatelessWidget {
  const _RbmWordmark();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'RBM',
        style: TextStyle(
          color: Color(0xFF0E2C76),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
