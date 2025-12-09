import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../lib/theme/app_theme.dart';

void main() {
  group('Spacing System Tests', () {
    test('should define 8dp grid spacing constants', () {
      // Base grid unit
      expect(AppSpacing.gridUnit, 8.0);

      // Common spacing multiples
      expect(AppSpacing.xs, 4.0);    // 0.5 * gridUnit
      expect(AppSpacing.sm, 8.0);    // 1 * gridUnit
      expect(AppSpacing.md, 16.0);   // 2 * gridUnit
      expect(AppSpacing.lg, 24.0);   // 3 * gridUnit
      expect(AppSpacing.xl, 32.0);   // 4 * gridUnit
      expect(AppSpacing.xxl, 48.0);  // 6 * gridUnit
    });

    test('should define specific spacing requirements', () {
      // Screen edge margins
      expect(AppSpacing.screenMargin, 16.0);

      // Card padding
      expect(AppSpacing.cardPadding, 20.0);

      // Space between cards
      expect(AppSpacing.cardsGap, 12.0);

      // Minimum vertical space between sections
      expect(AppSpacing.sectionGap, 24.0);
    });

    test('should provide convenience methods for edge insets', () {
      // Screen margins
      final screenMargins = AppSpacing.screenMargins;
      expect(screenMargins.left, 16.0);
      expect(screenMargins.right, 16.0);
      expect(screenMargins.top, 0.0);
      expect(screenMargins.bottom, 0.0);

      // Card padding
      final cardPadding = AppSpacing.cardPaddingInsets;
      expect(cardPadding.left, 20.0);
      expect(cardPadding.right, 20.0);
      expect(cardPadding.top, 20.0);
      expect(cardPadding.bottom, 20.0);

      // Card margins
      final cardMargins = AppSpacing.cardMargins;
      expect(cardMargins.top, 12.0);
      expect(cardMargins.bottom, 12.0);
      expect(cardMargins.left, 16.0);
      expect(cardMargins.right, 16.0);

      // Section gap
      final sectionGap = AppSpacing.sectionGapVertical;
      expect(sectionGap.top, 24.0);
      expect(sectionGap.bottom, 24.0);
      expect(sectionGap.left, 0.0);
      expect(sectionGap.right, 0.0);
    });

    test('should follow 8dp grid system', () {
      // All spacing values should be multiples of 8 or meet specific requirements
      final spacingValues = [
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ];

      for (final value in spacingValues) {
        expect(value % 4, 0.0, reason: 'All spacing should be multiples of 4dp (half grid unit)');
      }
    });
  });
}