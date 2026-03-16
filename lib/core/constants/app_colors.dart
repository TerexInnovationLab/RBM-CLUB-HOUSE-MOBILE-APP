import 'package:flutter/material.dart';

/// RBM design system colors.
abstract final class AppColors {
  /// #003A8F — App bar, greeting, primary.
  static const Color primaryBlue = Color(0xFF003A8F);

  /// #0056B3 — Buttons, links, CTAs.
  static const Color secondaryBlue = Color(0xFF0056B3);

  static const Color successGreen = Color(0xFF2E7D32);

  /// #F9A825 — Warnings, badges, reset.
  static const Color warningOrange = Color(0xFFF9A825);
  static const Color dangerRed = Color(0xFFC62828);

  /// #F4F6F8 — Page background, input fills.
  static const Color backgroundLight = Color(0xFFF4F6F8);
  static const Color surfaceLight = Colors.white;

  static const Color borderGray = Color(0xFFE0E0E0);

  /// #333333 — Body text, headings.
  static const Color textPrimary = Color(0xFF333333);

  static const Color textSecondary = Color(0xFF666666);

  /// #999999 — Inactive navigation tab labels/icons.
  static const Color inactive = Color(0xFF999999);

  static const Color darkSurface = Color(0xFF121318);
  static const Color darkCardBg = Color(0xFF1C1D24);
}
