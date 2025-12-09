import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/screens/dashboard_screen.dart';
import 'package:cardio_tracker/widgets/reading_summary_card.dart';
import 'package:cardio_tracker/widgets/clinical_scatter_plot.dart';
import 'package:cardio_tracker/widgets/fl_time_series_chart.dart';
import 'package:cardio_tracker/screens/add_reading_screen.dart';
import 'package:cardio_tracker/main.dart' as app;

void main() {
  group('Touch Targets Compliance Test', () {
    testWidgets('All interactive elements meet minimum touch target requirements', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Test dashboard screen elements
      await _verifyDashboardTouchTargets(tester);

      // Navigate to add reading screen
      final addReadingFab = find.byType(FloatingActionButton);
      expect(addReadingFab, findsOneWidget);
      await tester.tap(addReadingFab);
      await tester.pumpAndSettle();

      // Test add reading screen elements
      await _verifyAddReadingScreenTouchTargets(tester);

      // Go back to dashboard
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test chart touch areas
      await _verifyChartTouchTargets(tester);
    });
  });
}

Future<void> _verifyDashboardTouchTargets(WidgetTester tester) async {
  // FAB button should be 56dp minimum
  final fab = find.byType(FloatingActionButton);
  expect(fab, findsOneWidget);

  final RenderBox fabRenderBox = tester.renderObject(fab);
  final Size fabSize = fabRenderBox.size;
  expect(fabSize.width, greaterThanOrEqualTo(56.0));
  expect(fabSize.height, greaterThanOrEqualTo(56.0));

  // Menu buttons (typically in AppBar or as overflow buttons)
  final menuButtons = find.byType(PopupMenuButton<String>);
  if (menuButtons.evaluate().isNotEmpty) {
    for (final button in menuButtons.evaluate()) {
      final RenderBox buttonRenderBox = tester.renderObject(button);
      final Size buttonSize = buttonRenderBox.size;
      expect(buttonSize.width, greaterThanOrEqualTo(44.0),
          reason: 'Menu button width should be at least 44dp');
      expect(buttonSize.height, greaterThanOrEqualTo(44.0),
          reason: 'Menu button height should be at least 44dp');
    }
  }

  // Check for IconButton widgets
  final iconButtons = find.byType(IconButton);
  for (final button in iconButtons.evaluate()) {
    final RenderBox buttonRenderBox = tester.renderObject(button);
    final Size buttonSize = buttonRenderBox.size;
    expect(buttonSize.width, greaterThanOrEqualTo(44.0),
        reason: 'IconButton width should be at least 44dp');
    expect(buttonSize.height, greaterThanOrEqualTo(44.0),
        reason: 'IconButton height should be at least 44dp');
  }

  // Check for ElevatedButton widgets
  final elevatedButtons = find.byType(ElevatedButton);
  for (final button in elevatedButtons.evaluate()) {
    final RenderBox buttonRenderBox = tester.renderObject(button);
    final Size buttonSize = buttonRenderBox.size;
    expect(buttonSize.height, greaterThanOrEqualTo(44.0),
        reason: 'ElevatedButton height should be at least 44dp');
  }

  // Check for TextButton widgets
  final textButtons = find.byType(TextButton);
  for (final button in textButtons.evaluate()) {
    final RenderBox buttonRenderBox = tester.renderObject(button);
    final Size buttonSize = buttonRenderBox.size;
    expect(buttonSize.height, greaterThanOrEqualTo(44.0),
        reason: 'TextButton height should be at least 44dp');
  }
}

Future<void> _verifyAddReadingScreenTouchTargets(WidgetTester tester) async {
  // Text form fields should have adequate touch targets
  final textFields = find.byType(TextField);
  for (final field in textFields.evaluate()) {
    final RenderBox fieldRenderBox = tester.renderObject(field);
    final Size fieldSize = fieldRenderBox.size;
    expect(fieldSize.height, greaterThanOrEqualTo(44.0),
        reason: 'TextField height should be at least 44dp');
  }

  // Save/Add buttons
  final saveButtons = find.byType(ElevatedButton);
  for (final button in saveButtons.evaluate()) {
    final RenderBox buttonRenderBox = tester.renderObject(button);
    final Size buttonSize = buttonRenderBox.size;
    expect(buttonSize.height, greaterThanOrEqualTo(44.0),
        reason: 'Save button height should be at least 44dp');
  }

  // Dropdown buttons
  final dropdownButtons = find.byType(DropdownButtonFormField);
  for (final button in dropdownButtons.evaluate()) {
    final RenderBox buttonRenderBox = tester.renderObject(button);
    final Size buttonSize = buttonRenderBox.size;
    expect(buttonSize.height, greaterThanOrEqualTo(44.0),
        reason: 'DropdownButton height should be at least 44dp');
  }
}

Future<void> _verifyChartTouchTargets(WidgetTester tester) async {
  // Charts should have touchable areas of at least 44dp
  // This is harder to test directly, but we can check for GestureDetector
  // or InkWell widgets within chart widgets

  // Find chart containers
  final chartContainers = find.byKey(const Key('chart_container'));
  if (chartContainers.evaluate().isNotEmpty) {
    for (final container in chartContainers.evaluate()) {
      final RenderBox containerRenderBox = tester.renderObject(container);
      final Size containerSize = containerRenderBox.size;

      // Charts should be large enough to contain 44dp touch targets
      expect(containerSize.width, greaterThanOrEqualTo(44.0),
          reason: 'Chart container width should support 44dp touch targets');
      expect(containerSize.height, greaterThanOrEqualTo(44.0),
          reason: 'Chart container height should support 44dp touch targets');
    }
  }
}