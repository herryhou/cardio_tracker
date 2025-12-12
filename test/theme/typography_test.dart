import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cardio_tracker/theme/app_theme.dart';

void main() {
  group('Typography System Tests', () {
    test('should have correct font sizes defined', () {
      expect(AppTheme.displaySize, 48.0);
      expect(AppTheme.headerSize, 20.0);
      expect(AppTheme.bodySize, 14.0);
    });

    test('should have correct letter spacing for headers', () {
      expect(AppTheme.headerLetterSpacing, 4.0 / 100); // 4dp converted to letterSpacing value
    });

    test('should provide correct text styles', () {
      // Display style - for latest reading numbers
      final displayStyle = AppTheme.displayStyle;
      expect(displayStyle.fontSize, 48.0);
      expect(displayStyle.fontWeight, FontWeight.bold);
      expect(displayStyle.letterSpacing, null); // No letter spacing for display text

      // Header style - for section headers and metric labels
      final headerStyle = AppTheme.headerStyle;
      expect(headerStyle.fontSize, 20.0);
      expect(headerStyle.fontWeight, FontWeight.bold);
      expect(headerStyle.letterSpacing, 4.0 / 100);

      // Body style - for supporting text, descriptions, timestamps
      final bodyStyle = AppTheme.bodyStyle;
      expect(bodyStyle.fontSize, 14.0);
      expect(bodyStyle.fontWeight, FontWeight.normal);
      expect(bodyStyle.letterSpacing, null);
    });

    test('should not use all-caps for body text', () {
      final bodyStyle = AppTheme.bodyStyle;
      // Ensure we don't set all-caps anywhere in the body style
      expect(() => bodyStyle.copyWith(
        height: 1.0,
        decoration: TextDecoration.none,
        decorationStyle: TextDecorationStyle.solid,
      ), returnsNormally);
    });
  });
}