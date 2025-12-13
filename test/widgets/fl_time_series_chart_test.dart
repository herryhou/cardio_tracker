import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cardio_tracker/widgets/fl_time_series_chart.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/entities/chart_types.dart';

void main() {
  group('FlTimeSeriesChart', () {
    testWidgets('should display line chart with correct colors and styling', (WidgetTester tester) async {
      // Create test data
      final now = DateTime.now();
      final readings = [
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
          systolic: 125,
          diastolic: 82,
          heartRate: 72,
          timestamp: now.subtract(const Duration(days: 5)),
          lastModified: now.subtract(const Duration(days: 5)),
        ),
        BloodPressureReading(
          id: '3',
          systolic: 118,
          diastolic: 78,
          heartRate: 68,
          timestamp: now.subtract(const Duration(days: 4)),
          lastModified: now.subtract(const Duration(days: 4)),
        ),
        BloodPressureReading(
          id: '4',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: now.subtract(const Duration(days: 3)),
          lastModified: now.subtract(const Duration(days: 3)),
        ),
        BloodPressureReading(
          id: '5',
          systolic: 122,
          diastolic: 80,
          heartRate: 71,
          timestamp: now.subtract(const Duration(days: 2)),
          lastModified: now.subtract(const Duration(days: 2)),
        ),
        BloodPressureReading(
          id: '6',
          systolic: 128,
          diastolic: 83,
          heartRate: 73,
          timestamp: now.subtract(const Duration(days: 1)),
          lastModified: now.subtract(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlTimeSeriesChart(
              readings: readings,
              initialTimeRange: ExtendedTimeRange.week,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the chart is displayed
      expect(find.byType(LineChart), findsOneWidget);

      // Find all line chart bars
      final lineChartBars = find.byType(LineChartBarData);

      // Get the LineChart widget to inspect its data
      final lineChartWidget = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChartWidget.data;

      // Verify we have the correct number of lines (systolic, diastolic, and 2 average lines)
      expect(lineChartData.lineBarsData.length, 4);

      // Verify systolic line color is red (first line should be solid, not dotted)
      final systolicLine = lineChartData.lineBarsData[0];
      expect(systolicLine.color, const Color(0xFFFF0000)); // Red
      expect(systolicLine.dashArray, isNull, reason: 'Systolic line should be solid');

      // Verify diastolic line color is blue (second line should be dashed)
      final diastolicLine = lineChartData.lineBarsData[1];
      expect(diastolicLine.color, const Color(0xFF0000FF)); // Blue
      expect(diastolicLine.dashArray, isNotNull, reason: 'Diastolic line should be dashed');

      // Verify average reference lines exist (should be dotted lines without dots)
      final dashedLines = lineChartData.lineBarsData.where((line) =>
        line.dashArray != null && line.dashArray!.isNotEmpty
      ).toList();

      // Should have 3 dashed lines total (diastolic + 2 averages)
      expect(dashedLines.length, 3, reason: 'Should have 3 dashed lines (diastolic + 2 averages)');

      // Find the average lines (those without dots)
      final averageLines = dashedLines.where((line) => line.dotData.show == false).toList();
      expect(averageLines.length, 2, reason: 'Should have 2 average lines without dots');

      // Verify X-axis labels are horizontal (0° rotation)
      // Since we can't directly test rotation, we check that labels exist
      final bottomTitles = lineChartData.titlesData.bottomTitles;
      expect(bottomTitles.sideTitles.showTitles, isTrue);

      // Verify Y-axis values are shown
      final leftTitles = lineChartData.titlesData.leftTitles;
      expect(leftTitles.sideTitles.showTitles, isTrue);
      expect(leftTitles.sideTitles.interval, 20.0); // Should show values at 20 mmHg intervals
    });

    testWidgets('should show every 3rd date on X-axis', (WidgetTester tester) async {
      final now = DateTime.now();
      final readings = List<BloodPressureReading>.generate(10, (index) => BloodPressureReading(
        id: '$index',
        systolic: 120 + index,
        diastolic: 80 + index,
        heartRate: 70,
        timestamp: now.subtract(Duration(days: 9 - index)),
        lastModified: now.subtract(Duration(days: 9 - index)),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlTimeSeriesChart(
              readings: readings,
              initialTimeRange: ExtendedTimeRange.week,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the LineChart widget
      final lineChartWidget = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChartWidget.data;

      // Check X-axis interval
      final bottomTitles = lineChartData.titlesData.bottomTitles;
      expect(bottomTitles.sideTitles.interval, 3.0,
             reason: 'Should show every 3rd date');
    });
  });
}