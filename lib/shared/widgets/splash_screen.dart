import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Minimal splash/loading screen used during bootstrap.
class SplashScreen extends StatelessWidget {
  /// Creates a splash screen.
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(AppStrings.appName),
          ],
        ),
      ),
    );
  }
}

