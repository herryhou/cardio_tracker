import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';
import 'package:cardio_tracker/providers/blood_pressure_provider.dart';
import 'package:cardio_tracker/providers/dual_chart_provider.dart';
import 'package:cardio_tracker/services/database_service.dart';
import 'package:cardio_tracker/widgets/horizontal_charts_container.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  group('HorizontalChartsContainer', () {
    testWidgets('should show page indicator dots for two charts', (WidgetTester tester) async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 70,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => BloodPressureProvider(databaseService: DatabaseService.instance)),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(readings: readings, showSwipeHint: false),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SmoothPageIndicator), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
      expect(find.text('Distribution'), findsOneWidget);
    });

    testWidgets('should show swipe hint when first visiting', (WidgetTester tester) async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 70,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => BloodPressureProvider(databaseService: DatabaseService.instance)),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(readings: readings, showSwipeHint: true),
            ),
          ),
        ),
      );

      // Find swipe hint
      expect(find.text('Swipe to see more charts'), findsOneWidget);
      expect(find.byIcon(Icons.swipe), findsOneWidget);
    });

    testWidgets('should show correct page indicator', (WidgetTester tester) async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 70,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => BloodPressureProvider(databaseService: DatabaseService.instance)),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(readings: readings, showSwipeHint: false),
            ),
          ),
        ),
      );

      // Find page indicator
      expect(find.byType(SmoothPageIndicator), findsOneWidget);
    });
  });
}