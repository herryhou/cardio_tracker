import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/application/use_cases/get_reading_statistics.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'get_reading_statistics_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('GetReadingStatistics', () {
    late MockBloodPressureRepository mockRepository;
    late GetReadingStatistics useCase;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
      useCase = GetReadingStatistics(mockRepository);
    });

    test('should calculate statistics correctly for multiple readings',
        () async {
      // Arrange
      final now = DateTime.now();
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now.subtract(const Duration(days: 2)),
          lastModified: now.subtract(const Duration(days: 2)),
        ),
        BloodPressureReading(
          id: '2',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: now.subtract(const Duration(days: 1)),
          lastModified: now.subtract(const Duration(days: 1)),
        ),
        BloodPressureReading(
          id: '3',
          systolic: 125,
          diastolic: 82,
          heartRate: 74,
          timestamp: now,
          lastModified: now,
        ),
      ];

      when(mockRepository.getReadingsByDateRange(any, any))
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await useCase(const StatisticsParams(days: 30));

      // Assert
      expect(result, isA<Right>());
      final stats = result.fold((l) => null, (r) => r)!;
      expect(stats.averageSystolic, closeTo(125, 0.1));
      expect(stats.averageDiastolic, closeTo(82.33, 0.1));
      expect(stats.averageHeartRate, closeTo(73.67, 0.1));
      expect(stats.totalReadings, 3);
      expect(stats.hasData, isTrue);
      expect(stats.latestReadingDate, now);
      expect(stats.categoryDistribution, isA<Map<String, int>>());
      verify(mockRepository.getReadingsByDateRange(any, any));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty statistics when no readings exist', () async {
      // Arrange
      when(mockRepository.getReadingsByDateRange(any, any))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(const StatisticsParams(days: 30));

      // Assert
      expect(result, isA<Right>());
      final stats = result.fold((l) => null, (r) => r)!;
      expect(stats.averageSystolic, 0);
      expect(stats.averageDiastolic, 0);
      expect(stats.averageHeartRate, 0);
      expect(stats.totalReadings, 0);
      expect(stats.hasData, isFalse);
      expect(stats.categoryDistribution, isEmpty);
      expect(stats.latestReadingDate, isNull);
      verify(mockRepository.getReadingsByDateRange(any, any));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Database error');
      when(mockRepository.getReadingsByDateRange(any, any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const StatisticsParams(days: 30));

      // Assert
      expect(result, isA<Left>());
      expect(result.fold((l) => l, (r) => r), equals(failure));
      verify(mockRepository.getReadingsByDateRange(any, any));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should calculate date range correctly based on days parameter',
        () async {
      // Arrange
      final now = DateTime.now();
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now.subtract(const Duration(days: 7)),
          lastModified: now.subtract(const Duration(days: 7)),
        ),
      ];

      when(mockRepository.getReadingsByDateRange(any, any))
          .thenAnswer((_) async => Right(readings));

      // Act
      await useCase(const StatisticsParams(days: 7));

      // Assert
      final captured =
          verify(mockRepository.getReadingsByDateRange(captureAny, captureAny))
              .captured;
      final startDate = captured[0] as DateTime;
      final endDate = captured[1] as DateTime;

      expect(endDate.difference(now).inSeconds,
          lessThan(5)); // Within 5 seconds of now
      expect(endDate.difference(startDate).inDays, 7);
    });

    test('should include category distribution in statistics', () async {
      // Arrange
      final now = DateTime.now();
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 118,
          diastolic: 78,
          heartRate: 72,
          timestamp: now,
          lastModified: now,
        ),
        BloodPressureReading(
          id: '2',
          systolic: 135,
          diastolic: 88,
          heartRate: 75,
          timestamp: now,
          lastModified: now,
        ),
        BloodPressureReading(
          id: '3',
          systolic: 118,
          diastolic: 78,
          heartRate: 74,
          timestamp: now,
          lastModified: now,
        ),
      ];

      when(mockRepository.getReadingsByDateRange(any, any))
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await useCase(const StatisticsParams(days: 30));

      // Assert
      expect(result, isA<Right>());
      final stats = result.fold((l) => null, (r) => r)!;
      expect(stats.categoryDistribution, isNotEmpty);
      expect(stats.categoryDistribution['Normal'], 2);
      expect(stats.categoryDistribution['Stage 1'], 1);
    });
  });
}
