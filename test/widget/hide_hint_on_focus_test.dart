import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/screens/add_reading_screen.dart';

void main() {
  group('Hide hints on focus', () {
    testWidgets('Fields can be focused and interacted with', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddReadingContent(),
          ),
        ),
      );

      // Wait for initial setup
      await tester.pump();
      await tester.pumpAndSettle();

      // Find the fields using their unique keys
      final sysField = find.byKey(const Key('systolic_field'));
      final diaField = find.byKey(const Key('diastolic_field'));
      final pulseField = find.byKey(const Key('pulse_field'));
      final notesField = find.byType(TextFormField).last;

      expect(sysField, findsOneWidget);
      expect(diaField, findsOneWidget);
      expect(pulseField, findsOneWidget);
      expect(notesField, findsOneWidget);

      // Test that we can interact with all fields
      // Tap on SYS field
      await tester.tap(find.descendant(
        of: sysField,
        matching: find.byType(TextFormField),
      ));
      await tester.pump();

      // Enter a value
      await tester.enterText(find.descendant(
        of: sysField,
        matching: find.byType(TextFormField),
      ), '120');
      await tester.pump();

      // Tap on DIA field
      await tester.tap(find.descendant(
        of: diaField,
        matching: find.byType(TextFormField),
      ));
      await tester.pump();

      // Enter a value
      await tester.enterText(find.descendant(
        of: diaField,
        matching: find.byType(TextFormField),
      ), '80');
      await tester.pump();

      // Tap on Pulse field
      await tester.tap(find.descendant(
        of: pulseField,
        matching: find.byType(TextFormField),
      ));
      await tester.pump();

      // Enter a value
      await tester.enterText(find.descendant(
        of: pulseField,
        matching: find.byType(TextFormField),
      ), '72');
      await tester.pump();

      // Tap on Notes field
      await tester.tap(notesField);
      await tester.pump();

      // Enter a note
      await tester.enterText(notesField, 'Test note');
      await tester.pump();

      // Verify all values were entered
      expect(find.text('120'), findsWidgets);
      expect(find.text('80'), findsWidgets);
      expect(find.text('72'), findsWidgets);
      expect(find.text('Test note'), findsOneWidget);
    });
  });
}