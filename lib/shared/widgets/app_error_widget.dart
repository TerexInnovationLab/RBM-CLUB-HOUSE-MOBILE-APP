import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'rbm_button.dart';

/// Standard error state widget.
class AppErrorWidget extends StatelessWidget {
  /// Creates an error widget.
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// Message to show.
  final String message;

  /// Retry action.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              RbmButton(
                label: AppStrings.retry,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

