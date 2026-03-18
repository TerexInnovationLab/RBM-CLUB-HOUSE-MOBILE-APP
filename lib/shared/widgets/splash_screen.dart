import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Animated splash screen shown during auth/bootstrap checks.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _loopController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.1, 0.75, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.82, curve: Curves.easeOutBack),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_introController, _loopController]),
        builder: (context, child) {
          const brandLabel = 'RBM Club App';
          final revealProgress = Curves.easeOut.transform(
            _introController.value,
          );
          final revealChars = (brandLabel.length * revealProgress)
              .floor()
              .clamp(0, brandLabel.length);
          final animatedLabel = brandLabel.substring(0, revealChars);
          final showCursor =
              revealChars < brandLabel.length && _loopController.value > 0.5;

          final pulse = Curves.easeInOut.transform(_loopController.value);
          final shimmerAlignment = -1.5 + (_loopController.value * 3.0);
          final floatY = math.sin(_loopController.value * math.pi * 2) * 7.0;

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, floatY),
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Image.asset(
                        'assets/images/rbm_emblem.jpeg',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Opacity(
                  opacity: _textOpacity.value,
                  child: Transform.scale(
                    scale: 1 + (pulse * 0.01),
                    child: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(shimmerAlignment - 0.8, 0),
                          end: Alignment(shimmerAlignment + 0.8, 0),
                          colors: [
                            AppColors.primaryBlue,
                            const Color(0xFFE0B94E),
                            AppColors.primaryBlue,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        '$animatedLabel${showCursor ? '|' : ''}',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
