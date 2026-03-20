import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/top_snackbar.dart';

/// Check email verification screen for password reset.
class ForgotPasswordCheckScreen extends StatefulWidget {
  /// Creates a check email screen.
  const ForgotPasswordCheckScreen({super.key, required this.email});

  /// Email receiving the code.
  final String email;

  @override
  State<ForgotPasswordCheckScreen> createState() =>
      _ForgotPasswordCheckScreenState();
}

class _ForgotPasswordCheckScreenState extends State<ForgotPasswordCheckScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsLeft = 30;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  bool get _isCodeComplete => _code.length == 4;

  void _startResendTimer() {
    _resendTimer?.cancel();
    _secondsLeft = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _onCodeChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      setState(() {});
      return;
    }

    _codeControllers[index].text = digits;
    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (!_isCodeComplete || _verifying) return;

    setState(() => _verifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    TopSnackBar.show(
      context,
      message:
          'Verification completed. Contact HR if you still need a PIN reset.',
      tone: TopSnackBarTone.info,
      duration: const Duration(seconds: 4),
    );
    context.go(RouteNames.login);
  }

  void _resendCode() {
    if (_secondsLeft > 0) return;

    for (final controller in _codeControllers) {
      controller.clear();
    }
    _startResendTimer();
    setState(() {});
    TopSnackBar.show(
      context,
      message: 'A new 4-digit code has been sent to ${widget.email}.',
      tone: TopSnackBarTone.success,
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
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
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
                                  context.go(RouteNames.forgotPassword);
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
                            'Check your email',
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
                            'We sent a 4-digit code to\n${widget.email}.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                  right: index == 3 ? 0 : 10,
                                ),
                                child: SizedBox(
                                  width: 56,
                                  child: TextField(
                                    controller: _codeControllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF0F3F8),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
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
                                      counterText: '',
                                    ),
                                    onChanged: (value) =>
                                        _onCodeChanged(index, value),
                                    onSubmitted: (_) => _verify(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _isCodeComplete && !_verifying
                                  ? _verify
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF111827),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _verifying
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Verify'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Didn\'t receive the email? ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: _secondsLeft == 0
                                    ? _resendCode
                                    : null,
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  _secondsLeft == 0
                                      ? 'Resend'
                                      : 'Resend ($_secondsLeft)',
                                  style: TextStyle(
                                    color: _secondsLeft == 0
                                        ? AppColors.primaryBlue
                                        : AppColors.inactive,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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
