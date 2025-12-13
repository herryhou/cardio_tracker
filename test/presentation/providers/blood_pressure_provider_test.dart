import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/presentation/providers/blood_pressure_provider.dart';
import 'package:cardio_tracker/application/use_cases/get_all_readings.dart';
import 'package:cardio_tracker/application/use_cases/add_reading.dart';
import 'package:cardio_tracker/application/use_cases/update_reading.dart';
import 'package:cardio_tracker/application/use_cases/delete_reading.dart';
import 'package:cardio_tracker/application/use_cases/get_reading_statistics.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/value_objects/reading_statistics.dart';
import 'package:cardio_tracker/core/errors/failures.dart';
import 'package:cardio_tracker/core/usecases/usecase.dart';

import 'blood_pressure_provider_test.mocks.dart';

@GenerateMocks([GetAllReadings, AddReading, UpdateReading, DeleteReading, GetReadingStatistics])
void main() {
  group('BloodPressureProvider', () {
    late MockGetAllReadings mockGetAllReadings;
    late MockAddReading mockAddReading;
    late MockUpdateReading mockUpdateReading;
    late MockDeleteReading mockDeleteReading;
    late MockGetReadingStatistics mockGetStatistics;
    late BloodPressureProvider provider;

    setUp(() {
      mockGetAllReadings = MockGetAllReadings();
      mockAddReading = MockAddReading();
      mockUpdateReading = MockUpdateReading();
      mockDeleteReading = MockDeleteReading();
      mockGetStatistics = MockGetReadingStatistics();

      // Provide default behavior for getStatistics
      when(mockGetStatistics(any))
          .thenAnswer((_) async => Right(const ReadingStatistics(
            averageSystolic: 0,
            averageDiastolic: 0,
            averageHeartRate: 0,
            totalReadings: 0,
            categoryDistribution: {},
          )));

      provider = BloodPressureProvider(
        getAllReadings: mockGetAllReadings,
        addReading: mockAddReading,
        updateReading: mockUpdateReading,
        deleteReading: mockDeleteReading,
        getReadingStatistics: mockGetStatistics,
      );
    });

    test('should load readings successfully', () async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        )
      ];

      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right(readings));
      when(mockGetStatistics(any))
          .thenAnswer((_) async => Right(const ReadingStatistics(
            averageSystolic: 120,
            averageDiastolic: 80,
            averageHeartRate: 72,
            totalReadings: 1,
            categoryDistribution: {'Normal': 1},
          )));

      // Act
      await provider.loadReadings();

      // Wait for async statistics computation
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.readings.length, 1);
      expect(provider.readings.first.systolic, 120);
    });

    test('should handle error when loading readings fails', () async {
      // Arrange
      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Left(DatabaseFailure('Failed to load')));

      // Act
      await provider.loadReadings();

      // Assert
      expect(provider.isLoading, false);
      expect(provider.error, 'Failed to load');
      expect(provider.readings.isEmpty, true);
    });

    test('should add reading successfully', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockAddReading(reading))
          .thenAnswer((_) async => Right(null));
      when(mockGetStatistics(any))
          .thenAnswer((_) async => Right(const ReadingStatistics(
            averageSystolic: 120,
            averageDiastolic: 80,
            averageHeartRate: 72,
            totalReadings: 1,
            categoryDistribution: {'Normal': 1},
          )));

      // Act
      final result = await provider.addReading(reading);

      // Wait for async statistics computation
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(result, true);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.readings.length, 1);
      expect(provider.readings.first.systolic, 120);
    });

    test('should handle error when adding reading fails', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockAddReading(reading))
          .thenAnswer((_) async => Left(ValidationFailure('Invalid reading')));

      // Act
      final result = await provider.addReading(reading);

      // Assert
      expect(result, false);
      expect(provider.isLoading, false);
      expect(provider.error, 'Invalid reading');
      expect(provider.readings.isEmpty, true);
    });

    test('should compute correct statistics', () async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        ),
        BloodPressureReading(
          id: '2',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        ),
      ];

      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right(readings));
      when(mockGetStatistics(any))
          .thenAnswer((_) async => Right(const ReadingStatistics(
            averageSystolic: 125,
            averageDiastolic: 82.5,
            averageHeartRate: 73.5,
            totalReadings: 2,
            categoryDistribution: {'Normal': 2},
          )));

      // Act
      await provider.loadReadings();

      // Wait for async statistics computation
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(provider.averageSystolic, closeTo(125, 0.1));
      expect(provider.averageDiastolic, closeTo(82.5, 0.1));
      expect(provider.averageHeartRate, closeTo(73.5, 0.1));
    });

    test('should return latest reading correctly', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: yesterday,
          lastModified: yesterday,
        ),
        BloodPressureReading(
          id: '2',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: now,
          lastModified: now,
        ),
      ];

      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right(readings));

      // Act
      await provider.loadReadings();

      // Assert
      expect(provider.latestReading?.id, '2');
      expect(provider.latestReading?.systolic, 130);
    });

    test('should return empty list for recent readings when no readings exist', () async {
      // Arrange
      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right([]));
      when(mockGetStatistics(any))
          .thenAnswer((_) async => Right(const ReadingStatistics(
            averageSystolic: 0,
            averageDiastolic: 0,
            averageHeartRate: 0,
            totalReadings: 0,
            categoryDistribution: {},
          )));

      // Act
      await provider.loadReadings();

      // Assert
      expect(provider.recentReadings.isEmpty, true);
    });

    test('should update reading successfully', () async {
      // Arrange
      final originalReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      final updatedReading = BloodPressureReading(
        id: '1',
        systolic: 125,
        diastolic: 85,
        heartRate: 75,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Load initial reading
      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right([originalReading]));
      await provider.loadReadings();

      when(mockUpdateReading(updatedReading))
          .thenAnswer((_) async => Right(null));
      when(mockGetStatistics(any))
          .thenAnswer((_) async => Right(const ReadingStatistics(
            averageSystolic: 125,
            averageDiastolic: 85,
            averageHeartRate: 75,
            totalReadings: 1,
            categoryDistribution: {'Normal': 1},
          )));

      // Act
      final result = await provider.updateReading(updatedReading);

      // Wait for async statistics computation
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(result, true);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.readings.length, 1);
      expect(provider.readings.first.systolic, 125);
    });

    test('should handle error when updating reading fails', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockUpdateReading(reading))
          .thenAnswer((_) async => Left(ValidationFailure('Invalid reading')));

      // Act
      final result = await provider.updateReading(reading);

      // Assert
      expect(result, false);
      expect(provider.isLoading, false);
      expect(provider.error, 'Invalid reading');
    });

    test('should delete reading successfully', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Load initial reading
      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right([reading]));
      await provider.loadReadings();

      when(mockDeleteReading(any))
          .thenAnswer((_) async => Right(null));
      when(mockGetStatistics(any))
          .thenAnswer((_) async => Right(const ReadingStatistics(
            averageSystolic: 0,
            averageDiastolic: 0,
            averageHeartRate: 0,
            totalReadings: 0,
            categoryDistribution: {},
          )));

      // Act
      final result = await provider.deleteReading('1');

      // Wait for async statistics computation
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(result, true);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.readings.isEmpty, true);
    });

    test('should handle error when deleting reading fails', () async {
      // Arrange
      when(mockDeleteReading(any))
          .thenAnswer((_) async => Left(DatabaseFailure('Failed to delete')));

      // Act
      final result = await provider.deleteReading('1');

      // Assert
      expect(result, false);
      expect(provider.isLoading, false);
      expect(provider.error, 'Failed to delete');
    });

    test('should filter readings by date range correctly', () async {
      // Arrange
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      final lastMonth = now.subtract(const Duration(days: 30));

      final readings = [
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
          timestamp: lastWeek,
          lastModified: lastWeek,
        ),
        BloodPressureReading(
          id: '3',
          systolic: 110,
          diastolic: 70,
          heartRate: 68,
          timestamp: lastMonth,
          lastModified: lastMonth,
        ),
      ];

      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right(readings));

      // Act
      await provider.loadReadings();
      final filteredReadings = provider.getReadingsByDateRange(
        now.subtract(const Duration(days: 15)),
        now,
      );

      // Assert
      expect(filteredReadings.length, 2);
      expect(filteredReadings.any((r) => r.id == '1'), true);
      expect(filteredReadings.any((r) => r.id == '2'), true);
      expect(filteredReadings.any((r) => r.id == '3'), false);
    });

    test('should clear error correctly', () async {
      // Arrange
      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Left(DatabaseFailure('Error occurred')));

      await provider.loadReadings();
      expect(provider.error, 'Error occurred');

      // Act
      provider.clearError();

      // Assert
      expect(provider.error, null);
    });
  });
}