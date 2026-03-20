import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_input_widget.dart';
import '../widgets/pin_keypad_widget.dart';

/// Route args for setting a new PIN as part of activation.
class SetPinArgs {
  /// Creates set-pin args.
  const SetPinArgs({
    required this.employeeNumber,
    required this.activationCode,
  });

  /// Employee number.
  final String employeeNumber;

  /// Activation verification code.
  final String activationCode;
}

/// Screen to set a new secure 6-digit PIN.
class SetPinScreen extends ConsumerStatefulWidget {
  /// Creates a set PIN screen.
  const SetPinScreen({super.key, required this.args});

  /// Set PIN arguments.
  final SetPinArgs args;

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  String _pin1 = '';
  String _pin2 = '';
  bool _confirming = false;
  bool _loading = false;
  String? _error;

  void _appendDigit(int digit) {
    setState(() {
      _error = null;
      if (!_confirming) {
        if (_pin1.length >= 6) return;
        _pin1 = '$_pin1$digit';
        if (_pin1.length == 6) _confirming = true;
      } else {
        if (_pin2.length >= 6) return;
        _pin2 = '$_pin2$digit';
      }
    });
  }

  void _backspace() {
    setState(() {
      _error = null;
      if (!_confirming) {
        if (_pin1.isEmpty) return;
        _pin1 = _pin1.substring(0, _pin1.length - 1);
      } else {
        if (_pin2.isNotEmpty) {
          _pin2 = _pin2.substring(0, _pin2.length - 1);
        } else {
          _confirming = false;
        }
      }
    });
  }

  Future<void> _confirm() async {
    final pinToValidate = _confirming ? _pin2 : _pin1;
    final error = Validators.pin6(pinToValidate);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (!_confirming) return;
    if (_pin1 != _pin2) {
      setState(() {
        _error = 'PINs do not match. Please try again.';
        _pin1 = '';
        _pin2 = '';
        _confirming = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .activateStep2(
            employeeNumber: widget.args.employeeNumber,
            temporaryPin: widget.args.activationCode,
            newPin: _pin1,
          );
      if (!mounted) return;
      await _promptBiometricIfSupported();
      if (!mounted) return;
      context.go(RouteNames.activationSuccess);
    } catch (e) {
      setState(() => _error = 'Activation failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _promptBiometricIfSupported() async {
    final biometric = ref.read(biometricServiceProvider);
    final supported = await biometric.isSupported();
    if (!supported) return;
    if (!mounted) return;

    final enabled = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable biometric login?'),
        content: const Text(
          'Use fingerprint/Face ID for faster login on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    if (enabled == true) {
      await ref.read(authProvider.notifier).setBiometricEnabled(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final len = _confirming ? _pin2.length : _pin1.length;
    final args = widget.args;
    final theme = Theme.of(context);
    final instruction = _confirming
        ? 'Re-enter the same PIN to finish activation.'
        : 'Create a unique 6-digit PIN for secure sign-in.';

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
                                      backgroundColor: const Color(0xFFF1F4FA),
                                    ),
                                    icon: const Icon(Icons.arrow_back_rounded),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  child: SizedBox(
                                    width: 170,
                                    height: 140,
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
                                  _confirming
                                      ? 'Confirm Your PIN'
                                      : 'Create Your PIN',
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
                                  instruction,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PinInputWidget(
                                  length: 6,
                                  valueLength: len,
                                  errorText: _error,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: const [
                                    _PinTipChip(
                                      icon: Icons.pin_outlined,
                                      label: 'Use 6 digits',
                                    ),
                                    _PinTipChip(
                                      icon: Icons.shield_outlined,
                                      label: 'Avoid obvious patterns',
                                    ),
                                    _PinTipChip(
                                      icon: Icons.visibility_off_outlined,
                                      label: 'Keep your PIN private',
                                    ),
                                  ],
                                ),
                                if (_loading) ...[
                                  const SizedBox(height: 12),
                                  const LinearProgressIndicator(minHeight: 4),
                                ],
                                const SizedBox(height: 16),
                                PinKeypadWidget(
                                  onDigit: _appendDigit,
                                  onBackspace: _backspace,
                                  onConfirm: _confirm,
                                  confirmEnabled:
                                      !_loading &&
                                      ((_confirming && _pin2.length == 6) ||
                                          (!_confirming && _pin1.length == 6)),
                                  confirmLabel: _confirming
                                      ? 'Activate'
                                      : 'Continue',
                                  confirmIcon: _confirming
                                      ? Icons.check_circle_outline
                                      : Icons.arrow_forward,
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

class _PinTipChip extends StatelessWidget {
  const _PinTipChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFCADEFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
