import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/offline_banner.dart';

/// Activation completion screen shown before routing to home.
class ActivationSuccessScreen extends StatefulWidget {
  /// Creates an activation success screen.
  const ActivationSuccessScreen({super.key});

  @override
  State<ActivationSuccessScreen> createState() =>
      _ActivationSuccessScreenState();
}

class _ActivationSuccessScreenState extends State<ActivationSuccessScreen> {
  Timer? _timer;
  bool _redirectScheduled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleRedirect(Duration duration) {
    if (_redirectScheduled) return;
    _redirectScheduled = true;
    final safeDuration = duration > Duration.zero
        ? duration
        : const Duration(seconds: 2);
    _timer = Timer(safeDuration, () {
      if (!mounted) return;
      context.go(RouteNames.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OfflineBanner(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5FA),
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
              top: -180,
              left: -140,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDEE7FF).withValues(alpha: 0.48),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE0E8F5)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000E2A),
                            blurRadius: 28,
                            offset: Offset(0, 16),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 220,
                            height: 180,
                            child: Lottie.asset(
                              'assets/animations/success.json',
                              fit: BoxFit.contain,
                              repeat: false,
                              frameRate: FrameRate.max,
                              onLoaded: (composition) =>
                                  _scheduleRedirect(composition.duration),
                              errorBuilder: (context, error, stackTrace) {
                                _scheduleRedirect(const Duration(seconds: 2));
                                return const Center(
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 72,
                                    color: AppColors.successGreen,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Account Activated',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: const Color(0xFF101828),
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Success! Logging you in now...',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
