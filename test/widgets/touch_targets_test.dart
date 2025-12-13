import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/presentation/screens/dashboard_screen.dart';
import 'package:cardio_tracker/widgets/reading_summary_card.dart';
import 'package:cardio_tracker/presentation/screens/add_reading_screen.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

void main() {
  group('Touch Targets Compliance Test', () {
    testWidgets('Dashboard screen touch targets meet minimum requirements', (WidgetTester tester) async {
      // Build the dashboard screen
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // FAB button should be 56dp minimum
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      final RenderBox fabRenderBox = tester.renderObject(fab);
      final Size fabSize = fabRenderBox.size;
      expect(fabSize.width, greaterThanOrEqualTo(56.0),
          reason: 'FAB button width should be at least 56dp');
      expect(fabSize.height, greaterThanOrEqualTo(56.0),
          reason: 'FAB button height should be at least 56dp');

      // Check for IconButton widgets
      final iconButtons = find.byType(IconButton);
      for (int i = 0; i < iconButtons.evaluate().length; i++) {
        final button = iconButtons.at(i);
        final RenderBox buttonRenderBox = tester.renderObject(button);
        final Size buttonSize = buttonRenderBox.size;
        expect(buttonSize.width, greaterThanOrEqualTo(44.0),
            reason: 'IconButton width should be at least 44dp');
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'IconButton height should be at least 44dp');
      }

      // Check for ElevatedButton widgets
      final elevatedButtons = find.byType(ElevatedButton);
      for (int i = 0; i < elevatedButtons.evaluate().length; i++) {
        final button = elevatedButtons.at(i);
        final RenderBox buttonRenderBox = tester.renderObject(button);
        final Size buttonSize = buttonRenderBox.size;
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'ElevatedButton height should be at least 44dp');
      }

      // Check for TextButton widgets
      final textButtons = find.byType(TextButton);
      for (int i = 0; i < textButtons.evaluate().length; i++) {
        final button = textButtons.at(i);
        final RenderBox buttonRenderBox = tester.renderObject(button);
        final Size buttonSize = buttonRenderBox.size;
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'TextButton height should be at least 44dp');
      }
    });

    testWidgets('Add reading content touch targets meet minimum requirements', (WidgetTester tester) async {
      // Build the add reading content
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddReadingContent(isInModal: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Text form fields should have adequate touch targets
      final textFields = find.byType(TextField);
      for (int i = 0; i < textFields.evaluate().length; i++) {
        final field = textFields.at(i);
        final RenderBox fieldRenderBox = tester.renderObject(field);
        final Size fieldSize = fieldRenderBox.size;
        expect(fieldSize.height, greaterThanOrEqualTo(44.0),
            reason: 'TextField height should be at least 44dp');
      }

      // Save/Add buttons
      final saveButtons = find.byType(ElevatedButton);
      for (int i = 0; i < saveButtons.evaluate().length; i++) {
        final button = saveButtons.at(i);
        final RenderBox buttonRenderBox = tester.renderObject(button);
        final Size buttonSize = buttonRenderBox.size;
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'Save button height should be at least 44dp');
      }

      // Dropdown buttons
      final dropdownButtons = find.byType(DropdownButtonFormField);
      for (int i = 0; i < dropdownButtons.evaluate().length; i++) {
        final button = dropdownButtons.at(i);
        final RenderBox buttonRenderBox = tester.renderObject(button);
        final Size buttonSize = buttonRenderBox.size;
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'DropdownButton height should be at least 44dp');
      }
    });

    testWidgets('Reading Summary Card touch targets meet minimum requirements', (WidgetTester tester) async {
      // Create a sample reading
      final sampleReading = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 70,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Build the reading summary card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSummaryCard(
              reading: sampleReading,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for any buttons in the summary card
      final cardButtons = find.descendant(
        of: find.byType(ReadingSummaryCard),
        matching: find.byType(IconButton),
      );

      for (int i = 0; i < cardButtons.evaluate().length; i++) {
        final button = cardButtons.at(i);
        final RenderBox buttonRenderBox = tester.renderObject(button);
        final Size buttonSize = buttonRenderBox.size;
        expect(buttonSize.width, greaterThanOrEqualTo(44.0),
            reason: 'Card IconButton width should be at least 44dp');
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'Card IconButton height should be at least 44dp');
      }
    });
  });
}