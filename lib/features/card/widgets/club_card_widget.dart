import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../models/virtual_card_model.dart';

/// Club virtual card widget.
class ClubCardWidget extends StatelessWidget {
  /// Creates a club card widget.
  const ClubCardWidget({super.key, required this.card});

  /// Virtual card.
  final VirtualCardModel card;

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RBM Club House', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(card.cardholderName, style: Theme.of(context).textTheme.titleLarge),
          Text(card.employeeNumber),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: QrImageView(
                data: card.qrPayload,
                size: 160,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
