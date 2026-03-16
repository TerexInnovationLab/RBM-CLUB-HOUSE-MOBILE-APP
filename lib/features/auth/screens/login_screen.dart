import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_input_widget.dart';
import '../widgets/pin_keypad_widget.dart';

/// PIN-based login screen.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a login screen.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeController = TextEditingController();
  String _pin = '';
  bool _loading = false;

  @override
  void dispose() {
    _employeeController.dispose();
    super.dispose();
  }

  void _appendDigit(int digit) {
    if (_pin.length >= 6) return;
    setState(() => _pin = '$_pin$digit');
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final pinError = Validators.pin6(_pin);
    if (pinError != null) {
      setState(() {});
      return;
    }

    setState(() => _loading = true);
    await ref.read(authProvider.notifier).loginPin(
          employeeNumber: _employeeController.text.trim(),
          pin: _pin,
        );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteNames.home);
      });
    }

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: AppStrings.loginTitle),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _employeeController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeeNumberLabel,
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: Validators.employeeNumber,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PinInputWidget(
                      length: 6,
                      valueLength: _pin.length,
                      errorText: auth.errorMessage,
                    ),
                    const SizedBox(height: 24),
                    if (auth.isLocked)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Account locked — contact HR to unlock.',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    PinKeypadWidget(
                      onDigit: _appendDigit,
                      onBackspace: _backspace,
                      onConfirm: _confirm,
                      confirmEnabled: !_loading && _pin.length == 6 && !auth.isLocked,
                      confirmLabel: 'Log in',
                      confirmIcon: Icons.login_rounded,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      auth.isLocked ? '' : 'Attempts remaining: ${auth.remainingAttempts}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: auth.remainingAttempts <= 2
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (AppConfig.isDemo) ...[
                      FilledButton.icon(
                        onPressed: () async {
                          await ref
                              .read(authProvider.notifier)
                              .loginDemo(employeeNumber: _employeeController.text.trim());
                          if (context.mounted) context.go(RouteNames.home);
                        },
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Use demo account'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextButton(
                      onPressed: () => context.go(RouteNames.activation),
                      child: const Text('First time? Activate account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
