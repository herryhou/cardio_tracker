import 'package:flutter/material.dart';

/// Modern Blood Pressure Tracker Theme with AHA Medical Colors
/// Based on Material Design 3 with medical color standards
class AppTheme {
  /// Spacing System Constants
  /// All spacing follows an 8dp grid system for consistency
  static const AppSpacing spacing = AppSpacing._();

  // AHA Medical Color Standards (WCAG AA Compliant)
  static const Color _normalColor = Color(0xFF2E7D32);     // Darker Green for better contrast
  static const Color _elevatedColor = Color(0xFFBF360C);   // Dark Brown-Orange for WCAG AA compliance
  static const Color _stage1Color = Color(0xFFBF360C);     // Dark Brown-Orange for WCAG AA compliance
  static const Color _stage2Color = Color(0xFFD32F2F);     // Darker Red for better contrast
  static const Color _crisisColor = Color(0xFF7B1FA2);     // Darker Purple for better contrast
  static const Color _lowColor = Color(0xFF1976D2);        // Darker Blue for better contrast

  // Modern Neutral Palette - Production Medical Colors
  static const Color _primarySeed = Color(0xFF2563EB);     // Medical Blue (more vibrant)
  static const Color _backgroundLight = Color(0xFFF8FAFC); // Very light gray
  static const Color _surfaceLight = Color(0xFFFFFFFF);    // Pure white
  static const Color _errorLight = Color(0xFFE53935);      // Material Red
  static const Color _cardBackground = Color(0xFFFFFFFF);  // Pure white cards
  static const Color _dividerColor = Color(0xFFE5E7EB);    // Light dividers

  static const Color _backgroundDark = Color(0xFF0F172A);  // Dark slate
  static const Color _surfaceDark = Color(0xFF1E293B);     // Dark surface
  static const Color _errorDark = Color(0xFFEF5350);       // Lighter red for dark

  // Typography Scale (Material Design 3)
  static const String _fontFamily = 'SF Pro Display'; // Fallback to system

  // Typography System Constants
  static const double displaySize = 48.0;  // Latest reading numbers (122/88)
  static const double headerSize = 20.0;   // Section headers, metric labels
  static const double bodySize = 14.0;     // Supporting text, descriptions, timestamps
  static const double headerLetterSpacing = 4.0 / 100; // 4dp letter spacing for headers

  // Typography System Styles
  static TextStyle get displayStyle => const TextStyle(
    fontSize: displaySize,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
    letterSpacing: null, // No letter spacing for display text
  );

  static TextStyle get headerStyle => const TextStyle(
    fontSize: headerSize,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
    letterSpacing: headerLetterSpacing,
  );

  static TextStyle get bodyStyle => const TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.normal,
    fontFamily: _fontFamily,
    letterSpacing: null,
  );

  // Light Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primarySeed,
        brightness: Brightness.light,
        background: _backgroundLight,
        surface: _surfaceLight,
        error: _errorLight,
      ).copyWith(
        primary: const Color(0xFF1976D2),
        secondary: const Color(0xFF03A9F4),
        tertiary: const Color(0xFF00ACC1),
      ),

      // Typography
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(Brightness.light),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1976D2),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1976D2),
          fontFamily: _fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: _surfaceLight,
        surfaceTintColor: Colors.transparent,
        margin: AppSpacing.cardMargins,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: _fontFamily,
          ),
        ),
      ),

      // Filled Button Theme (Modern Material 3)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: _fontFamily,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: _fontFamily,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(width: 1),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: _fontFamily,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD),  // Darker gray for better contrast
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD),  // Darker gray for better contrast
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1976D2),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          color: Color(0xFF757575),  // Darker gray for better contrast
          fontSize: 14,
          fontFamily: _fontFamily,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontFamily: _fontFamily,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: _surfaceLight,
        selectedItemColor: Color(0xFF1976D2),
        unselectedItemColor: Color(0xFF9E9E9E),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: _fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primarySeed,
        brightness: Brightness.dark,
        background: _backgroundDark,
        surface: _surfaceDark,
        error: _errorDark,
      ).copyWith(
        primary: const Color(0xFF64B5F6),
        secondary: const Color(0xFF4FC3F7),
        tertiary: const Color(0xFF4DD0E1),
      ),

      // Typography
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(Brightness.dark),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF64B5F6),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64B5F6),
          fontFamily: _fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: _surfaceDark,
        surfaceTintColor: Colors.transparent,
        margin: AppSpacing.cardMargins,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: _fontFamily,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF616161),  // Darker gray for dark theme
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF616161),  // Darker gray for dark theme
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF64B5F6),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF5350),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF5350),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),  // Lighter gray for dark theme
          fontSize: 14,
          fontFamily: _fontFamily,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontFamily: _fontFamily,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: _surfaceDark,
        selectedItemColor: Color(0xFF64B5F6),
        unselectedItemColor: Color(0xFF9E9E9E),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: _fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }

  // Medical Color Accessors
  static Color getNormalColor(BuildContext context) => _normalColor;
  static Color getElevatedColor(BuildContext context) => _elevatedColor;
  static Color getStage1Color(BuildContext context) => _stage1Color;
  static Color getStage2Color(BuildContext context) => _stage2Color;
  static Color getCrisisColor(BuildContext context) => _crisisColor;
  static Color getLowColor(BuildContext context) => _lowColor;

  // Text Theme Builder
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? const Color(0xFF212121)  // Changed from #1C1C1E for better contrast
        : const Color(0xFFF2F2F7);

    final Color secondaryTextColor = brightness == Brightness.light
        ? const Color(0xFF212121)  // Changed from #6B7280 to #212121 for WCAG AA compliance
        : const Color(0xFFA1A1AA);

    return TextTheme(
      // Display Styles (rarely used)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: _fontFamily,
      ),

      // Headline Styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: _fontFamily,
      ),

      // Title Styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: _fontFamily,
      ),

      // Body Styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        fontFamily: _fontFamily,
      ),

      // Label Styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: _fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        fontFamily: _fontFamily,
      ),
    );
  }
}

/// Spacing System for the Cardio Tracker App
/// Follows an 8dp grid system with specific requirements for medical UI
class AppSpacing {
  const AppSpacing._();

  // Base grid unit (8dp)
  static const double gridUnit = 8.0;

  // Standard spacing values based on 8dp grid
  static const double xs = 4.0;    // 0.5 * gridUnit
  static const double sm = 8.0;    // 1 * gridUnit
  static const double md = 16.0;   // 2 * gridUnit
  static const double lg = 24.0;   // 3 * gridUnit
  static const double xl = 32.0;   // 4 * gridUnit
  static const double xxl = 48.0;  // 6 * gridUnit

  // Specific spacing requirements
  static const double screenMargin = 16.0;  // Screen edge margins
  static const double cardPadding = 20.0;   // Card padding
  static const double cardsGap = 12.0;      // Space between cards
  static const double sectionGap = 24.0;    // Minimum vertical space between sections

  // Convenience methods for common EdgeInsets
  static EdgeInsets get screenMargins => const EdgeInsets.symmetric(horizontal: screenMargin);
  static EdgeInsets get cardPaddingInsets => const EdgeInsets.all(cardPadding);
  static EdgeInsets get cardMargins => const EdgeInsets.symmetric(vertical: cardsGap, horizontal: screenMargin);
  static EdgeInsets get sectionGapVertical => const EdgeInsets.symmetric(vertical: sectionGap);
  static EdgeInsets get sectionGapHorizontal => const EdgeInsets.symmetric(horizontal: sectionGap);
}