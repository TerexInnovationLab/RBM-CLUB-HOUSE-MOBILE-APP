import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Snackbar tone variants aligned to RBM semantic colors.
enum TopSnackBarTone { info, success, warning, error }

/// Optional action for the top snackbar.
class TopSnackBarAction {
  /// Creates a top snackbar action.
  const TopSnackBarAction({required this.label, required this.onPressed});

  /// Action button label.
  final String label;

  /// Callback when action is tapped.
  final VoidCallback onPressed;
}

/// Shows a floating, top-positioned snackbar.
abstract final class TopSnackBar {
  static OverlayEntry? _entry;
  static Timer? _timer;

  /// Displays a top snackbar message.
  static void show(
    BuildContext context, {
    required String message,
    TopSnackBarTone tone = TopSnackBarTone.info,
    Duration duration = const Duration(seconds: 3),
    TopSnackBarAction? action,
  }) {
    _timer?.cancel();
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final style = _styleFor(tone);
    _entry = OverlayEntry(
      builder: (overlayContext) {
        final topInset = MediaQuery.of(overlayContext).padding.top + 10;
        return Positioned(
          top: topInset,
          left: 14,
          right: 14,
          child: Material(
            color: Colors.transparent,
            child: _TopSnackBarCard(
              icon: style.icon,
              message: message,
              start: style.start,
              end: style.end,
              action: action == null
                  ? null
                  : TopSnackBarAction(
                      label: action.label,
                      onPressed: () {
                        dismiss();
                        action.onPressed();
                      },
                    ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);
    _timer = Timer(duration, dismiss);
  }

  /// Dismisses the active top snackbar, if any.
  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static _TopSnackBarStyle _styleFor(TopSnackBarTone tone) {
    return switch (tone) {
      TopSnackBarTone.info => _TopSnackBarStyle(
        icon: Icons.info_outline_rounded,
        start: AppColors.primaryBlue,
        end: AppColors.secondaryBlue,
      ),
      TopSnackBarTone.success => _TopSnackBarStyle(
        icon: Icons.check_circle_outline_rounded,
        start: AppColors.successGreen,
        end: const Color(0xFF1F6B2A),
      ),
      TopSnackBarTone.warning => _TopSnackBarStyle(
        icon: Icons.warning_amber_rounded,
        start: AppColors.warningOrange,
        end: const Color(0xFFE28705),
      ),
      TopSnackBarTone.error => _TopSnackBarStyle(
        icon: Icons.error_outline_rounded,
        start: AppColors.dangerRed,
        end: const Color(0xFF9F1F1F),
      ),
    };
  }
}

class _TopSnackBarStyle {
  const _TopSnackBarStyle({
    required this.icon,
    required this.start,
    required this.end,
  });

  final IconData icon;
  final Color start;
  final Color end;
}

class _TopSnackBarCard extends StatelessWidget {
  const _TopSnackBarCard({
    required this.icon,
    required this.message,
    required this.start,
    required this.end,
    this.action,
  });

  final IconData icon;
  final String message;
  final Color start;
  final Color end;
  final TopSnackBarAction? action;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [start, end]),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 6),
              TextButton(
                onPressed: action!.onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                ),
                child: Text(action!.label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
