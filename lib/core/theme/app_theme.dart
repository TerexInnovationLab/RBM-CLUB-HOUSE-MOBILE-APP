import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Application Material 3 themes.
abstract final class AppTheme {
  /// Light theme.
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryBlue,
      surface: AppColors.surfaceLight,
      error: AppColors.dangerRed,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
        titleMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w400),
        labelMedium: GoogleFonts.roboto(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderGray, thickness: 1),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.borderGray, width: 1),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.secondaryBlue),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.primaryBlue.withAlpha(31),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? AppColors.primaryBlue : AppColors.inactive,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primaryBlue : AppColors.inactive,
          ),
        ),
      ),
    );
  }

  /// Dark theme.
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkSurface,
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
      ),
    );
  }
}
