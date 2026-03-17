import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
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
      child: RbmTabScaffold(
        currentIndex: 4,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (profile != null) ProfileHeaderWidget(profile: profile),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 0, 13, 72),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  if (profile != null)
                    SettingsSectionWidget(
                      title: 'My information',
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _IconBox(icon: Icons.mail_outline, tone: _Tone.blue),
                          title: Text(profile.email),
                          subtitle: const Text('Work email'),
                          onTap: null,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _IconBox(icon: Icons.phone_outlined, tone: _Tone.blue),
                          title: Text(profile.phoneMasked),
                          subtitle: const Text('Phone number'),
                          onTap: null,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _IconBox(icon: Icons.verified_outlined, tone: _Tone.green),
                          title: const Text('Account active'),
                          subtitle: const Text('Status verified by HR'),
                          onTap: null,
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  SettingsSectionWidget(
                    title: 'Security',
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _IconBox(icon: Icons.lock_outline, tone: _Tone.amber),
                        title: const Text('Change PIN'),
                        subtitle: const Text('Update your 6-digit PIN'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(RouteNames.changePin),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: _IconBox(icon: Icons.fingerprint, tone: _Tone.amber),
                        title: const Text('Biometric login'),
                        subtitle: const Text('Fingerprint / Face ID'),
                        value: ref.watch(authProvider).biometricEnabled,
                        onChanged: (v) => ref.read(authProvider.notifier).setBiometricEnabled(v),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _IconBox(icon: Icons.devices_outlined, tone: _Tone.neutral),
                        title: const Text('Trusted devices'),
                        subtitle: const Text('Manage registered devices'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(RouteNames.trustedDevices),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SettingsSectionWidget(
                    title: 'Support',
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _IconBox(icon: Icons.help_outline, tone: _Tone.neutral),
                        title: const Text('Help'),
                        subtitle: const Text('FAQs and contact'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(RouteNames.help),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _IconBox(icon: Icons.settings_outlined, tone: _Tone.neutral),
                        title: const Text('Settings'),
                        subtitle: const Text('App preferences'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(RouteNames.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                    child: const Text('Log out from this device'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { blue, green, amber, neutral }

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.tone});

  final IconData icon;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _Tone.blue => (const Color(0xFFE6F1FB), const Color(0xFF0C447C)),
      _Tone.green => (const Color(0xFFEAF3DE), const Color(0xFF3B6D11)),
      _Tone.amber => (const Color(0xFFFAEEDA), const Color(0xFF633806)),
      _Tone.neutral => (AppColors.backgroundLight, AppColors.textSecondary),
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}
