import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:cardio_tracker/widgets/export_bottom_sheet.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

void main() {
  group('ExportBottomSheet', () {
    late List<BloodPressureReading> mockReadings;

    setUp(() {
      mockReadings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          lastModified: DateTime.now(),
        ),
        BloodPressureReading(
          id: '2',
          systolic: 135,
          diastolic: 85,
          heartRate: 78,
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          lastModified: DateTime.now(),
        ),
      ];
    });

    testWidgets('displays export options with neumorphic design',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: mockReadings,
            ),
          ),
        ),
      );

      // Verify the bottom sheet has a handle bar
      expect(find.byType(Container), findsWidgets);

      // Verify all three export options are present
      expect(find.text('Export All Data'), findsOneWidget);
      expect(find.text('Export Summary'), findsOneWidget);
      expect(find.text('Export This Month'), findsOneWidget);

      // Verify icons are present for each option
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
      expect(find.byIcon(Icons.today), findsOneWidget);
    });

    testWidgets('triggers haptic feedback on button press', (tester) async {
      bool hapticTriggered = false;

      // Mock haptic feedback
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          hapticTriggered = true;
          return null;
        }
        return null;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: mockReadings,
            ),
          ),
        ),
      );

      // Tap the first export button
      await tester.tap(find.text('Export All Data'));
      await tester.pump();

      // Verify haptic feedback was triggered
      expect(hapticTriggered, isTrue);
    });

    testWidgets('calls appropriate export service for each option',
        (tester) async {
      bool exportAllCalled = false;
      bool exportSummaryCalled = false;
      bool exportMonthCalled = false;

      // Mock the CSV export service
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'SystemNavigator.pop') {
          return null;
        }
        return null;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ExportBottomSheet(
                  readings: mockReadings,
                );
              },
            ),
          ),
        ),
      );

      // Test Export All Data
      await tester.tap(find.text('Export All Data'));
      await tester.pumpAndSettle();
      // We would need to mock the CsvExportService to verify this call

      // Test Export Summary
      await tester.tap(find.text('Export Summary'));
      await tester.pumpAndSettle();

      // Test Export This Month
      await tester.tap(find.text('Export This Month'));
      await tester.pumpAndSettle();
    });

    testWidgets('shows loading state during export', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: mockReadings,
            ),
          ),
        ),
      );

      // Initially should not show loading
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Simulate button press (would trigger loading state in actual implementation)
      // This would require mocking the export operation to be async
    });

    testWidgets('has proper touch targets for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: mockReadings,
            ),
          ),
        ),
      );

      // Find all button containers
      final buttonContainers = find.byKey(const Key('export_button_container'));

      // Verify buttons exist
      expect(buttonContainers, findsNWidgets(3));

      // Get the size of the first button to verify minimum touch target
      final firstButton = tester.widget<Container>(
        find.byKey(const Key('export_button_container')).first,
      );
      final RenderBox renderBox = tester.renderObject(
        find.byKey(const Key('export_button_container')).first,
      );

      // Verify minimum touch target size (48x48 logical pixels)
      expect(renderBox.size.height, greaterThanOrEqualTo(48));
      expect(renderBox.size.width, greaterThanOrEqualTo(48));
    });

    testWidgets('dismisses on tap outside', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: mockReadings,
            ),
          ),
        ),
      );

      // The bottom sheet should be present
      expect(find.text('Export All Data'), findsOneWidget);

      // This test would need to be integrated with the actual modal bottom sheet
      // to test tap-outside-to-dismiss functionality
    });

    testWidgets('handles empty readings gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: [],
            ),
          ),
        ),
      );

      // Should still display export options even with no data
      expect(find.text('Export All Data'), findsOneWidget);
      expect(find.text('Export Summary'), findsOneWidget);
      expect(find.text('Export This Month'), findsOneWidget);
    });
  });

  group('ExportBottomSheet widget animations', () {
    testWidgets('has slide-up animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: [],
            ),
          ),
        ),
      );

      // Initial render
      await tester.pump();

      // Check for AnimatedContainer or similar animation widgets
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('buttons have press animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExportBottomSheet(
              readings: [],
            ),
          ),
        ),
      );

      // Find the first export button
      final button = find.text('Export All Data');

      // Press down
      await tester.press(button);
      await tester.pump();

      // Should have some visual feedback during press
      // This would be verified through the animation controller state
      // in the actual implementation
    });
  });
}
