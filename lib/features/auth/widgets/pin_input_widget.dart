import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Masked PIN input indicator (dots) without system keyboard.
class PinInputWidget extends StatelessWidget {
  /// Creates a PIN input widget.
  const PinInputWidget({
    super.key,
    required this.length,
    required this.valueLength,
    this.errorText,
  });

  /// Expected PIN length.
  final int length;

  /// Current entered digits.
  final int valueLength;

  /// Optional error message.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final dots = List<Widget>.generate(length, (i) {
      final filled = i < valueLength;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryBlue : Colors.transparent,
          border: Border.all(color: AppColors.borderGray),
          shape: BoxShape.circle,
        ),
      );
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dots
              .expand((w) => [w, const SizedBox(width: 12)])
              .toList()
            ..removeLast(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

