import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import 'package:cardio_tracker/theme/app_theme.dart';
import 'package:cardio_tracker/main.dart';

void main() {
  group('Material Design 3 Tests', () {
    testWidgets('App should use Material Design 3 with correct color scheme', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const CardioTrackerApp());

      // Verify Material Design 3 is enabled
      final MaterialApp materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, true, reason: 'Material Design 3 should be enabled in light theme');
      expect(materialApp.darkTheme?.useMaterial3, true, reason: 'Material Design 3 should be enabled in dark theme');

      // Test primary color scheme for light theme
      final ColorScheme lightColorScheme = materialApp.theme!.colorScheme;
      expect(lightColorScheme.primary, const Color(0xFF6A1B9A), reason: 'Primary color should be deep purple (#6A1B9A)');
      expect(lightColorScheme.secondary, const Color(0xFFFF5252), reason: 'Secondary color should be soft red (#FF5252)');
      expect(lightColorScheme.tertiary, const Color(0xFF4CAF50), reason: 'Tertiary color should be green (#4CAF50)');

      // Test primary color scheme for dark theme
      final ColorScheme darkColorScheme = materialApp.darkTheme!.colorScheme;
      expect(darkColorScheme.primary, const Color(0xFF581C87), reason: 'Dark theme primary should be very dark purple for 7:1 contrast');
      expect(darkColorScheme.secondary, const Color(0xFFFF6B6B), reason: 'Dark theme secondary should be lighter red');
      expect(darkColorScheme.tertiary, const Color(0xFF66BB6A), reason: 'Dark theme tertiary should be lighter green');
    });

    testWidgets('Typography should use Material 2021 styles', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const CardioTrackerApp());

      // Get the text theme
      final MaterialApp materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final TextTheme lightTextTheme = materialApp.theme!.textTheme;
      final TextTheme darkTextTheme = materialApp.darkTheme!.textTheme;

      // Verify Material 2021 typography styles
      expect(lightTextTheme.displayLarge?.fontSize, 57.0, reason: 'Display Large should be 57sp');
      expect(lightTextTheme.headlineMedium?.fontSize, 28.0, reason: 'Headline Medium should be 28sp');
      expect(lightTextTheme.titleLarge?.fontSize, 22.0, reason: 'Title Large should be 22sp');
      expect(lightTextTheme.bodyLarge?.fontSize, 16.0, reason: 'Body Large should be 16sp');
      expect(lightTextTheme.labelLarge?.fontSize, 14.0, reason: 'Label Large should be 14sp');

      // Verify font family is set (system font)
      expect(lightTextTheme.bodyLarge?.fontFamily, isNotNull, reason: 'Font family should be set');
      expect(darkTextTheme.bodyLarge?.fontFamily, isNotNull, reason: 'Font family should be set for dark theme');
    });

    testWidgets('Text should have 7:1 contrast ratio for accessibility', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const CardioTrackerApp());

      // Get the color scheme
      final MaterialApp materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final ColorScheme lightColorScheme = materialApp.theme!.colorScheme;
      final ColorScheme darkColorScheme = materialApp.darkTheme!.colorScheme;

      // Test light theme contrast ratios
      double lightPrimaryContrast = _calculateContrast(lightColorScheme.onPrimary, lightColorScheme.primary);
      double lightSurfaceContrast = _calculateContrast(lightColorScheme.onSurface, lightColorScheme.surface);

      expect(lightPrimaryContrast, greaterThanOrEqualTo(7.0), reason: 'Primary text should have 7:1 contrast in light theme');
      expect(lightSurfaceContrast, greaterThanOrEqualTo(7.0), reason: 'Surface text should have 7:1 contrast in light theme');

      // Test dark theme contrast ratios
      double darkPrimaryContrast = _calculateContrast(darkColorScheme.onPrimary, darkColorScheme.primary);
      double darkSurfaceContrast = _calculateContrast(darkColorScheme.onSurface, darkColorScheme.surface);

      expect(darkPrimaryContrast, greaterThanOrEqualTo(7.0), reason: 'Primary text should have 7:1 contrast in dark theme');
      expect(darkSurfaceContrast, greaterThanOrEqualTo(7.0), reason: 'Surface text should have 7:1 contrast in dark theme');
    });

    testWidgets('Material 3 components should be properly styled', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const CardioTrackerApp());

      // Test elevated button style
      final ElevatedButtonThemeData elevatedButtonTheme = AppTheme.lightTheme.elevatedButtonTheme;
      final ButtonStyle? elevatedStyle = elevatedButtonTheme.style;

      expect(elevatedStyle, isNotNull, reason: 'Elevated button theme should be configured');

      // Test filled button style (Material 3 specific)
      final FilledButtonThemeData filledButtonTheme = AppTheme.lightTheme.filledButtonTheme;
      final ButtonStyle? filledStyle = filledButtonTheme.style;

      expect(filledStyle, isNotNull, reason: 'Filled button theme should be configured (Material 3)');

      // Test card theme with MD3 styling
      final CardThemeData cardTheme = AppTheme.lightTheme.cardTheme;
      expect(cardTheme.elevation, 2.0, reason: 'Card elevation should follow MD3 guidelines');
      expect(cardTheme.shape, isA<RoundedRectangleBorder>(), reason: 'Card should use rounded rectangle shape');
    });
  });
}

// Helper function to calculate contrast ratio
double _calculateContrast(Color foreground, Color background) {
  // Calculate relative luminance
  double getLuminance(Color color) {
    double r = color.red / 255.0;
    double g = color.green / 255.0;
    double b = color.blue / 255.0;

    r = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4).toDouble();
    g = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4).toDouble();
    b = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double l1 = getLuminance(foreground);
  double l2 = getLuminance(background);

  double lighter = l1 > l2 ? l1 : l2;
  double darker = l1 > l2 ? l2 : l1;

  return (lighter + 0.05) / (darker + 0.05);
}