import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';
import '../../../shared/widgets/rbm_tab_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
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

    return OfflineBanner(
      child: RbmTabScaffold(
        currentIndex: 2,
        appBar: const RbmAppBar(title: AppStrings.cardTitle, centerTitle: true),
        body: card.when(
          data: (c) => Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF8FAFF),
                        AppColors.backgroundLight,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -120,
                right: -85,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE8FF).withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 84),
                children: [
                  _CardHeroHeader(
                    fullName: auth.staffProfile?.fullName ?? c.cardholderName,
                  ),
                  const SizedBox(height: 12),
                  ClubCardWidget(
                    card: c,
                    staffDepartment: auth.staffProfile?.department,
                    staffGrade: auth.staffProfile?.grade,
                    staffEmail: auth.staffProfile?.email,
                    staffPhoneMasked: auth.staffProfile?.phoneMasked,
                    showRbmLogo: true,
                  ),
                  const SizedBox(height: 12),
                  const CardActionsRow(),
                  const SizedBox(height: 12),
                  const _VerificationPanel(),
                ],
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(message: 'Failed to load card: $e'),
        ),
      ),
    );
  }
}

class _CardHeroHeader extends StatelessWidget {
  const _CardHeroHeader({required this.fullName});

  final String fullName;

  String get _firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Staff ID',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hello, $_firstName. Your secure electronic ID is ready for verification and club access.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_rounded,
                size: 15,
                color: AppColors.successGreen,
              ),
              SizedBox(width: 4),
              Text(
                'Secure',
                style: TextStyle(
                  color: AppColors.successGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel();

  @override
  Widget build(BuildContext context) {
    return RbmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification & Security',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const _InfoRow(
            icon: Icons.qr_code_2_rounded,
            title: 'Use the QR for fast verification',
            message: 'Present the ID at POS or check-in for quick scanning.',
          ),
          const SizedBox(height: 10),
          const _InfoRow(
            icon: Icons.shield_rounded,
            title: 'Protected while open',
            message:
                'This screen is secured during use to help protect sensitive identity data.',
          ),
          const SizedBox(height: 10),
          const _InfoRow(
            icon: Icons.person_pin_circle_rounded,
            title: 'Keep your profile current',
            message:
                'Your department, contacts, and ID details reflect your staff profile information.',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
