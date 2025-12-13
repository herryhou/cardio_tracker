import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/infrastructure/repositories/blood_pressure_repository_impl.dart';
import 'package:cardio_tracker/infrastructure/data_sources/local_database_source.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'blood_pressure_repository_impl_test.mocks.dart';

@GenerateMocks([LocalDatabaseSource])
void main() {
  group('BloodPressureRepositoryImpl', () {
    late MockLocalDatabaseSource mockDataSource;
    late BloodPressureRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockLocalDatabaseSource();
      repository = BloodPressureRepositoryImpl(dataSource: mockDataSource);
    });

    group('getAllReadings', () {
      test('should return list of readings on success', () async {
        // Arrange
        final now = DateTime.now();
        final readingsMap = [
          {
            'id': '1',
            'systolic': 120,
            'diastolic': 80,
            'heartRate': 72,
            'timestamp': now.toIso8601String(),
            'notes': null,
            'lastModified': now.toIso8601String(),
            'isDeleted': 0,
          },
          {
            'id': '2',
            'systolic': 130,
            'diastolic': 85,
            'heartRate': 75,
            'timestamp': now.add(const Duration(days: 1)).toIso8601String(),
            'notes': 'Feeling good',
            'lastModified': now.add(const Duration(days: 1)).toIso8601String(),
            'isDeleted': 0,
          }
        ];

        when(mockDataSource.getAllReadings())
            .thenAnswer((_) async => readingsMap);

        // Act
        final result = await repository.getAllReadings();

        // Assert
        expect(result, isA<Right>());
        final readings = result.fold((l) => null, (r) => r)!;
        expect(readings.length, 2);
        expect(readings[0].systolic, 120);
        expect(readings[0].diastolic, 80);
        expect(readings[0].notes, isNull);
        expect(readings[1].systolic, 130);
        expect(readings[1].diastolic, 85);
        expect(readings[1].notes, 'Feeling good');
        verify(mockDataSource.getAllReadings());
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should return DatabaseFailure when data source throws', () async {
        // Arrange
        when(mockDataSource.getAllReadings())
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getAllReadings();

        // Assert
        expect(result, isA<Left>());
        final failure = result.fold((l) => l, (r) => null)!;
        expect(failure, isA<DatabaseFailure>());
        expect(failure.toString(), contains('Failed to get readings'));
        verify(mockDataSource.getAllReadings());
        verifyNoMoreInteractions(mockDataSource);
      });
    });

    group('addReading', () {
      test('should add reading successfully', () async {
        // Arrange
        final now = DateTime.now();
        final reading = BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now,
          lastModified: now,
        );

        when(mockDataSource.insertReading(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.addReading(reading);

        // Assert
        expect(result, isA<Right>());
        final capturedMap = verify(mockDataSource.insertReading(captureAny)).captured.first as Map<String, dynamic>;
        expect(capturedMap['id'], '1');
        expect(capturedMap['systolic'], 120);
        expect(capturedMap['diastolic'], 80);
        expect(capturedMap['heartRate'], 72);
        expect(capturedMap['timestamp'], now.toIso8601String());
        expect(capturedMap['lastModified'], now.toIso8601String());
        expect(capturedMap['isDeleted'], 0);
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should return DatabaseFailure when insert fails', () async {
        // Arrange
        final reading = BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        );

        when(mockDataSource.insertReading(any))
            .thenThrow(Exception('Insert failed'));

        // Act
        final result = await repository.addReading(reading);

        // Assert
        expect(result, isA<Left>());
        final failure = result.fold((l) => l, (r) => null)!;
        expect(failure, isA<DatabaseFailure>());
        expect(failure.toString(), contains('Failed to add reading'));
        verify(mockDataSource.insertReading(any));
        verifyNoMoreInteractions(mockDataSource);
      });
    });

    group('updateReading', () {
      test('should update reading successfully', () async {
        // Arrange
        final now = DateTime.now();
        final reading = BloodPressureReading(
          id: '1',
          systolic: 125,
          diastolic: 82,
          heartRate: 74,
          timestamp: now.subtract(const Duration(days: 1)),
          lastModified: now,
          notes: 'Updated notes',
        );

        when(mockDataSource.updateReading(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updateReading(reading);

        // Assert
        expect(result, isA<Right>());
        final capturedMap = verify(mockDataSource.updateReading(captureAny)).captured.first as Map<String, dynamic>;
        expect(capturedMap['id'], '1');
        expect(capturedMap['systolic'], 125);
        expect(capturedMap['diastolic'], 82);
        expect(capturedMap['notes'], 'Updated notes');
        expect(capturedMap['lastModified'], now.toIso8601String());
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should return DatabaseFailure when update fails', () async {
        // Arrange
        final reading = BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        );

        when(mockDataSource.updateReading(any))
            .thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateReading(reading);

        // Assert
        expect(result, isA<Left>());
        final failure = result.fold((l) => l, (r) => null)!;
        expect(failure, isA<DatabaseFailure>());
        expect(failure.toString(), contains('Failed to update reading'));
        verify(mockDataSource.updateReading(any));
        verifyNoMoreInteractions(mockDataSource);
      });
    });

    group('deleteReading', () {
      test('should delete reading successfully', () async {
        // Arrange
        when(mockDataSource.deleteReading('1'))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.deleteReading('1');

        // Assert
        expect(result, isA<Right>());
        verify(mockDataSource.deleteReading('1'));
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should return DatabaseFailure when delete fails', () async {
        // Arrange
        when(mockDataSource.deleteReading('1'))
            .thenThrow(Exception('Delete failed'));

        // Act
        final result = await repository.deleteReading('1');

        // Assert
        expect(result, isA<Left>());
        final failure = result.fold((l) => l, (r) => null)!;
        expect(failure, isA<DatabaseFailure>());
        expect(failure.toString(), contains('Failed to delete reading'));
        verify(mockDataSource.deleteReading('1'));
        verifyNoMoreInteractions(mockDataSource);
      });
    });

    group('getReadingsByDateRange', () {
      test('should return readings in date range', () async {
        // Arrange
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();
        final readingsMap = [
          {
            'id': '1',
            'systolic': 120,
            'diastolic': 80,
            'heartRate': 72,
            'timestamp': startDate.add(const Duration(days: 1)).toIso8601String(),
            'notes': null,
            'lastModified': startDate.add(const Duration(days: 1)).toIso8601String(),
            'isDeleted': 0,
          }
        ];

        when(mockDataSource.getReadingsByDateRange(startDate, endDate))
            .thenAnswer((_) async => readingsMap);

        // Act
        final result = await repository.getReadingsByDateRange(startDate, endDate);

        // Assert
        expect(result, isA<Right>());
        final readings = result.fold((l) => null, (r) => r)!;
        expect(readings.length, 1);
        expect(readings[0].systolic, 120);
        verify(mockDataSource.getReadingsByDateRange(startDate, endDate));
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should return DatabaseFailure when query fails', () async {
        // Arrange
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        when(mockDataSource.getReadingsByDateRange(startDate, endDate))
            .thenThrow(Exception('Query failed'));

        // Act
        final result = await repository.getReadingsByDateRange(startDate, endDate);

        // Assert
        expect(result, isA<Left>());
        final failure = result.fold((l) => l, (r) => null)!;
        expect(failure, isA<DatabaseFailure>());
        expect(failure.toString(), contains('Failed to get readings by date range'));
        verify(mockDataSource.getReadingsByDateRange(startDate, endDate));
        verifyNoMoreInteractions(mockDataSource);
      });
    });

    group('getLatestReading', () {
      test('should return latest reading when exists', () async {
        // Arrange
        final now = DateTime.now();
        final readingMap = {
          'id': '1',
          'systolic': 120,
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': now.toIso8601String(),
          'notes': 'Latest reading',
          'lastModified': now.toIso8601String(),
          'isDeleted': 0,
        };

        when(mockDataSource.getLatestReading())
            .thenAnswer((_) async => readingMap);

        // Act
        final result = await repository.getLatestReading();

        // Assert
        expect(result, isA<Right>());
        final reading = result.fold((l) => null, (r) => r)!;
        expect(reading, isNotNull);
        expect(reading.id, '1');
        expect(reading.systolic, 120);
        expect(reading.notes, 'Latest reading');
        verify(mockDataSource.getLatestReading());
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should return null when no reading exists', () async {
        // Arrange
        when(mockDataSource.getLatestReading())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getLatestReading();

        // Assert
        expect(result, isA<Right>());
        final reading = result.fold((l) => null, (r) => r);
        expect(reading, isNull);
        verify(mockDataSource.getLatestReading());
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should return DatabaseFailure when query fails', () async {
        // Arrange
        when(mockDataSource.getLatestReading())
            .thenThrow(Exception('Query failed'));

        // Act
        final result = await repository.getLatestReading();

        // Assert
        expect(result, isA<Left>());
        final failure = result.fold((l) => l, (r) => null)!;
        expect(failure, isA<DatabaseFailure>());
        expect(failure.toString(), contains('Failed to get latest reading'));
        verify(mockDataSource.getLatestReading());
        verifyNoMoreInteractions(mockDataSource);
      });
    });

    group('getRecentReadings', () {
      test('should get readings for last 30 days by default', () async {
        // Arrange
        final readingsMap = [
          {
            'id': '1',
            'systolic': 120,
            'diastolic': 80,
            'heartRate': 72,
            'timestamp': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            'notes': null,
            'lastModified': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            'isDeleted': 0,
          }
        ];

        when(mockDataSource.getReadingsByDateRange(any, any))
            .thenAnswer((_) async => readingsMap);

        // Act
        final result = await repository.getRecentReadings();

        // Assert
        expect(result, isA<Right>());
        final readings = result.fold((l) => null, (r) => r)!;
        expect(readings.length, 1);
        verify(mockDataSource.getReadingsByDateRange(any, any));
        verifyNoMoreInteractions(mockDataSource);
      });

      test('should get readings for specified days', () async {
        // Arrange
        when(mockDataSource.getReadingsByDateRange(any, any))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getRecentReadings(days: 7);

        // Assert
        expect(result, isA<Right>());
        verify(mockDataSource.getReadingsByDateRange(any, any));
        verifyNoMoreInteractions(mockDataSource);
      });
    });

    group('data mapping', () {
      test('should correctly map isDeleted flag from database', () async {
        // Arrange
        final readingsMap = [
          {
            'id': '1',
            'systolic': 120,
            'diastolic': 80,
            'heartRate': 72,
            'timestamp': DateTime.now().toIso8601String(),
            'notes': null,
            'lastModified': DateTime.now().toIso8601String(),
            'isDeleted': 1, // Should map to true
          },
          {
            'id': '2',
            'systolic': 130,
            'diastolic': 85,
            'heartRate': 75,
            'timestamp': DateTime.now().toIso8601String(),
            'notes': null,
            'lastModified': DateTime.now().toIso8601String(),
            'isDeleted': 0, // Should map to false
          }
        ];

        when(mockDataSource.getAllReadings())
            .thenAnswer((_) async => readingsMap);

        // Act
        final result = await repository.getAllReadings();

        // Assert
        expect(result, isA<Right>());
        final readings = result.fold((l) => null, (r) => r)!;
        expect(readings.length, 2);
        expect(readings[0].isDeleted, isTrue);
        expect(readings[1].isDeleted, isFalse);
      });

      test('should correctly map isDeleted flag to database', () async {
        // Arrange
        final reading = BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
          isDeleted: true,
        );

        when(mockDataSource.insertReading(any))
            .thenAnswer((_) async {});

        // Act
        await repository.addReading(reading);

        // Assert
        final capturedMap = verify(mockDataSource.insertReading(captureAny)).captured.first as Map<String, dynamic>;
        expect(capturedMap['isDeleted'], 1);
      });
    });
  });
}