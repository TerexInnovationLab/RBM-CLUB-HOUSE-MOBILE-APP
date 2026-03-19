import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../../shared/widgets/top_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/app_settings_model.dart';
import '../providers/app_settings_provider.dart';

/// Settings screen.
class SettingsScreen extends ConsumerWidget {
  /// Creates settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final auth = ref.watch(authProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Settings', centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A4A9E), AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                    spreadRadius: -7,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Personalize privacy, display and wallet behavior for your daily flow.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              children: [
                _SwitchTile(
                  title: 'Allow notifications',
                  subtitle: 'Enable push alerts for this app',
                  value: settings.notificationPermission,
                  onChanged: (enabled) async {
                    await settingsNotifier.setNotificationPermission(enabled);
                    if (!enabled || !context.mounted) return;

                    try {
                      final permission = await FirebaseMessaging.instance
                          .requestPermission();
                      final granted =
                          permission.authorizationStatus ==
                              AuthorizationStatus.authorized ||
                          permission.authorizationStatus ==
                              AuthorizationStatus.provisional;

                      if (!granted) {
                        await settingsNotifier.setNotificationPermission(false);
                        if (context.mounted) {
                          TopSnackBar.show(
                            context,
                            message:
                                'Notification permission is blocked by device settings.',
                            tone: TopSnackBarTone.warning,
                          );
                        }
                      }
                    } catch (_) {
                      // Keep app preference even if OS permission request fails.
                    }
                  },
                ),
                _SwitchTile(
                  title: 'Transactions',
                  subtitle: 'Payment and purchase updates',
                  value: settings.notificationTransactions,
                  enabled: settings.notificationPermission,
                  onChanged: settingsNotifier.setNotificationTransactions,
                ),
                _SwitchTile(
                  title: 'Low balance',
                  subtitle: 'Warn when available amount is low',
                  value: settings.notificationLowBalance,
                  enabled: settings.notificationPermission,
                  onChanged: settingsNotifier.setNotificationLowBalance,
                ),
                _SwitchTile(
                  title: 'Wallet cycle',
                  subtitle: 'Monthly allocation and reset reminders',
                  value: settings.notificationWalletCycle,
                  enabled: settings.notificationPermission,
                  onChanged: settingsNotifier.setNotificationWalletCycle,
                ),
                _SwitchTile(
                  title: 'Security alerts',
                  subtitle: 'PIN and trusted device activity',
                  value: settings.notificationSecurityAlerts,
                  enabled: settings.notificationPermission,
                  onChanged: settingsNotifier.setNotificationSecurityAlerts,
                ),
                _SwitchTile(
                  title: 'Quiet hours',
                  subtitle:
                      '${_formatHour(settings.quietHoursStartHour)} to ${_formatHour(settings.quietHoursEndHour)}',
                  value: settings.quietHoursEnabled,
                  enabled: settings.notificationPermission,
                  onChanged: settingsNotifier.setQuietHoursEnabled,
                ),
                if (settings.quietHoursEnabled)
                  _QuietHourEditor(
                    startHour: settings.quietHoursStartHour,
                    endHour: settings.quietHoursEndHour,
                    onStartTap: () async {
                      final hour = await _pickHour(
                        context,
                        initialHour: settings.quietHoursStartHour,
                      );
                      if (hour != null) {
                        await settingsNotifier.setQuietHoursRange(
                          startHour: hour,
                        );
                      }
                    },
                    onEndTap: () async {
                      final hour = await _pickHour(
                        context,
                        initialHour: settings.quietHoursEndHour,
                      );
                      if (hour != null) {
                        await settingsNotifier.setQuietHoursRange(
                          endHour: hour,
                        );
                      }
                    },
                  ),
                _SwitchTile(
                  title: 'Sound',
                  subtitle: 'Play notification sound',
                  value: settings.notificationSound,
                  enabled: settings.notificationPermission,
                  onChanged: settingsNotifier.setNotificationSound,
                ),
                _SwitchTile(
                  title: 'Vibration',
                  subtitle: 'Vibrate on incoming alerts',
                  value: settings.notificationVibration,
                  enabled: settings.notificationPermission,
                  onChanged: settingsNotifier.setNotificationVibration,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.shield_outlined,
              title: 'Privacy',
              children: [
                _SwitchTile(
                  title: 'Hide balances by default',
                  subtitle: 'Start with balance values hidden on Home',
                  value: settings.hideBalancesByDefault,
                  onChanged: settingsNotifier.setHideBalancesByDefault,
                ),
                _SwitchTile(
                  title: 'Screenshot protection',
                  subtitle: 'Block screenshots and screen recording',
                  value: settings.screenshotProtection,
                  onChanged: (enabled) async {
                    await settingsNotifier.setScreenshotProtection(enabled);
                    if (context.mounted) {
                      TopSnackBar.show(
                        context,
                        message: enabled
                            ? 'Screenshot protection enabled.'
                            : 'Screenshot protection disabled.',
                        tone: TopSnackBarTone.info,
                      );
                    }
                  },
                ),
                _SwitchTile(
                  title: 'Biometric permission',
                  subtitle: 'Allow fingerprint / Face ID login',
                  value: auth.biometricEnabled,
                  onChanged: (enabled) async {
                    await ref
                        .read(authProvider.notifier)
                        .setBiometricEnabled(enabled);
                    await settingsNotifier.setBiometricPermission(enabled);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.palette_outlined,
              title: 'Display',
              children: [
                _ChoiceRow<AppThemePreference>(
                  label: 'Theme',
                  value: settings.themePreference,
                  entries: const [
                    _ChoiceEntry(
                      value: AppThemePreference.system,
                      label: 'System',
                    ),
                    _ChoiceEntry(
                      value: AppThemePreference.light,
                      label: 'Light',
                    ),
                    _ChoiceEntry(value: AppThemePreference.dark, label: 'Dark'),
                  ],
                  onChanged: settingsNotifier.setThemePreference,
                ),
                _SliderTile(
                  title: 'Text size',
                  subtitle: 'Scale app text for readability',
                  value: settings.textScale,
                  min: 0.85,
                  max: 1.25,
                  divisions: 8,
                  valueLabel: '${(settings.textScale * 100).round()}%',
                  onChanged: settingsNotifier.setTextScale,
                ),
                _SwitchTile(
                  title: 'Compact mode',
                  subtitle: 'Use denser spacing throughout the app',
                  value: settings.compactMode,
                  onChanged: settingsNotifier.setCompactMode,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet & Transactions',
              children: [
                _ChoiceRow<ReceiptBehavior>(
                  label: 'Default receipt behavior',
                  value: settings.receiptBehavior,
                  entries: const [
                    _ChoiceEntry(value: ReceiptBehavior.ask, label: 'Ask'),
                    _ChoiceEntry(
                      value: ReceiptBehavior.download,
                      label: 'Save',
                    ),
                    _ChoiceEntry(value: ReceiptBehavior.share, label: 'Share'),
                  ],
                  onChanged: settingsNotifier.setReceiptBehavior,
                ),
                _SwitchTile(
                  title: 'Confirmation prompts',
                  subtitle: 'Show confirmation before key actions',
                  value: settings.confirmationPrompts,
                  onChanged: settingsNotifier.setConfirmationPrompts,
                ),
                _SwitchTile(
                  title: 'Amount masking',
                  subtitle: 'Mask values in wallet and transaction screens',
                  value: settings.amountMasking,
                  onChanged: settingsNotifier.setAmountMasking,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.sync_outlined,
              title: 'Data & Sync',
              children: [
                _ChoiceRow<RefreshBehavior>(
                  label: 'Refresh behavior',
                  value: settings.refreshBehavior,
                  entries: const [
                    _ChoiceEntry(value: RefreshBehavior.auto, label: 'Auto'),
                    _ChoiceEntry(
                      value: RefreshBehavior.manual,
                      label: 'Manual',
                    ),
                  ],
                  onChanged: settingsNotifier.setRefreshBehavior,
                ),
                _SwitchTile(
                  title: 'Offline data controls',
                  subtitle: 'Allow offline cache and connectivity indicators',
                  value: settings.offlineDataControls,
                  onChanged: settingsNotifier.setOfflineDataControls,
                ),
                _ClearCacheTile(
                  onClear: () async {
                    await settingsNotifier.clearImageCache();
                    if (context.mounted) {
                      TopSnackBar.show(
                        context,
                        message: 'Local cache cleared.',
                        tone: TopSnackBarTone.success,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<int?> _pickHour(BuildContext context, {required int initialHour}) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initialHour, minute: 0),
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
  return picked?.hour;
}

String _formatHour(int hour24) {
  final normalized = hour24.clamp(0, 23);
  final hour12 = normalized % 12 == 0 ? 12 : normalized % 12;
  final period = normalized >= 12 ? 'PM' : 'AM';
  return '$hour12:00 $period';
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F6)),
          ],
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final Future<void> Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final titleColor = enabled ? AppColors.textPrimary : AppColors.inactive;
    final subtitleColor = enabled
        ? AppColors.textSecondary
        : AppColors.inactive;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: enabled
            ? (next) {
                onChanged(next);
              }
            : null,
        activeThumbColor: AppColors.secondaryBlue,
        activeTrackColor: AppColors.secondaryBlue.withValues(alpha: 0.45),
      ),
    );
  }
}

class _ClearCacheTile extends StatelessWidget {
  const _ClearCacheTile({required this.onClear});

  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.cleaning_services_outlined,
                  color: AppColors.secondaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear cache',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Remove local image cache and temporary data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: () async {
                await onClear();
              },
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietHourEditor extends StatelessWidget {
  const _QuietHourEditor({
    required this.startHour,
    required this.endHour,
    required this.onStartTap,
    required this.onEndTap,
  });

  final int startHour;
  final int endHour;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onStartTap,
              icon: const Icon(Icons.nightlight_round, size: 16),
              label: Text('From ${_formatHour(startHour)}', style: labelStyle),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEndTap,
              icon: const Icon(Icons.wb_sunny_outlined, size: 16),
              label: Text('To ${_formatHour(endHour)}', style: labelStyle),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceEntry<T> {
  const _ChoiceEntry({required this.value, required this.label});

  final T value;
  final String label;
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.value,
    required this.entries,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<_ChoiceEntry<T>> entries;
  final Future<void> Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<T>(
              showSelectedIcon: false,
              segments: [
                for (final option in entries)
                  ButtonSegment<T>(
                    value: option.value,
                    label: Text(option.label),
                  ),
              ],
              selected: {value},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  onChanged(selection.first);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final Future<void> Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: (next) {
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}
