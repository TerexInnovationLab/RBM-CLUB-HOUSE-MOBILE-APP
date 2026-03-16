import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_button.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../routes/route_names.dart';
import '../providers/auth_provider.dart';
import 'set_pin_screen.dart';

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
  final _tempPinController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _employeeController.dispose();
    _tempPinController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).activateStep1(
            employeeNumber: _employeeController.text.trim(),
            temporaryPin: _tempPinController.text.trim(),
          );
      if (!mounted) return;
      context.go(
        RouteNames.setPin,
        extra: SetPinArgs(
          employeeNumber: _employeeController.text.trim(),
          temporaryPin: _tempPinController.text.trim(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activation failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: AppStrings.activationTitle),
        body: auth.isLocked
            ? const AppErrorWidget(message: 'Account locked — contact HR to unlock.')
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Text(
                        'Enter your Employee Number and temporary PIN from HR to activate your account.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _employeeController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.employeeNumberLabel,
                        ),
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.next,
                        validator: Validators.employeeNumber,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tempPinController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.temporaryPinLabel,
                        ),
                        autocorrect: false,
                        enableSuggestions: false,
                        obscureText: true,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Temporary PIN is required.'
                            : null,
                      ),
                      const Spacer(),
                      RbmButton(
                        label: AppStrings.continueLabel,
                        onPressed: _activate,
                        isLoading: _loading,
                        icon: Icons.lock_open,
                      ),
                      const SizedBox(height: 8),
                      if (AppConfig.isDemo) ...[
                        FilledButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authProvider.notifier)
                                .loginDemo(employeeNumber: _employeeController.text.trim());
                            if (!context.mounted) return;
                            context.go(RouteNames.home);
                          },
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Use demo account'),
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextButton(
                        onPressed: () => context.go(RouteNames.login),
                        child: const Text('Already activated? Log in'),
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
