import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
          data: (c) => Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: c.qrPayload,
                size: 280,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load QR: $e'),
        ),
      ),
    );
  }
}

