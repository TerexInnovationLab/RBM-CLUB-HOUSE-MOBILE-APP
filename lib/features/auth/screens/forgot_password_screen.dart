import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/offline_banner.dart';

/// Forgot password screen.
class ForgotPasswordScreen extends StatefulWidget {
  /// Creates a forgot password screen.
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_loading) return;

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    final email = _emailController.text.trim();
    setState(() => _loading = false);
    context.push(
      '${RouteNames.forgotPasswordCheck}?email=${Uri.encodeQueryComponent(email)}',
    );
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
                                  backgroundColor: const Color(0xFFF1F4FA),
                                ),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              child: Container(
                                width: 74,
                                height: 74,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFE6ECFA), Colors.white],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F4),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/images/rbm_emblem.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFFECF5),
                                  border: Border.all(
                                    color: const Color(0xFFF8D4E8),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: Color(0xFFCF0F72),
                                  size: 38,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Forgot Password?',
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
                              'Enter your work email and we\'ll send a 4-digit verification code.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'name@rbm.mw',
                                filled: true,
                                fillColor: const Color(0xFFF0F3F8),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E7F1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryBlue,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              validator: _validateEmail,
                              onFieldSubmitted: (_) => _sendCode(),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 52,
                              child: FilledButton(
                                onPressed: _loading ? null : _sendCode,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF111827),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
                                    : const Text('Send'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(RouteNames.login);
                                }
                              },
                              child: const Text('Back to sign in'),
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

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required.';
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }
}
