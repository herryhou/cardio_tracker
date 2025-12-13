import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'blood_pressure_repository_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('BloodPressureRepository', () {
    late MockBloodPressureRepository mockRepository;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
    });

    test('should return list of readings when getAll succeeds', () async {
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

      when(mockRepository.getAllReadings())
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await mockRepository.getAllReadings();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals(readings)),
      );
    });

    test('should return failure when getAll fails', () async {
      // Arrange
      when(mockRepository.getAllReadings())
          .thenAnswer((_) async => Left(DatabaseFailure('Database error')));

      // Act
      final result = await mockRepository.getAllReadings();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<DatabaseFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });

    test('should return void when addReading succeeds', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockRepository.addReading(reading))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.addReading(reading);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return failure when addReading fails', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockRepository.addReading(reading))
          .thenAnswer((_) async => Left(DatabaseFailure('Insert failed')));

      // Act
      final result = await mockRepository.addReading(reading);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<DatabaseFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });

    test('should return void when updateReading succeeds', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockRepository.updateReading(reading))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.updateReading(reading);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return void when deleteReading succeeds', () async {
      // Arrange
      when(mockRepository.deleteReading('1'))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.deleteReading('1');

      // Assert
      expect(result.isRight(), true);
    });

    test('should return readings by date range', () async {
      // Arrange
      final startDate = DateTime.now().subtract(const Duration(days: 7));
      final endDate = DateTime.now();
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

      when(mockRepository.getReadingsByDateRange(startDate, endDate))
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await mockRepository.getReadingsByDateRange(startDate, endDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals(readings)),
      );
    });

    test('should return latest reading', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockRepository.getLatestReading())
          .thenAnswer((_) async => Right(reading));

      // Act
      final result = await mockRepository.getLatestReading();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals(reading)),
      );
    });

    test('should return null when no latest reading exists', () async {
      // Arrange
      when(mockRepository.getLatestReading())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.getLatestReading();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, isNull),
      );
    });

    test('should return recent readings', () async {
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

      when(mockRepository.getRecentReadings(days: 30))
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await mockRepository.getRecentReadings(days: 30);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals(readings)),
      );
    });
  });
}