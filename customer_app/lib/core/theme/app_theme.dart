import 'package:flutter/material.dart';

/// Fixawy Brand Colors — Premium Egyptian palette
class FixawyColors {
  FixawyColors._();

  // Primary — Deep Teal (Trust & professionalism)
  static const Color primary = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14A3A8);
  static const Color primaryDark = Color(0xFF095456);
  static const Color primarySurface = Color(0xFFE6F5F5);

  // Secondary — Warm Amber (Energy & urgency for emergency services)
  static const Color secondary = Color(0xFFE8A838);
  static const Color secondaryLight = Color(0xFFF4C66B);
  static const Color secondaryDark = Color(0xFFC48A1E);

  // Accent — Coral (Attention-grabbing for CTAs)
  static const Color accent = Color(0xFFE85D4A);
  static const Color accentLight = Color(0xFFFF8A7A);

  // Neutrals
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE9ECEF);

  // Text
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF2CB67D);
  static const Color warning = Color(0xFFE8A838);
  static const Color error = Color(0xFFE85D4A);
  static const Color info = Color(0xFF4A9FE5);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A2028);
  static const Color darkSurfaceVariant = Color(0xFF242D38);
  static const Color darkCardBackground = Color(0xFF1E2730);
  static const Color darkTextPrimary = Color(0xFFE8EBED);
  static const Color darkTextSecondary = Color(0xFF8B95A1);
}

/// Fixawy Theme — Arabic-first with premium aesthetics
class FixawyTheme {
  FixawyTheme._();

  // ─── Typography ─────────────────────────────────────────────────────
  static const String _fontFamily = 'Cairo';

  static TextTheme get _textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      );

  // ─── Light Theme ────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: _fontFamily,

        // Colors
        colorScheme: const ColorScheme.light(
          primary: FixawyColors.primary,
          onPrimary: FixawyColors.textOnPrimary,
          primaryContainer: FixawyColors.primarySurface,
          secondary: FixawyColors.secondary,
          onSecondary: FixawyColors.textPrimary,
          tertiary: FixawyColors.accent,
          surface: FixawyColors.surface,
          onSurface: FixawyColors.textPrimary,
          error: FixawyColors.error,
          outline: FixawyColors.divider,
        ),
        scaffoldBackgroundColor: FixawyColors.background,

        // Text
        textTheme: _textTheme.apply(
          bodyColor: FixawyColors.textPrimary,
          displayColor: FixawyColors.textPrimary,
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: FixawyColors.surface,
          foregroundColor: FixawyColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 1,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FixawyColors.textPrimary,
          ),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: FixawyColors.primary,
            foregroundColor: FixawyColors.textOnPrimary,
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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: FixawyColors.primary,
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: FixawyColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: FixawyColors.primary,
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: FixawyColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: FixawyColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: FixawyColors.error, width: 1.5),
          ),
          hintStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: FixawyColors.textHint,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: FixawyColors.textSecondary,
            fontSize: 14,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: FixawyColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: FixawyColors.divider, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: FixawyColors.surface,
          selectedItemColor: FixawyColors.primary,
          unselectedItemColor: FixawyColors.textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
          ),
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: FixawyColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: FixawyColors.divider,
          thickness: 1,
          space: 1,
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: FixawyColors.primarySurface,
          labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FixawyColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: FixawyColors.accent,
          foregroundColor: FixawyColors.textOnPrimary,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: FixawyColors.primary,
          linearTrackColor: FixawyColors.primarySurface,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: FixawyColors.textPrimary,
          contentTextStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: FixawyColors.textOnPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ─── Dark Theme ─────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: _fontFamily,

        colorScheme: const ColorScheme.dark(
          primary: FixawyColors.primaryLight,
          onPrimary: FixawyColors.darkBackground,
          primaryContainer: FixawyColors.primaryDark,
          secondary: FixawyColors.secondaryLight,
          onSecondary: FixawyColors.darkBackground,
          tertiary: FixawyColors.accentLight,
          surface: FixawyColors.darkSurface,
          onSurface: FixawyColors.darkTextPrimary,
          error: FixawyColors.error,
          outline: FixawyColors.darkSurfaceVariant,
        ),
        scaffoldBackgroundColor: FixawyColors.darkBackground,

        textTheme: _textTheme.apply(
          bodyColor: FixawyColors.darkTextPrimary,
          displayColor: FixawyColors.darkTextPrimary,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: FixawyColors.darkSurface,
          foregroundColor: FixawyColors.darkTextPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FixawyColors.darkTextPrimary,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: FixawyColors.primaryLight,
            foregroundColor: FixawyColors.darkBackground,
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

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: FixawyColors.darkSurfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: FixawyColors.primaryLight, width: 2),
          ),
          hintStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: FixawyColors.darkTextSecondary,
            fontSize: 14,
          ),
        ),

        cardTheme: CardThemeData(
          color: FixawyColors.darkCardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: FixawyColors.darkSurfaceVariant,
              width: 1,
            ),
          ),
          margin: EdgeInsets.zero,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: FixawyColors.darkSurface,
          selectedItemColor: FixawyColors.primaryLight,
          unselectedItemColor: FixawyColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: FixawyColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: FixawyColors.darkSurfaceVariant,
          contentTextStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: FixawyColors.darkTextPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
