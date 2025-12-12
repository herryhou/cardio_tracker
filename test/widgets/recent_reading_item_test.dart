import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/widgets/recent_reading_item.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';

void main() {
  group('RecentReadingItem', () {
    testWidgets('displays reading information correctly',
        (WidgetTester tester) async {
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentReadingItem(
              reading: reading,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify date/time is displayed
      expect(find.textContaining('Today'), findsOneWidget);

      // Verify BP values are displayed
      expect(find.text('120/80'), findsOneWidget);

      // Verify pulse is displayed with icon
      expect(find.text('72'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows correct background color based on BP category',
        (WidgetTester tester) async {
      // Test normal BP
      final normalReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentReadingItem(
              reading: normalReading,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find the reading badge container by looking for the BP text
      final bpTextFinder = find.text('120/80');
      expect(bpTextFinder, findsOneWidget);

      // Get the parent container of the BP text (should be the badge)
      final badgeContainer = tester.widget<Container>(
        find
            .ancestor(
              of: bpTextFinder,
              matching: find.byType(Container),
            )
            .first,
      );

      final BoxDecoration decoration =
          badgeContainer.decoration as BoxDecoration;

      // Verify badge has color (non-transparent)
      expect(decoration.color, isNotNull);
      expect(decoration.color!.opacity, greaterThan(0.0));
    });

    testWidgets('handles swipe to delete gesture', (WidgetTester tester) async {
      bool deleteCalled = false;

      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentReadingItem(
              reading: reading,
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // Perform swipe gesture
      await tester.drag(find.byType(RecentReadingItem), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify delete was called
      expect(deleteCalled, true);
    });

    testWidgets('displays formatted date correctly',
        (WidgetTester tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: yesterday,
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentReadingItem(
              reading: reading,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify yesterday is displayed
      expect(find.textContaining('Yesterday'), findsOneWidget);
    });

    testWidgets('has minimum height of 72dp', (WidgetTester tester) async {
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentReadingItem(
              reading: reading,
              onDelete: () {},
            ),
          ),
        ),
      );

      final Size size = tester.getSize(find.byType(RecentReadingItem));
      expect(size.height, greaterThanOrEqualTo(72.0));
    });
  });
}
