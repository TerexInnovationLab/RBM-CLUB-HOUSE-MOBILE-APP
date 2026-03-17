import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../providers/card_provider.dart';

/// Full-screen QR screen.
class FullscreenQrScreen extends ConsumerWidget {
  /// Creates a full-screen QR screen.
  const FullscreenQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(virtualCardProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'QR Code'),
        body: card.when(
          data: (c) {
            final src = c.cardId.isEmpty ? c.qrPayload : c.cardId;
            final last4 = src.length >= 4 ? src.substring(src.length - 4) : src;
            final token = 'TKN-••••••••$last4'.toUpperCase();

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGray),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Present to POS attendant for scanning',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: c.qrPayload,
                        size: 280,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Token: $token',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inactive),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load QR: $e'),
        ),
      ),
    );
  }
}
