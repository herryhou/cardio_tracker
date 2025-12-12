import 'package:flutter/material.dart';

/// Modern Blood Pressure Tracker Theme with AHA Medical Colors
/// Based on Material Design 3 with medical color standards
class AppTheme {
  /// Spacing System Constants
  /// All spacing follows an 8dp grid system for consistency
  static const AppSpacing spacing = AppSpacing._();

  // AHA Medical Color Standards (WCAG AA Compliant)
  // static const Color _normalColor =
  //     const Color(0xFF2E7D32); // Darker Green for better contrast
  // static const Color _elevatedColor =
  //     const Color(0xFFBF360C); // Dark Brown-Orange for WCAG AA compliance
  // static const Color _stage1Color =
  //     const Color(0xFFBF360C); // Dark Brown-Orange for WCAG AA compliance
  // static const Color _stage2Color =
  //     const Color(0xFFD32F2F); // Darker Red for better contrast
  // static const Color _crisisColor =
  //     const Color(0xFF7B1FA2); // Darker Purple for better contrast
  // static const Color _lowColor =
  //     const Color(0xFF1976D2); // Darker Blue for better contrast

  // Material Design 3 Color Scheme - 2025 UI/UX Redesign Requirements
  static const Color _primarySeed =
      Color(0xFF6A1B9A); // Deep Purple (MD3 Primary)
  // static const Color _secondarySeed =
  //     const Color(0xFFFF5252); // Soft Red (MD3 Secondary)
  // static const Color _tertiarySeed =
  //     const Color(0xFF4CAF50); // Green (MD3 Tertiary - for normal readings)

  // static const Color _backgroundLight = Color(0xFFF8FAFC); // Very light gray
  static const Color _surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color _errorLight = Color(0xFFE53935); // Material Red
  // static const Color _cardBackground =
  //     const Color(0xFFFFFFFF); // Pure white cards
  // static const Color _dividerColor = const Color(0xFFE5E7EB); // Light dividers

  // static const Color _backgroundDark = Color(0xFF0F172A); // Dark slate
  static const Color _surfaceDark = Color(0xFF1E293B); // Dark surface
  static const Color _errorDark = Color(0xFFEF5350); // Lighter red for dark

  // Typography Scale (Material Design 3)
  static const String _fontFamily = 'SF Pro Display'; // Fallback to system

  // Typography System Constants
  static const double displaySize = 48.0; // Latest reading numbers (122/88)
  static const double headerSize = 20.0; // Section headers, metric labels
  static const double bodySize =
      14.0; // Supporting text, descriptions, timestamps
  static const double headerLetterSpacing =
      4.0 / 100; // 4dp letter spacing for headers

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
        // background: _backgroundLight,
        surface: _surfaceLight,
        error: _errorLight,
      ).copyWith(
        primary: const Color(0xFF6A1B9A), // Deep Purple
        onPrimary: const Color(0xFFFFFFFF), // White text on primary
        secondary: const Color(0xFFFF5252), // Soft Red
        onSecondary: const Color(0xFFFFFFFF), // White text on secondary
        tertiary: const Color(0xFF4CAF50), // Green for normal readings
        onTertiary: const Color(0xFFFFFFFF), // White text on tertiary
        surface: _surfaceLight,
        onSurface: const Color(0xFF1C1B1F), // High contrast text (7:1)
        onSurfaceVariant: const Color(0xFF49454F), // High contrast variant text
        outline: const Color(0xFF79747E), // High contrast outlines
      ),

      // Typography
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(Brightness.light),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF6A1B9A),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6A1B9A),
          fontFamily: _fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
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
            color: Color(0xFFBDBDBD), // Darker gray for better contrast
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFBDBDBD), // Darker gray for better contrast
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6A1B9A),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          color: Color(0xFF757575), // Darker gray for better contrast
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
        selectedItemColor: Color(0xFF6A1B9A),
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
        // background: _backgroundDark,
        surface: _surfaceDark,
        error: _errorDark,
      ).copyWith(
        primary: const Color(0xFF581C87), // Very dark purple for 7:1 contrast
        onPrimary: const Color(0xFFFFFFFF), // White text on primary
        secondary: const Color(0xFFFF6B6B), // Lighter Soft Red for dark mode
        onSecondary: const Color(0xFF000000), // Black text on secondary
        tertiary: const Color(0xFF66BB6A), // Lighter green for dark mode
        onTertiary: const Color(0xFF000000), // Black text on tertiary
        surface: _surfaceDark,
        onSurface: const Color(0xFFF2F2F7), // High contrast text (7:1)
        onSurfaceVariant: const Color(0xFFCAC4D0), // High contrast variant text
        outline: const Color(0xFF938F99), // High contrast outlines
      ),

      // Typography
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(Brightness.dark),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF581C87),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF581C87),
          fontFamily: _fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
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
            color: Color(0xFF616161), // Darker gray for dark theme
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF616161), // Darker gray for dark theme
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF581C87),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E), // Lighter gray for dark theme
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
        selectedItemColor: Color(0xFF581C87),
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

  // Medical Color Accessors - updated for better contrast
  static Color getNormalColor(BuildContext context) {
    // Use darker green for light mode, lighter green for dark mode
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF10B981) // Lighter green for dark mode
        : const Color(0xFF047857); // Darker green for light mode
  }

  static Color getElevatedColor(BuildContext context) {
    // Use darker amber for light mode, lighter for dark mode
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF59E0B) // Lighter amber for dark mode
        : const Color(0xFFB45309); // Darker amber for light mode
  }

  static Color getStage1Color(BuildContext context) {
    // Use darker orange for light mode, lighter for dark mode
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF97316) // Lighter orange for dark mode
        : const Color(0xFFDC2626); // Darker red-orange for light mode
  }

  static Color getStage2Color(BuildContext context) {
    // Use darker red for light mode, lighter for dark mode
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFEF4444) // Lighter red for dark mode
        : const Color(0xFFB91C1C); // Even darker red for light mode
  }

  static Color getCrisisColor(BuildContext context) {
    // Use darker purple for light mode, lighter for dark mode
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFA855F7) // Lighter purple for dark mode
        : const Color(0xFF6D28D9); // Dark purple for light mode
  }

  static Color getLowColor(BuildContext context) {
    // Use darker blue for light mode, lighter blue for dark mode
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3B82F6) // Lighter blue for dark mode
        : const Color(0xFF1E40AF); // Darker blue for light mode
  }

  // Chart-specific color helpers for dark mode support
  static Color getChartBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
  }

  static Color getChartTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getChartGridColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.withValues(alpha: 0.2)
        : Colors.grey.withValues(alpha: 0.3);
  }

  static Color getChartAxisColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
  }

  // Text Theme Builder
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? const Color(0xFF1C1B1F) // MD3 high contrast onSurface (7:1 ratio)
        : const Color(
            0xFFF2F2F7); // MD3 high contrast onSurface for dark (7:1 ratio)

    final Color secondaryTextColor = brightness == Brightness.light
        ? const Color(0xFF49454F) // MD3 high contrast onSurfaceVariant
        : const Color(
            0xFFCAC4D0); // MD3 high contrast onSurfaceVariant for dark

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
  static const double xs = 4.0; // 0.5 * gridUnit
  static const double sm = 8.0; // 1 * gridUnit
  static const double md = 16.0; // 2 * gridUnit
  static const double lg = 24.0; // 3 * gridUnit
  static const double xl = 32.0; // 4 * gridUnit
  static const double xxl = 48.0; // 6 * gridUnit

  // Specific spacing requirements
  static const double screenMargin = 16.0; // Screen edge margins
  static const double cardPadding = 20.0; // Card padding
  static const double cardsGap = 12.0; // Space between cards
  static const double sectionGap =
      24.0; // Minimum vertical space between sections

  // Convenience methods for common EdgeInsets
  static EdgeInsets get screenMargins =>
      const EdgeInsets.symmetric(horizontal: screenMargin);
  static EdgeInsets get cardPaddingInsets => const EdgeInsets.all(cardPadding);
  static EdgeInsets get cardMargins =>
      const EdgeInsets.symmetric(vertical: cardsGap, horizontal: screenMargin);
  static EdgeInsets get sectionGapVertical =>
      const EdgeInsets.symmetric(vertical: sectionGap);
  static EdgeInsets get sectionGapHorizontal =>
      const EdgeInsets.symmetric(horizontal: sectionGap);
}
