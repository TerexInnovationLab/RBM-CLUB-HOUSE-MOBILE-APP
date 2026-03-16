import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../auth/providers/auth_provider.dart';

/// Settings screen.
class SettingsScreen extends ConsumerWidget {
  /// Creates settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Settings'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RbmCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('Enable biometric login'),
                subtitle: const Text('Use fingerprint/Face ID for faster login.'),
                value: auth.biometricEnabled,
                onChanged: (v) => ref.read(authProvider.notifier).setBiometricEnabled(v),
              ),
            ),
            const SizedBox(height: 12),
            const RbmCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Text('Theme'),
                subtitle: Text('System (default)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
