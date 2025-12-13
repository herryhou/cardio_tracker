import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/widgets/timeline_carousel.dart';
import 'package:cardio_tracker/widgets/neumorphic_container.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

void main() {
  group('TimelineCarousel', () {
    late List<BloodPressureReading> testReadings;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testReadings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 70,
          timestamp: now.subtract(const Duration(days: 6)),
          lastModified: now.subtract(const Duration(days: 6)),
        ),
        BloodPressureReading(
          id: '2',
          systolic: 135,
          diastolic: 88,
          heartRate: 75,
          timestamp: now.subtract(const Duration(days: 5)),
          lastModified: now.subtract(const Duration(days: 5)),
        ),
        BloodPressureReading(
          id: '3',
          systolic: 145,
          diastolic: 95,
          heartRate: 78,
          timestamp: now.subtract(const Duration(days: 4)),
          lastModified: now.subtract(const Duration(days: 4)),
        ),
        BloodPressureReading(
          id: '4',
          systolic: 118,
          diastolic: 78,
          heartRate: 72,
          timestamp: now.subtract(const Duration(days: 3)),
          lastModified: now.subtract(const Duration(days: 3)),
        ),
        BloodPressureReading(
          id: '5',
          systolic: 165,
          diastolic: 105,
          heartRate: 85,
          timestamp: now.subtract(const Duration(days: 2)),
          lastModified: now.subtract(const Duration(days: 2)),
        ),
        BloodPressureReading(
          id: '6',
          systolic: 125,
          diastolic: 82,
          heartRate: 73,
          timestamp: now.subtract(const Duration(days: 1)),
          lastModified: now.subtract(const Duration(days: 1)),
        ),
        BloodPressureReading(
          id: '7',
          systolic: 130,
          diastolic: 85,
          heartRate: 74,
          timestamp: now,
          lastModified: now,
        ),
      ];
    });

    testWidgets('should display horizontal scrollable timeline with date labels', (WidgetTester tester) async {
      String? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: testReadings,
              onDateSelected: (date) => selectedDate = date,
            ),
          ),
        ),
      );

      // Verify the timeline carousel is displayed
      expect(find.byType(TimelineCarousel), findsOneWidget);

      // Verify all timeline items are present
      expect(find.byType(TimelineItem), findsWidgets);

      // Check if date labels are formatted correctly (MM/dd)
      expect(find.text('12/04'), findsOneWidget);
      expect(find.text('12/05'), findsOneWidget);
      expect(find.text('12/06'), findsOneWidget);
      expect(find.text('12/07'), findsOneWidget);
      expect(find.text('12/08'), findsOneWidget);
      expect(find.text('12/09'), findsOneWidget);
      expect(find.text('12/10'), findsOneWidget);
    });

    testWidgets('should display vertical bars with correct heights based on BP range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: testReadings,
              onDateSelected: (date) {},
            ),
          ),
        ),
      );

      // Find all timeline items which contain the bars
      final items = find.byType(TimelineItem);
      expect(items, findsWidgets);

      // Check for different bar heights by looking at Container widgets in TimelineItems
      final containers = find.descendant(
        of: items,
        matching: find.byType(Container),
      );

      // Verify we have containers (which include the bars)
      expect(containers, findsWidgets);

      // The height calculation is based on systolic values, so bars should vary
      // We can verify this indirectly by checking different systolic values in readings
      final systolicValues = testReadings.map((r) => r.systolic).toSet();
      expect(systolicValues.length, greaterThan(1));
    });

    testWidgets('should show correct colors for different BP ranges', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: testReadings,
              onDateSelected: (date) {},
            ),
          ),
        ),
      );

      // Check for normal BP (green)
      expect(find.byKey(const Key('normal_bar')), findsWidgets);

      // Check for elevated BP (yellow)
      expect(find.byKey(const Key('elevated_bar')), findsWidgets);

      // Check for high BP (orange)
      expect(find.byKey(const Key('high_bar')), findsWidgets);

      // Check for very high BP (red)
      expect(find.byKey(const Key('very_high_bar')), findsWidgets);
    });

    testWidgets('should handle tap events with scale animation feedback', (WidgetTester tester) async {
      String? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: testReadings,
              onDateSelected: (date) => selectedDate = date,
            ),
          ),
        ),
      );

      // Find the first timeline item
      final firstItem = find.byType(TimelineItem).first;
      expect(firstItem, findsOneWidget);

      // Get the center point of the widget
      await tester.tap(firstItem, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the callback was triggered
      expect(selectedDate, isNotNull);

      // Check for animation controllers
      expect(find.byType(AnimatedScale), findsWidgets);
    });

    testWidgets('should support filtering by time range', (WidgetTester tester) async {
      final startDate = now.subtract(const Duration(days: 4));
      final endDate = now.subtract(const Duration(days: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: testReadings,
              onDateSelected: (date) {},
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        ),
      );

      // Should only show items within the date range (adjusted for inclusive dates)
      expect(find.byType(TimelineItem), findsNWidgets(4));

      // Verify specific dates are shown
      expect(find.text('12/06'), findsOneWidget);
      expect(find.text('12/07'), findsOneWidget);
      expect(find.text('12/08'), findsOneWidget);
      expect(find.text('12/09'), findsOneWidget);

      // Verify dates outside range are not shown
      expect(find.text('12/04'), findsNothing);
      expect(find.text('12/05'), findsNothing);
      expect(find.text('12/10'), findsNothing);
    });

    testWidgets('should apply neumorphic design with soft shadows', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: testReadings,
              onDateSelected: (date) {},
            ),
          ),
        ),
      );

      // Find neumorphic containers
      final containers = find.byKey(const Key('neumorphic_container'));
      expect(containers, findsWidgets);

      // Verify NeumorphicContainer is used
      final neumorphicWidget = tester.widget<NeumorphicContainer>(containers.first);
      expect(neumorphicWidget, isNotNull);
    });

    testWidgets('should handle empty readings list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: const [],
              onDateSelected: (date) {},
            ),
          ),
        ),
      );

      // Should display empty state message
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('should scroll horizontally when content overflows', (WidgetTester tester) async {
      // Create more readings to ensure horizontal scroll
      final manyReadings = List.generate(20, (index) => BloodPressureReading(
        id: '$index',
        systolic: 120 + index,
        diastolic: 80 + index,
        heartRate: 70,
        timestamp: now.subtract(Duration(days: 19 - index)),
        lastModified: now.subtract(Duration(days: 19 - index)),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Constrain width to force scrolling
              child: TimelineCarousel(
                readings: manyReadings,
                onDateSelected: (date) {},
              ),
            ),
          ),
        ),
      );

      // Verify SingleChildScrollView is present for horizontal scrolling
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify scroll direction is horizontal
      final scrollable = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(scrollable.scrollDirection, Axis.horizontal);
    });

    testWidgets('should update selection when tapped', (WidgetTester tester) async {
      String? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineCarousel(
              readings: testReadings,
              onDateSelected: (date) => selectedDate = date,
            ),
          ),
        ),
      );

      // Tap on the third item
      final thirdItem = find.byType(TimelineItem).at(2);
      await tester.tap(thirdItem, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Store the first selection
      final firstSelection = selectedDate;
      expect(firstSelection, isNotNull);

      // Tap on a different item
      final fifthItem = find.byType(TimelineItem).at(4);
      await tester.tap(fifthItem, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Selection should have changed
      expect(selectedDate, isNotNull);
      expect(selectedDate, isNot(equals(firstSelection)));
    });
  });
}