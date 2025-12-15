import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/presentation/providers/blood_pressure_provider.dart';
import 'package:cardio_tracker/presentation/providers/dual_chart_provider.dart';
import 'package:cardio_tracker/application/use_cases/get_all_readings.dart';
import 'package:cardio_tracker/application/use_cases/add_reading.dart';
import 'package:cardio_tracker/application/use_cases/update_reading.dart';
import 'package:cardio_tracker/application/use_cases/delete_reading.dart';
import 'package:cardio_tracker/application/use_cases/get_reading_statistics.dart';
import 'package:cardio_tracker/application/use_cases/clear_all_readings.dart';
import 'package:cardio_tracker/application/use_cases/rebuild_database.dart';
import 'package:cardio_tracker/domain/value_objects/reading_statistics.dart';
import 'package:cardio_tracker/widgets/horizontal_charts_container.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'horizontal_charts_container_test.mocks.dart';

@GenerateMocks([
  GetAllReadings,
  AddReading,
  UpdateReading,
  DeleteReading,
  GetReadingStatistics,
  ClearAllReadings,
  RebuildDatabase
])
void main() {
  group('HorizontalChartsContainer', () {
    late MockGetAllReadings mockGetAllReadings;
    late MockAddReading mockAddReading;
    late MockUpdateReading mockUpdateReading;
    late MockDeleteReading mockDeleteReading;
    late MockGetReadingStatistics mockGetReadingStatistics;
    late MockClearAllReadings mockClearAllReadings;
    late MockRebuildDatabase mockRebuildDatabase;

    setUp(() {
      mockGetAllReadings = MockGetAllReadings();
      mockAddReading = MockAddReading();
      mockUpdateReading = MockUpdateReading();
      mockDeleteReading = MockDeleteReading();
      mockGetReadingStatistics = MockGetReadingStatistics();
      mockClearAllReadings = MockClearAllReadings();
      mockRebuildDatabase = MockRebuildDatabase();

      // Setup default behavior for mocks to return empty data
      when(mockGetAllReadings(any)).thenAnswer((_) async => const Right([]));
      when(mockGetReadingStatistics(any))
          .thenAnswer((_) async => const Right(ReadingStatistics(
                averageSystolic: 0,
                averageDiastolic: 0,
                averageHeartRate: 0,
                totalReadings: 0,
                categoryDistribution: {},
              )));
      when(mockClearAllReadings(any))
          .thenAnswer((_) async => const Right(null));
      when(mockRebuildDatabase(any)).thenAnswer((_) async => const Right(null));
    });

    testWidgets('should show page indicator dots for two charts',
        (WidgetTester tester) async {
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
              ChangeNotifierProvider(
                  create: (_) => BloodPressureProvider(
                        getAllReadings: mockGetAllReadings,
                        addReading: mockAddReading,
                        updateReading: mockUpdateReading,
                        deleteReading: mockDeleteReading,
                        getReadingStatistics: mockGetReadingStatistics,
                        clearAllReadings: mockClearAllReadings,
                        rebuildDatabase: mockRebuildDatabase,
                      )),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                  readings: readings, showSwipeHint: false),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SmoothPageIndicator), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
      expect(find.text('Distribution'), findsOneWidget);
    });

    testWidgets('should show swipe hint when first visiting',
        (WidgetTester tester) async {
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
              ChangeNotifierProvider(
                  create: (_) => BloodPressureProvider(
                        getAllReadings: mockGetAllReadings,
                        addReading: mockAddReading,
                        updateReading: mockUpdateReading,
                        deleteReading: mockDeleteReading,
                        getReadingStatistics: mockGetReadingStatistics,
                        clearAllReadings: mockClearAllReadings,
                        rebuildDatabase: mockRebuildDatabase,
                      )),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                  readings: readings, showSwipeHint: true),
            ),
          ),
        ),
      );

      // Find swipe hint
      expect(find.text('Swipe to see more charts'), findsOneWidget);
      expect(find.byIcon(Icons.swipe), findsOneWidget);
    });

    testWidgets('should show correct page indicator',
        (WidgetTester tester) async {
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
              ChangeNotifierProvider(
                  create: (_) => BloodPressureProvider(
                        getAllReadings: mockGetAllReadings,
                        addReading: mockAddReading,
                        updateReading: mockUpdateReading,
                        deleteReading: mockDeleteReading,
                        getReadingStatistics: mockGetReadingStatistics,
                        clearAllReadings: mockClearAllReadings,
                        rebuildDatabase: mockRebuildDatabase,
                      )),
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: Scaffold(
              body: HorizontalChartsContainer(
                  readings: readings, showSwipeHint: false),
            ),
          ),
        ),
      );

      // Find page indicator
      expect(find.byType(SmoothPageIndicator), findsOneWidget);
    });
  });
}
