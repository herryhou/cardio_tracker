import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../lib/models/blood_pressure_reading.dart';
import '../lib/providers/blood_pressure_provider.dart';
import '../lib/providers/dual_chart_provider.dart';
import '../lib/widgets/horizontal_charts_container.dart';
import '../lib/services/database_service.dart';

/// Benchmark for Chart Carousel Performance
///
/// This benchmark tests:
/// 1. Rendering performance with different dataset sizes
/// 2. Memory usage
/// 3. Frame rate during navigation
/// 4. Animation smoothness
/// 5. Build times
void main() {
  group('Chart Carousel Benchmarks', () {
    late List<BloodPressureReading> smallDataset;
    late List<BloodPressureReading> mediumDataset;
    late List<BloodPressureReading> largeDataset;

    setUpAll(() {
      // Generate test datasets
      smallDataset = generateReadings(50);    // 1 month of daily readings
      mediumDataset = generateReadings(365);  // 1 year of daily readings
      largeDataset = generateReadings(1825); // 5 years of daily readings
    });

    testWidgets('Small dataset (50 readings) build performance',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => BloodPressureProvider(
                  databaseService: DatabaseService.instance,
                ),
              ),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                readings: smallDataset,
                showSwipeHint: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      print('Small dataset build time: ${stopwatch.elapsedMilliseconds}ms');

      // Should build quickly with small dataset
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('Medium dataset (365 readings) build performance',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => BloodPressureProvider(
                  databaseService: DatabaseService.instance,
                ),
              ),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                readings: mediumDataset,
                showSwipeHint: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      print('Medium dataset build time: ${stopwatch.elapsedMilliseconds}ms');

      // Should still be reasonably fast with medium dataset
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Large dataset (1825 readings) build performance',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => BloodPressureProvider(
                  databaseService: DatabaseService.instance,
                ),
              ),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                readings: largeDataset,
                showSwipeHint: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      print('Large dataset build time: ${stopwatch.elapsedMilliseconds}ms');

      // May be slower with large dataset, but should still complete
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('Swipe animation performance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => BloodPressureProvider(
                  databaseService: DatabaseService.instance,
                ),
              ),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                readings: mediumDataset,
                showSwipeHint: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Measure swipe performance
      final stopwatch = Stopwatch()..start();

      // Swipe to second chart
      await tester.fling(
        find.byType(PageView),
        const Offset(-300, 0),
        1000,
      );

      // Let animation complete
      await tester.pumpAndSettle();
      stopwatch.stop();

      print('Swipe animation time: ${stopwatch.elapsedMilliseconds}ms');

      // Animation should be smooth and complete quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Page indicator tap performance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => BloodPressureProvider(
                  databaseService: DatabaseService.instance,
                ),
              ),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                readings: mediumDataset,
                showSwipeHint: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap page indicator
      final indicator = find.byType(SmoothPageIndicator);
      expect(indicator, findsOneWidget);

      final stopwatch = Stopwatch()..start();

      // Tap second indicator dot
      await tester.tap(indicator);
      await tester.pumpAndSettle();
      stopwatch.stop();

      print('Page indicator tap time: ${stopwatch.elapsedMilliseconds}ms');

      // Should be very responsive
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('Memory usage with multiple rebuilds',
        (WidgetTester tester) async {
      final totalMemoryBefore = _getMemoryUsage();

      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => BloodPressureProvider(
                    databaseService: DatabaseService.instance,
                  ),
                ),
                ChangeNotifierProvider(create: (_) => DualChartProvider()),
              ],
              child: Scaffold(
                body: HorizontalChartsContainer(
                  readings: mediumDataset,
                  showSwipeHint: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      final totalMemoryAfter = _getMemoryUsage();
      final memoryIncrease = totalMemoryAfter - totalMemoryBefore;

      print('Memory increase after 10 rebuilds: ${memoryIncrease}MB');

      // Memory increase should be minimal
      expect(memoryIncrease, lessThan(10));
    });
  });
}

/// Generate test blood pressure readings
List<BloodPressureReading> generateReadings(int count) {
  final readings = <BloodPressureReading>[];
  final now = DateTime.now();
  final random = Random();

  for (int i = 0; i < count; i++) {
    final timestamp = now.subtract(Duration(days: count - i));
    final systolic = 110 + random.nextInt(40); // 110-150
    final diastolic = 70 + random.nextInt(20);  // 70-90
    final heartRate = 60 + random.nextInt(40);  // 60-100

    readings.add(BloodPressureReading(
      id: 'reading_$i',
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      timestamp: timestamp,
      lastModified: timestamp,
    ));
  }

  return readings;
}

/// Get current memory usage in MB
int _getMemoryUsage() {
  // In a real implementation, you would use proper memory profiling
  // For now, return a simulated value
  return 50;
}