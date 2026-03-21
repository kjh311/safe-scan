import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF8EFF71); // Bio-Green
  static const Color secondary = Color(0xFFFF7354); // Safety Orange
  static const Color tertiary = Color(0xFF00E5FF); // Precision Blue
  static const Color surface = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF131313);
  static const Color surfaceContainerHigh = Color(0xFF20201F);
  static const Color onSurface = Colors.white;
  static const Color onSurfaceVariant = Color(0xFFADAAAA);
  static const Color errorContainer = Color(0xFFB92902);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      errorContainer: AppColors.errorContainer,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      ),
    ),
  );
}
