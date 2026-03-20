import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/top_snackbar.dart';
import '../providers/auth_provider.dart';
import 'activation_verify_screen.dart';

/// First-time account activation screen.
class ActivationScreen extends ConsumerStatefulWidget {
  /// Creates an activation screen.
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _employeeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final employeeNumber = _employeeController.text.trim();
      final args = _resolveActivationVerifyArgs(employeeNumber);

      if (!mounted) return;
      context.push(RouteNames.activationVerify, extra: args);
    } catch (e) {
      if (!mounted) return;
      TopSnackBar.show(
        context,
        message: 'Activation failed: $e',
        tone: TopSnackBarTone.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    return OfflineBanner(
      child: Scaffold(
        body: auth.isLocked
            ? const AppErrorWidget(
                message: 'Account locked - contact HR to unlock.',
              )
            : Stack(
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
                  Positioned(
                    top: -120,
                    left: -80,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCCD9F7).withValues(alpha: 0.44),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0xFFE0E8F5),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000E2A),
                                  blurRadius: 28,
                                  offset: Offset(0, 16),
                                  spreadRadius: -8,
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      onPressed: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go(RouteNames.login);
                                        }
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFF1F4FA,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    child: SizedBox(
                                      width: 170,
                                      height: 150,
                                      child: Lottie.asset(
                                        'assets/animations/forgot_password.json',
                                        fit: BoxFit.contain,
                                        repeat: true,
                                        frameRate: FrameRate.max,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Activate Account',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(
                                          color: const Color(0xFF101828),
                                          fontSize: 34,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.8,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Enter your employee number to start account activation.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  TextFormField(
                                    controller: _employeeController,
                                    decoration: _fieldDecoration(
                                      label: AppStrings.employeeNumberLabel,
                                      hint: 'EMP-00123',
                                    ),
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    textInputAction: TextInputAction.done,
                                    validator: Validators.employeeNumber,
                                    onFieldSubmitted: (_) => _continue(),
                                  ),
                                  if (AppConfig.isDemo) ...[
                                    const SizedBox(height: 14),
                                    const _DemoCredentialsCard(),
                                  ],
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    height: 52,
                                    child: FilledButton(
                                      onPressed: _loading ? null : _continue,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF111827,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              AppStrings.continueLabel,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () =>
                                        context.go(RouteNames.login),
                                    child: const Text(
                                      'Already activated? Log in',
                                    ),
                                  ),
                                ],
                              ),
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

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0F3F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E7F1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
      ),
    );
  }

  ActivationVerifyArgs _resolveActivationVerifyArgs(String employeeNumber) {
    final normalized = employeeNumber.trim().toUpperCase();

    // Demo directory for activation identity checks.
    final demoDirectory = <String, ({String fullName, String phoneNumber})>{
      AppConfig.demoActivationEmployeeNumber.toUpperCase(): (
        fullName: AppConfig.demoLoginName,
        phoneNumber: AppConfig.demoActivationPhoneNumber,
      ),
      'EMP-00456': (fullName: 'Mary Tembo', phoneNumber: '+265995551234'),
      'EMP-00789': (fullName: 'Peter Mbewe', phoneNumber: '+265998880789'),
    };

    if (AppConfig.isDemo) {
      final match =
          demoDirectory[normalized] ??
          (
            fullName: AppConfig.demoLoginName,
            phoneNumber: AppConfig.demoActivationPhoneNumber,
          );
      return ActivationVerifyArgs(
        employeeNumber: employeeNumber,
        fullName: match.fullName,
        registeredPhoneNumber: match.phoneNumber,
      );
    }

    // Deterministic non-demo fallback while backend identity lookup is pending.
    final digits = RegExp(r'\d+').firstMatch(normalized)?.group(0) ?? '000';
    final padded = digits.padLeft(6, '0');
    final last6 = padded.substring(padded.length - 6);
    return ActivationVerifyArgs(
      employeeNumber: employeeNumber,
      fullName: 'Employee',
      registeredPhoneNumber: '+26599$last6',
    );
  }
}

class _DemoCredentialsCard extends StatelessWidget {
  const _DemoCredentialsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCADEFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demo Activation Credentials',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF003A8F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Employee Number: ${AppConfig.demoActivationEmployeeNumber}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Name: ${AppConfig.demoLoginName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Registered Phone: ${AppConfig.demoActivationPhoneNumber}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Next step asks for the full phone number, then you set your own PIN.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
