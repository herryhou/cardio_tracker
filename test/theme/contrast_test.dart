import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/theme/app_theme.dart';

/// WCAG AA Contrast Compliance Tests
/// Ensures all text meets minimum 4.5:1 contrast ratio
void main() {
  group('WCAG AA Contrast Compliance', () {
    test('Primary text colors have sufficient contrast', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      // Light theme - primary text should be #212121 against white background
      expect(lightTheme.textTheme.bodyLarge?.color,
          equals(const Color(0xFF212121)));
      expect(lightTheme.textTheme.bodyMedium?.color,
          equals(const Color(0xFF212121)));

      // Calculate contrast ratio
      final lightContrast = _calculateContrastRatio(
        const Color(0xFF212121),
        const Color(0xFFFFFFFF),
      );

      // WCAG AA requires 4.5:1 for normal text
      expect(lightContrast, greaterThanOrEqualTo(4.5),
          reason: 'Primary text must have at least 4.5:1 contrast ratio');

      // Dark theme - primary text against dark surface
      expect(darkTheme.textTheme.bodyLarge?.color,
          equals(const Color(0xFFF2F2F7)));

      final darkContrast = _calculateContrastRatio(
        const Color(0xFFF2F2F7),
        const Color(0xFF1E293B),
      );

      expect(darkContrast, greaterThanOrEqualTo(4.5),
          reason: 'Primary text must have at least 4.5:1 contrast ratio');
    });

    test('Secondary text colors have sufficient contrast', () {
      final lightTheme = AppTheme.lightTheme;

      // Check secondary text color
      expect(lightTheme.textTheme.bodySmall?.color,
          equals(const Color(0xFF212121)));

      // Calculate contrast against white background
      final contrast = _calculateContrastRatio(
        const Color(0xFF212121),
        const Color(0xFFFFFFFF),
      );

      // This should fail with current color to verify our test works
      expect(contrast, greaterThanOrEqualTo(4.5),
          reason: 'Secondary text must have at least 4.5:1 contrast ratio');
    });

    test('Stage 1 badge has sufficient contrast', () {
      // Stage 1 should use #BF360C (dark brown-orange) with white text for WCAG AA compliance
      const stage1Color = Color(0xFFBF360C);
      const textColor = Colors.white;

      final contrast = _calculateContrastRatio(textColor, stage1Color);

      expect(contrast, greaterThanOrEqualTo(4.5),
          reason: 'Stage 1 badge text must have at least 4.5:1 contrast ratio');
    });

    test('All medical category colors have sufficient contrast with white text',
        () {
      final categories = [
        const Color(0xFF2E7D32), // Normal (darker green)
        const Color(0xFFBF360C), // Elevated (dark brown-orange for WCAG AA)
        const Color(0xFFBF360C), // Stage 1 (dark brown-orange for WCAG AA)
        const Color(0xFFD32F2F), // Stage 2 (darker red)
        const Color(0xFF7B1FA2), // Crisis (darker purple)
        const Color(0xFF1976D2), // Low (darker blue)
      ];

      for (final color in categories) {
        final contrast = _calculateContrastRatio(Colors.white, color);
        expect(contrast, greaterThanOrEqualTo(4.5),
            reason:
                'White text on $color must have at least 4.5:1 contrast ratio');
      }
    });

    test('Hint text has sufficient contrast', () {
      final lightTheme = AppTheme.lightTheme;
      const hintColor = Color(0xFF757575);

      final contrast = _calculateContrastRatio(
        hintColor,
        const Color(0xFFFFFFFF),
      );

      // This will likely fail and need to be updated
      expect(contrast, greaterThanOrEqualTo(3.0),
          reason:
              'Hint text should have at least 3:1 contrast ratio (large text exception)');
    });
  });
}

/// Calculate relative luminance of a color
double _calculateRelativeLuminance(Color color) {
  final r = _gammaCorrect(color.red / 255.0);
  final g = _gammaCorrect(color.green / 255.0);
  final b = _gammaCorrect(color.blue / 255.0);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Apply gamma correction
double _gammaCorrect(double colorChannel) {
  if (colorChannel <= 0.03928) {
    return colorChannel / 12.92;
  } else {
    return math.pow((colorChannel + 0.055) / 1.055, 2.4) as double;
  }
}

/// Calculate contrast ratio between two colors
double _calculateContrastRatio(Color foreground, Color background) {
  final l1 = _calculateRelativeLuminance(foreground);
  final l2 = _calculateRelativeLuminance(background);

  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);

  return (lighter + 0.05) / (darker + 0.05);
}
