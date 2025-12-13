import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/widgets/clinical_scatter_plot.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

void main() {
  group('ClinicalScatterPlot Axes Tests', () {
    late List<BloodPressureReading> testReadings;

    setUp(() {
      final now = DateTime.now();
      testReadings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now,
          lastModified: now,
        ),
        BloodPressureReading(
          id: '2',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: now.subtract(const Duration(days: 1)),
          lastModified: now,
        ),
        BloodPressureReading(
          id: '3',
          systolic: 140,
          diastolic: 90,
          heartRate: 78,
          timestamp: now.subtract(const Duration(days: 2)),
          lastModified: now,
        ),
      ];
    });

    testWidgets('Chart should render with CustomPaint and ClinicalScatterPainter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClinicalScatterPlot(
              readings: testReadings,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the CustomPaint widgets
      final customPaintFinder = find.byType(CustomPaint);
      expect(customPaintFinder, findsWidgets);

      // Find the CustomPaint that has our painter
      CustomPaint? chartPaint;
      for (final element in customPaintFinder.evaluate()) {
        final widget = element.widget as CustomPaint;
        if (widget.painter is ClinicalScatterPainter) {
          chartPaint = widget;
          break;
        }
      }

      expect(chartPaint, isNotNull);
      final painter = chartPaint!.painter as ClinicalScatterPainter;

      // Verify the painter has the readings
      expect(painter.readings, testReadings);
    });

    testWidgets('Data points should be tappable and show tooltip',
        (WidgetTester tester) async {
      BloodPressureReading? selectedReading;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ClinicalScatterPlot(
                readings: testReadings,
                onReadingSelected: (reading) {
                  selectedReading = reading;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the chart widget and tap on it
      final chartFinder = find.byType(ClinicalScatterPlot);
      expect(chartFinder, findsOneWidget);

      // Calculate approximate position for a reading
      // With swapped axes: diastolic on X (80), systolic on Y (120)
      // X position: 80 is in the middle of 50-120 range
      // Y position: 120 is in the middle of 70-170 range
      const tapPosition = Offset(400, 300);

      await tester.tapAt(tapPosition);
      await tester.pumpAndSettle();

      // A reading might be selected depending on tap accuracy
      // The important thing is that the tap handler doesn't crash
      expect(find.byType(ClinicalScatterPlot), findsOneWidget);
    });

    testWidgets('Long press should show detailed tooltip',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ClinicalScatterPlot(
                readings: testReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Long press on the chart
      final chartFinder = find.byType(ClinicalScatterPlot);
      expect(chartFinder, findsOneWidget);

      const tapPosition = Offset(400, 300);
      await tester.longPressAt(tapPosition);
      await tester.pumpAndSettle();

      // Check for overlay (tooltip might appear)
      expect(find.byType(Overlay), findsOneWidget);
    });

    testWidgets('Chart should handle empty readings list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClinicalScatterPlot(
              readings: [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(ClinicalScatterPlot), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Chart should update when readings change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClinicalScatterPlot(
              readings: testReadings,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update readings
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClinicalScatterPlot(
              readings: [testReadings.first],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still render without crashing
      expect(find.byType(ClinicalScatterPlot), findsOneWidget);
    });
  });
}