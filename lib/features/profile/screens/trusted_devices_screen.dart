import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../providers/profile_provider.dart';

/// Trusted devices screen.
class TrustedDevicesScreen extends ConsumerWidget {
  /// Creates trusted devices screen.
  const TrustedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(trustedDevicesProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Trusted Devices'),
        body: devices.when(
          data: (items) => ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final d = items[index];
              return ListTile(
                leading: const Icon(Icons.devices),
                title: Text(d.deviceName),
                subtitle: Text('${d.platform} · last seen ${Formatters.formatLocalDateTime(d.lastSeenAt)}'),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove',
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load devices: $e'),
        ),
      ),
    );
  }
}
