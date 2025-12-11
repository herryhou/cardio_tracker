import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/screens/add_reading_screen.dart';

void main() {
  group('Save Button Behavior', () {
    testWidgets('Save button should be disabled by default (onSave is null)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddReadingContent(
              isInModal: true,
            ),
          ),
        ),
      );

      await tester.pump();

      // Find the save button - it should exist
      final saveButton = find.byType(ElevatedButton);
      expect(saveButton, findsOneWidget);

      // Check that the button is disabled by default (onSave is null)
      final ElevatedButton button = tester.widget(saveButton);
      expect(button.onPressed, isNull);

      // Button should still show "Save Reading" text
      expect(find.text('Save Reading'), findsOneWidget);
    });

    testWidgets('Save button can be disabled when onSave is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddReadingContent(
              isInModal: true,
              onSave: null,
            ),
          ),
        ),
      );

      await tester.pump();

      // Find the save button
      final saveButton = find.byType(ElevatedButton);
      expect(saveButton, findsOneWidget);

      // Check that the button is disabled (onPressed is null)
      final ElevatedButton button = tester.widget(saveButton);
      expect(button.onPressed, isNull);
    });
  });
}