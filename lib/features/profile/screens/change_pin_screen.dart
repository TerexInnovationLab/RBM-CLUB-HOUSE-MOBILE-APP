import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../auth/widgets/pin_input_widget.dart';
import '../../auth/widgets/pin_keypad_widget.dart';

/// Change PIN screen.
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

  int get _activeLength => _settingNew ? _newPin.length : _oldPin.length;
  String get _activeLabel => _settingNew ? 'New PIN' : 'Current PIN';
  String get _activeHelp => _settingNew
      ? 'Create a new 6-digit PIN that is easy for you to remember.'
      : 'Enter your current 6-digit PIN to continue.';

  void _appendDigit(int digit) {
    setState(() {
      _error = null;
      if (!_settingNew) {
        if (_oldPin.length >= 6) return;
        _oldPin = '$_oldPin$digit';
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
    if (!_settingNew) {
      if (_oldPin.length != 6) {
        setState(() => _error = 'Enter your current 6-digit PIN.');
        return;
      }
      setState(() {
        _error = null;
        _settingNew = true;
      });
      return;
    }

    if (_newPin.length != 6) {
      setState(() => _error = 'Enter your new 6-digit PIN.');
      return;
    }

    if (_newPin == _oldPin) {
      setState(
        () => _error = 'New PIN must be different from your current PIN.',
      );
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
    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: 'Change PIN', centerTitle: true),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF4FF), AppColors.backgroundLight],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  children: [
                    _PinStepCard(
                      settingNew: _settingNew,
                      oldPinLength: _oldPin.length,
                      newPinLength: _newPin.length,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8EDF7)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _PinBadge(active: true, label: _activeLabel),
                              const Spacer(),
                              Text(
                                '$_activeLength/6',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _activeHelp,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          PinInputWidget(
                            length: 6,
                            valueLength: _activeLength,
                            errorText: _error,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE8EDF7))),
                ),
                child: PinKeypadWidget(
                  onDigit: _appendDigit,
                  onBackspace: _backspace,
                  onConfirm: _confirm,
                  confirmEnabled: _settingNew
                      ? _newPin.length == 6
                      : _oldPin.length == 6,
                  confirmLabel: _settingNew ? 'Update PIN' : 'Continue',
                  confirmIcon: _settingNew
                      ? Icons.lock_reset_rounded
                      : Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinStepCard extends StatelessWidget {
  const _PinStepCard({
    required this.settingNew,
    required this.oldPinLength,
    required this.newPinLength,
  });

  final bool settingNew;
  final int oldPinLength;
  final int newPinLength;

  @override
  Widget build(BuildContext context) {
    final step1Complete = oldPinLength == 6;
    final step2Complete = newPinLength == 6;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF042A67)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StepPill(
              index: 1,
              title: 'Verify Current PIN',
              active: !settingNew,
              done: step1Complete,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 16,
            height: 2,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StepPill(
              index: 2,
              title: 'Set New PIN',
              active: settingNew,
              done: step2Complete,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.index,
    required this.title,
    required this.active,
    required this.done,
  });

  final int index;
  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.transparent;
    final textColor = active
        ? Colors.white
        : Colors.white.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: active ? 0.24 : 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? const Color(0xFF40B566)
                  : Colors.white.withValues(alpha: 0.2),
            ),
            child: Icon(
              done
                  ? Icons.check_rounded
                  : (index == 1
                        ? Icons.looks_one_rounded
                        : Icons.looks_two_rounded),
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinBadge extends StatelessWidget {
  const _PinBadge({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7EEFF) : const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
