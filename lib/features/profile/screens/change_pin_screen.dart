import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../auth/widgets/pin_input_widget.dart';
import '../../auth/widgets/pin_keypad_widget.dart';

/// Change PIN screen (placeholder).
class ChangePinScreen extends ConsumerStatefulWidget {
  /// Creates change PIN screen.
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  String _oldPin = '';
  String _newPin = '';
  bool _settingNew = false;
  String? _error;

  void _appendDigit(int digit) {
    setState(() {
      _error = null;
      if (!_settingNew) {
        if (_oldPin.length >= 6) return;
        _oldPin = '$_oldPin$digit';
        if (_oldPin.length == 6) _settingNew = true;
      } else {
        if (_newPin.length >= 6) return;
        _newPin = '$_newPin$digit';
      }
    });
  }

  void _backspace() {
    setState(() {
      _error = null;
      if (!_settingNew) {
        if (_oldPin.isEmpty) return;
        _oldPin = _oldPin.substring(0, _oldPin.length - 1);
      } else {
        if (_newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        } else {
          _settingNew = false;
        }
      }
    });
  }

  Future<void> _confirm() async {
    if (_oldPin.length != 6) {
      setState(() => _error = 'Enter your current 6-digit PIN.');
      return;
    }
    if (_newPin.length != 6) {
      setState(() => _error = 'Enter your new 6-digit PIN.');
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN change request submitted.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final len = _settingNew ? _newPin.length : _oldPin.length;
    final label = _settingNew ? 'New PIN' : 'Current PIN';

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Change PIN'),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              PinInputWidget(length: 6, valueLength: len, errorText: _error),
              const Spacer(),
              PinKeypadWidget(
                onDigit: _appendDigit,
                onBackspace: _backspace,
                onConfirm: _confirm,
                confirmEnabled: _settingNew ? _newPin.length == 6 : _oldPin.length == 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

