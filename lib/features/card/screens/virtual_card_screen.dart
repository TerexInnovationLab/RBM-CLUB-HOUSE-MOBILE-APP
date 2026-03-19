import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../profile/models/app_settings_model.dart';
import '../../profile/providers/app_settings_provider.dart';
import '../providers/card_provider.dart';
import '../widgets/card_actions_row.dart';
import '../widgets/club_card_widget.dart';

/// Virtual card screen.
class VirtualCardScreen extends ConsumerStatefulWidget {
  /// Creates a virtual card screen.
  const VirtualCardScreen({super.key});

  @override
  ConsumerState<VirtualCardScreen> createState() => _VirtualCardScreenState();
}

class _VirtualCardScreenState extends ConsumerState<VirtualCardScreen> {
  ProviderSubscription<AppSettingsModel>? _settingsSubscription;
  bool _keepScreenSecure = false;

  @override
  void initState() {
    super.initState();
    _keepScreenSecure = ref.read(appSettingsProvider).screenshotProtection;
    _settingsSubscription = ref.listenManual<AppSettingsModel>(
      appSettingsProvider,
      (_, next) => _keepScreenSecure = next.screenshotProtection,
    );
    _secureScreen();
  }

  Future<void> _secureScreen() async {
    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } catch (_) {}
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  @override
  void dispose() {
    _settingsSubscription?.close();
    _settingsSubscription = null;

    try {
      if (!_keepScreenSecure) {
        FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    } catch (_) {}
    try {
      WakelockPlus.disable();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(virtualCardProvider);
    final auth = ref.watch(authProvider);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;

    return OfflineBanner(
      child: RbmTabScaffold(
        currentIndex: 2,
        appBar: const RbmAppBar(title: AppStrings.cardTitle),
        body: card.when(
          data: (c) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClubCardWidget(
                card: c,
                staffDepartment: auth.staffProfile?.department,
                staffGrade: auth.staffProfile?.grade,
                availableBalance: dashboard?.currentBalance,
              ),
              const SizedBox(height: 12),
              const CardActionsRow(),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load card: $e'),
        ),
      ),
    );
  }
}
