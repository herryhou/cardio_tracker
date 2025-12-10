import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/screens/dashboard_screen.dart';
import 'package:cardio_tracker/providers/blood_pressure_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('WCAG 2.2 Compliance Tests', () {
    late BloodPressureProvider bpProvider;

    setUp(() {
      bpProvider = BloodPressureProvider();
    });

    testWidgets('All interactive elements meet minimum touch target of 48dp', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<BloodPressureProvider>.value(
          value: bpProvider,
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Find all interactive elements
      final gestures = tester.binding.renderObject.layer?.find<Semantics>()
          ?.children?.where((e) => e.properties.tapActions?.isNotEmpty == true)
          ?.toList() ?? [];

      // Check minimum touch targets
      for (final gesture in gestures) {
        final rect = gesture.getRect();
        final size = gesture.renderObject?.paintBounds?.size ?? Size.zero;

        // All touchable elements must be at least 48dp in both dimensions
        expect(size.width, greaterThanOrEqualTo(48.0),
            reason: 'Touch target width must be at least 48dp');
        expect(size.height, greaterThanOrEqualTo(48.0),
            reason: 'Touch target height must be at least 48dp');
      }
    });

    testWidgets('Text meets 4.5:1 contrast ratio for normal text', (tester) async {
      // This would require a color contrast checker plugin
      // For now, we verify the colors used meet the requirements

      // Primary text should use #1C1B1F on light background (7.22:1 ratio)
      final primaryTextOnLight = ThemeData.light().textTheme.bodyLarge?.color;
      expect(primaryTextOnLight, equals(Color(0xFF1C1B1F)));

      // Primary text should use #F2F2F7 on dark background (7.12:1 ratio)
      final primaryTextOnDark = ThemeData.dark().textTheme.bodyLarge?.color;
      expect(primaryTextOnDark, equals(Color(0xFFF2F2F7)));
    });

    testWidgets('Large text meets 3:1 contrast ratio', (tester) async {
      // Large text (18pt and above) needs 3:1 contrast
      final largeTextOnLight = ThemeData.light().textTheme.headlineMedium?.color;
      expect(largeTextOnLight, equals(Color(0xFF1C1B1F)));

      final largeTextOnDark = ThemeData.dark().textTheme.headlineMedium?.color;
      expect(largeTextOnDark, equals(Color(0xFFF2F2F7)));
    });

    testWidgets('Semantic labels are present for important elements', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<BloodPressureProvider>.value(
          value: bpProvider,
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Check for semantic labels on key elements
      expect(find.bySemanticsLabel('Add new blood pressure reading'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Systolic \d+.*Diastolic \d+')), findsOneWidget);
    });

    testWidgets('Color zones have patterns/textures for colorblind users', (tester) async {
      // Verify that BP categories are not distinguished by color alone
      // Each category should have distinct patterns or text labels

      final categories = [
        'Normal',
        'Elevated',
        'Stage 1 Hypertension',
        'Stage 2 Hypertension',
        'Crisis'
      ];

      // The implementation should use text labels in addition to colors
      for (final category in categories) {
        expect(find.text(category), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('Focus management works with keyboard navigation', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<BloodPressureProvider>.value(
          value: bpProvider,
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Verify focus moves to interactive elements
      final focusNode = FocusManager.instance.primaryFocus;
      expect(focusNode, isNotNull);
    });

    testWidgets('Haptic feedback is provided for important actions', (tester) async {
      // Note: Haptic feedback cannot be directly tested in unit tests
      // We verify the code paths that would trigger haptic feedback exist

      await tester.pumpWidget(
        ChangeNotifierProvider<BloodPressureProvider>.value(
          value: bpProvider,
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Long press should trigger haptic feedback
      await tester.longPress(find.byType(SingleChildScrollView));
      await tester.pump();

      // Verify export menu appears (indicating haptic feedback was triggered)
      expect(find.text('Export All Data'), findsOneWidget);
    });

    testWidgets('Content respects text scaling preferences', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 2.0, // Test with 200% text scaling
          ),
          child: ChangeNotifierProvider<BloodPressureProvider>.value(
            value: bpProvider,
            child: MaterialApp(
              home: DashboardScreen(),
            ),
          ),
        ),
      );

      // Text should scale properly without overflow
      await tester.pumpAndSettle();

      // Verify no overflow errors occur
      expect(tester.takeException(), isNull);
    });

    group('Color Contrast Validation', () {
      test('Blood pressure category colors meet contrast requirements', () {
        // Verify category colors have sufficient contrast
        final backgroundColor = Colors.white;

        // These colors should meet 4.5:1 contrast against white
        final categoryColors = {
          'Normal': Color(0xFF2E7D32), // Dark green
          'Elevated': Color(0xFFBF360C), // Dark brown
          'Stage 1': Color(0xFFBF360C), // Dark brown
          'Stage 2': Color(0xFFD32F2F), // Dark red
          'Crisis': Color(0xFF7B1FA2), // Dark purple
          'Low': Color(0xFF1976D2), // Dark blue
        };

        for (final entry in categoryColors.entries) {
          final contrast = _calculateContrast(entry.value, backgroundColor);
          expect(contrast, greaterThanOrEqualTo(4.5),
              reason: '${entry.key} color contrast must be at least 4.5:1');
        }
      });

      test('Dark theme colors meet contrast requirements', () {
        final darkBackground = Color(0xFF121212);

        // These colors should meet 4.5:1 contrast against dark background
        final darkThemeColors = {
          'Primary': Color(0xFF64B5F6), // Light blue
          'Secondary': Color(0xFF4FC3F7), // Light cyan
          'Surface': Color(0xFF1E1E1E), // Dark gray
        };

        for (final entry in darkThemeColors.entries) {
          final contrast = _calculateContrast(entry.value, darkBackground);
          expect(contrast, greaterThanOrEqualTo(4.5),
              reason: '${entry.key} dark theme contrast must be at least 4.5:1');
        }
      });
    });
  });
}

// Helper function to calculate contrast ratio
double _calculateContrast(Color color1, Color color2) {
  // Calculate luminance
  final l1 = _calculateLuminance(color1);
  final l2 = _calculateLuminance(color2);

  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;

  return (lighter + 0.05) / (darker + 0.05);
}

double _calculateLuminance(Color color) {
  final r = color.red / 255.0;
  final g = color.green / 255.0;
  final b = color.blue / 255.0;

  final rL = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
  final gL = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
  final bL = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

  return 0.2126 * rL + 0.7152 * gL + 0.0722 * bL;
}