import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../models/trusted_device_model.dart';
import '../providers/profile_provider.dart';

/// Trusted devices screen.
class TrustedDevicesScreen extends ConsumerStatefulWidget {
  /// Creates trusted devices screen.
  const TrustedDevicesScreen({super.key});

  @override
  ConsumerState<TrustedDevicesScreen> createState() =>
      _TrustedDevicesScreenState();
}

class _TrustedDevicesScreenState extends ConsumerState<TrustedDevicesScreen> {
  final Set<String> _hiddenDeviceIds = <String>{};

  Future<void> _refresh() async {
    ref.invalidate(trustedDevicesProvider);
    await ref.read(trustedDevicesProvider.future);
  }

  bool _isCurrentDevice(TrustedDeviceModel device, int index) {
    final name = device.deviceName.toLowerCase();
    return name.contains('this device') || index == 0;
  }

  Future<void> _removeDevice(TrustedDeviceModel device) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Remove Device',
        message: 'Remove "${device.deviceName}" from trusted devices?',
        confirmLabel: 'Remove',
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _hiddenDeviceIds.add(device.deviceId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${device.deviceName} removed.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (!mounted) return;
            setState(() => _hiddenDeviceIds.remove(device.deviceId));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(trustedDevicesProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Trusted Devices', centerTitle: true),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF4FF), AppColors.backgroundLight],
            ),
          ),
          child: devicesAsync.when(
            data: (items) {
              final visibleItems = items
                  .where(
                    (device) => !_hiddenDeviceIds.contains(device.deviceId),
                  )
                  .toList();

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 88),
                  children: [
                    _TrustedSummaryCard(deviceCount: visibleItems.length),
                    const SizedBox(height: 12),
                    if (visibleItems.isEmpty)
                      const _NoDevicesCard()
                    else
                      ...List.generate(visibleItems.length, (index) {
                        final device = visibleItems[index];
                        final isCurrent = _isCurrentDevice(device, index);
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == visibleItems.length - 1 ? 0 : 10,
                          ),
                          child: _TrustedDeviceCard(
                            device: device,
                            isCurrent: isCurrent,
                            onRemove: isCurrent
                                ? null
                                : () => _removeDevice(device),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                AppErrorWidget(message: 'Failed to load devices: $e'),
          ),
        ),
      ),
    );
  }
}

class _TrustedSummaryCard extends StatelessWidget {
  const _TrustedSummaryCard({required this.deviceCount});

  final int deviceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF042A67)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
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
                  '$deviceCount trusted ${deviceCount == 1 ? 'device' : 'devices'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pull down to refresh this list',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
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

class _NoDevicesCard extends StatelessWidget {
  const _NoDevicesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF7)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.devices_other_outlined,
            size: 28,
            color: AppColors.inactive,
          ),
          const SizedBox(height: 8),
          Text(
            'No trusted devices',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'When a device is registered, it will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TrustedDeviceCard extends StatelessWidget {
  const _TrustedDeviceCard({
    required this.device,
    required this.isCurrent,
    required this.onRemove,
  });

  final TrustedDeviceModel device;
  final bool isCurrent;
  final VoidCallback? onRemove;

  IconData get _platformIcon {
    final platform = device.platform.toLowerCase();
    if (platform.contains('android')) return Icons.android_rounded;
    if (platform.contains('ios') || platform.contains('iphone')) {
      return Icons.phone_iphone_rounded;
    }
    if (platform.contains('web') || platform.contains('browser')) {
      return Icons.language_rounded;
    }
    return Icons.devices_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_platformIcon, color: AppColors.primaryBlue, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.deviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4DF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Current',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: const Color(0xFF3E6F14),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${device.platform.toUpperCase()} | Last seen ${Formatters.formatLocalDateTime(device.lastSeenAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            tooltip: isCurrent ? 'Current device' : 'Remove',
            style: IconButton.styleFrom(
              backgroundColor: isCurrent
                  ? const Color(0xFFF0F2F5)
                  : const Color(0xFFFFEEEE),
              foregroundColor: isCurrent
                  ? AppColors.inactive
                  : AppColors.dangerRed,
            ),
            icon: Icon(
              isCurrent
                  ? Icons.lock_outline_rounded
                  : Icons.delete_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
