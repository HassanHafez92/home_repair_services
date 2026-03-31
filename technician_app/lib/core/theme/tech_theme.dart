import 'package:flutter/material.dart';

/// Technician App Theme — Distinguished from customer app with dark navy palette
class TechColors {
  TechColors._();

  // Primary — Dark Navy (Professional technician identity)
  static const Color primary = Color(0xFF1B2B4D);
  static const Color primaryLight = Color(0xFF2B4278);
  static const Color primarySurface = Color(0xFFE8ECF4);

  // Accent — Teal (Consistent with Fixawy brand)
  static const Color accent = Color(0xFF0D7377);
  static const Color accentLight = Color(0xFF14A3A8);

  // Status Colors
  static const Color online = Color(0xFF2CB67D);
  static const Color offline = Color(0xFFE85D4A);
  static const Color busy = Color(0xFFE8A838);

  // Neutrals
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);
  static const Color divider = Color(0xFFE2E5EA);

  // Text
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);

  // Earnings
  static const Color earningsGreen = Color(0xFF2CB67D);
  static const Color earningsBackground = Color(0xFFE8F8F0);
}

class TechTheme {
  TechTheme._();

  static const String _fontFamily = 'Cairo';

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    colorScheme: const ColorScheme.light(
      primary: TechColors.primary,
      onPrimary: Colors.white,
      secondary: TechColors.accent,
      surface: TechColors.surface,
      onSurface: TechColors.textPrimary,
      error: TechColors.offline,
    ),
    scaffoldBackgroundColor: TechColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: TechColors.surface,
      foregroundColor: TechColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: TechColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TechColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: const Color(0xFF0F1419),
  );
}
