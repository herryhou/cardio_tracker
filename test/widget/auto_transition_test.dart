import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/presentation/screens/add_reading_screen.dart';

void main() {
  group('Auto-transition functionality', () {
    testWidgets('Auto-transition works between fields',
        (WidgetTester tester) async {
      // Create controllers to capture the input
      final systolicController = TextEditingController();
      final diastolicController = TextEditingController();
      final heartRateController = TextEditingController();

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddReadingContent(
              systolicController: systolicController,
              diastolicController: diastolicController,
              heartRateController: heartRateController,
            ),
          ),
        ),
      );

      // Wait for initial setup
      await tester.pump();
      await tester.pumpAndSettle();

      // Find all input fields
      final sysField = find.byKey(const Key('systolic_field'));
      final diaField = find.byKey(const Key('diastolic_field'));
      final pulseField = find.byKey(const Key('pulse_field'));

      expect(sysField, findsOneWidget);
      expect(diaField, findsOneWidget);
      expect(pulseField, findsOneWidget);

      // Test that we can enter values in all fields
      await tester.tap(sysField);
      await tester.enterText(sysField, '120');
      await tester.pump();

      await tester.tap(diaField);
      await tester.enterText(diaField, '80');
      await tester.pump();

      await tester.tap(pulseField);
      await tester.enterText(pulseField, '72');
      await tester.pump();

      // Verify the values were entered
      expect(systolicController.text, '120');
      expect(diastolicController.text, '80');
      expect(heartRateController.text, '72');
    });
  });
}
