import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_input_widget.dart';
import '../widgets/pin_keypad_widget.dart';

/// Route args for setting a new PIN as part of activation.
class SetPinArgs {
  /// Creates set-pin args.
  const SetPinArgs({required this.employeeNumber, required this.temporaryPin});

  /// Employee number.
  final String employeeNumber;

  /// Temporary PIN.
  final String temporaryPin;
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
      await ref.read(authProvider.notifier).activateStep2(
            employeeNumber: widget.args.employeeNumber,
            temporaryPin: widget.args.temporaryPin,
            newPin: _pin1,
          );
      if (!mounted) return;
      await _promptBiometricIfSupported();
      if (!mounted) return;
      context.go(RouteNames.home);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account activated successfully.')),
      );
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
        content: const Text('Use fingerprint/Face ID for faster login on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enable')),
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

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: AppStrings.setPinTitle),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _confirming ? 'Confirm your new 6-digit PIN' : 'Create a new secure 6-digit PIN',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              PinInputWidget(length: 6, valueLength: len, errorText: _error),
              const Spacer(),
              PinKeypadWidget(
                onDigit: _appendDigit,
                onBackspace: _backspace,
                onConfirm: _confirm,
                confirmEnabled: !_loading && ((_confirming && _pin2.length == 6) || (!_confirming && _pin1.length == 6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
