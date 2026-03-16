import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Simple confirmation dialog.
class ConfirmationDialog extends StatelessWidget {
  /// Creates a confirmation dialog.
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirmLabel,
    this.cancelLabel = AppStrings.cancelLabel,
  });

  /// Title.
  final String title;

  /// Message.
  final String message;

  /// Confirm label.
  final String confirmLabel;

  /// Cancel label.
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

