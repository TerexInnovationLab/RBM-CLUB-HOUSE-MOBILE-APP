import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/top_snackbar.dart';
import '../providers/auth_provider.dart';
import 'set_pin_screen.dart';

/// Route args for activation identity verification.
class ActivationVerifyArgs {
  /// Creates activation verification args.
  const ActivationVerifyArgs({
    required this.employeeNumber,
    required this.fullName,
    required this.registeredPhoneNumber,
  });

  /// Employee number.
  final String employeeNumber;

  /// Employee full name.
  final String fullName;

  /// Registered full phone number.
  final String registeredPhoneNumber;
}

/// Activation identity verification screen.
class ActivationVerifyScreen extends ConsumerStatefulWidget {
  /// Creates activation verification screen.
  const ActivationVerifyScreen({super.key, required this.args});

  /// Arguments from activation step 1.
  final ActivationVerifyArgs args;

  @override
  ConsumerState<ActivationVerifyScreen> createState() =>
      _ActivationVerifyScreenState();
}

class _ActivationVerifyScreenState
    extends ConsumerState<ActivationVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_loading) return;

    final entered = _normalizePhone(_phoneController.text.trim());
    final expected = _normalizePhone(widget.args.registeredPhoneNumber);
    if (entered != expected) {
      TopSnackBar.show(
        context,
        message: 'The phone number entered does not match our records.',
        tone: TopSnackBarTone.error,
      );
      return;
    }
    final activationCode = entered.substring(entered.length - 3);

    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .activateStep1(
            employeeNumber: widget.args.employeeNumber,
            temporaryPin: activationCode,
          );

      if (!mounted) return;
      context.push(
        RouteNames.setPin,
        extra: SetPinArgs(
          employeeNumber: widget.args.employeeNumber,
          activationCode: activationCode,
        ),
      );
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
    final args = widget.args;
    final theme = Theme.of(context);
    final firstName = _firstName(args.fullName);

    return OfflineBanner(
      child: Scaffold(
        body: args.employeeNumber.trim().isEmpty
            ? const AppErrorWidget(message: 'Activation details are missing.')
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
                                          context.go(RouteNames.activation);
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
                                      width: 185,
                                      height: 150,
                                      child: Lottie.asset(
                                        'assets/animations/email.json',
                                        fit: BoxFit.contain,
                                        repeat: true,
                                        frameRate: FrameRate.max,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Hello, $firstName.',
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
                                    'Verify your identity by entering your full registered phone number.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      12,
                                      12,
                                      10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF2FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFCADEFF),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Confirm your details',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Name: ${args.fullName}'),
                                        Text(
                                          'Employee Number: ${args.employeeNumber}',
                                        ),
                                        Text(
                                          'Registered Phone: ${args.registeredPhoneNumber}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: _fieldDecoration(
                                      label: 'Phone number',
                                      hint: '+265991234321',
                                    ),
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    validator: Validators.phoneNumber,
                                    onFieldSubmitted: (_) =>
                                        _verifyAndContinue(),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 52,
                                    child: FilledButton(
                                      onPressed: _loading
                                          ? null
                                          : _verifyAndContinue,
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

  String _normalizePhone(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  String _firstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
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
}
