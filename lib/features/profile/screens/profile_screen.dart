import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/settings_section_widget.dart';

/// Profile screen.
class ProfileScreen extends ConsumerWidget {
  /// Creates profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(staffProfileProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: AppStrings.profileTitle),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (profile != null) ProfileHeaderWidget(profile: profile),
            const SizedBox(height: 12),
            SettingsSectionWidget(
              title: 'Security',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change PIN'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RouteNames.changePin),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.devices_outlined),
                  title: const Text('Trusted devices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RouteNames.trustedDevices),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsSectionWidget(
              title: 'Preferences',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RouteNames.settings),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsSectionWidget(
              title: 'Support',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RouteNames.help),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmationDialog(
                    title: 'Logout',
                    message: 'Are you sure you want to log out?',
                  ),
                );
                if (ok == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(RouteNames.login);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logoutLabel),
            ),
          ],
        ),
      ),
    );
  }
}

