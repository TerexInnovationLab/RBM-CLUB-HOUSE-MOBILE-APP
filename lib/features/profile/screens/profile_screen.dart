import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/staff_profile_model.dart';
import '../providers/app_settings_provider.dart';
import '../providers/profile_provider.dart';

/// Profile screen.
class ProfileScreen extends ConsumerWidget {
  /// Creates profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(staffProfileProvider);
    final auth = ref.watch(authProvider);

    return OfflineBanner(
      child: RbmTabScaffold(
        currentIndex: 4,
        appBar: const RbmAppBar(title: 'Profile', centerTitle: true),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF4FF), AppColors.backgroundLight],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 88),
            children: [
              if (profile != null)
                _ProfileHeroCard(
                  profile: profile,
                  onEditTap: () => context.go(RouteNames.editProfile),
                )
              else
                const _ProfileFallbackCard(),
              const SizedBox(height: 14),
              _SectionHeader(
                title: 'Personal Information',
                actionLabel: 'Edit',
                onActionTap: () => context.go(RouteNames.editProfile),
              ),
              const SizedBox(height: 6),
              if (profile != null)
                _InfoCard(
                  rows: [
                    _InfoRow(
                      icon: Icons.alternate_email_rounded,
                      label: 'Email',
                      value: profile.email,
                    ),
                    _InfoRow(
                      icon: Icons.phone_iphone_rounded,
                      label: 'Phone',
                      value: profile.phoneMasked,
                    ),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Employee Number',
                      value: profile.employeeNumber,
                    ),
                    _InfoRow(
                      icon: Icons.work_outline_rounded,
                      label: 'Department',
                      value: profile.department,
                    ),
                    _InfoRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Grade',
                      value: profile.grade,
                    ),
                    _InfoRow(
                      icon: Icons.shield_outlined,
                      label: 'Status',
                      value: profile.status,
                    ),
                  ],
                )
              else
                const _InfoCard(
                  rows: [
                    _InfoRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Profile',
                      value: 'No staff profile loaded',
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              const _SectionHeader(title: 'Utilities'),
              const SizedBox(height: 6),
              _ActionCard(
                children: [
                  _ActionRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change PIN',
                    subtitle: 'Update your 6-digit PIN',
                    onTap: () => context.go(RouteNames.changePin),
                  ),
                  _ActionRow(
                    icon: Icons.devices_outlined,
                    title: 'Trusted Devices',
                    subtitle: 'Manage registered devices',
                    onTap: () => context.go(RouteNames.trustedDevices),
                  ),
                  _ActionSwitchRow(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Login',
                    subtitle: 'Fingerprint / Face ID',
                    value: auth.biometricEnabled,
                    onChanged: (v) async {
                      await ref
                          .read(authProvider.notifier)
                          .setBiometricEnabled(v);
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setBiometricPermission(v);
                    },
                  ),
                  _ActionRow(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Desk',
                    subtitle: 'FAQs and support',
                    onTap: () => context.go(RouteNames.help),
                  ),
                  _ActionRow(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    subtitle: 'Update preferences',
                    onTap: () => context.go(RouteNames.settings),
                  ),
                  _ActionRow(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    subtitle: 'Sign out from this device',
                    danger: true,
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => const ConfirmationDialog(
                          title: 'Log Out',
                          message: 'Are you sure you want to log out?',
                          confirmLabel: 'Log Out',
                          isDestructive: true,
                        ),
                      );
                      if (ok == true) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(RouteNames.login);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.profile, required this.onEditTap});

  final StaffProfileModel profile;
  final VoidCallback onEditTap;

  String get _initials {
    final parts = profile.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'RB';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF042A67)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 20,
            offset: Offset(0, 12),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                color: Colors.white70,
                size: 20,
              ),
              const Spacer(),
              IconButton(
                onPressed: onEditTap,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF5CF), Color(0xFFF6C24D)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40F6C24D),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.fullName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${profile.employeeNumber}  |  Grade ${profile.grade}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Text(
              '${profile.department}  •  ${profile.status}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFallbackCard extends StatelessWidget {
  const _ProfileFallbackCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(
        'Profile data unavailable',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onActionTap,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: Text(actionLabel!),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF7)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F4FA)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          _CircleIcon(icon: icon, tone: _IconTone.soft),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF7)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F4FA)),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? AppColors.dangerRed : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _CircleIcon(
              icon: icon,
              tone: danger ? _IconTone.danger : _IconTone.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: danger ? AppColors.dangerRed : AppColors.inactive,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSwitchRow extends StatelessWidget {
  const _ActionSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _CircleIcon(icon: icon, tone: _IconTone.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.secondaryBlue,
          ),
        ],
      ),
    );
  }
}

enum _IconTone { primary, soft, danger }

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.tone});

  final IconData icon;
  final _IconTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _IconTone.primary => (const Color(0xFFE4EEFF), AppColors.primaryBlue),
      _IconTone.soft => (const Color(0xFFF0F4FA), AppColors.secondaryBlue),
      _IconTone.danger => (const Color(0xFFFFECEC), AppColors.dangerRed),
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 17, color: fg),
    );
  }
}
