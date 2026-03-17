import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/route_names.dart';
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: AppColors.primaryBlue,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'RBM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Club House',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reserve Bank of Malawi',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Employee number'.toUpperCase(),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _employeeController,
                              decoration: InputDecoration(
                                hintText: 'EMP-00123',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.6),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              autocorrect: false,
                              enableSuggestions: false,
                              validator: Validators.employeeNumber,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '6-digit PIN'.toUpperCase(),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                          ),
                          const SizedBox(height: 12),
                          PinInputWidget(
                            length: 6,
                            valueLength: _pin.length,
                            errorText: auth.errorMessage,
                          ),
                          const SizedBox(height: 18),
                          if (auth.isLocked)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
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
                            confirmLabel: 'Sign in',
                            confirmIcon: Icons.login_rounded,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            auth.isLocked ? '' : 'Attempts remaining: ${auth.remainingAttempts}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: auth.remainingAttempts <= 2
                                      ? Theme.of(context).colorScheme.error
                                      : AppColors.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          if (AppConfig.isDemo) ...[
                            OutlinedButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(authProvider.notifier)
                                    .loginDemo(employeeNumber: _employeeController.text.trim());
                                if (context.mounted) context.go(RouteNames.home);
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Use demo account'),
                            ),
                            const SizedBox(height: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
