import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/application/use_cases/add_reading.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'add_reading_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('AddReading', () {
    late MockBloodPressureRepository mockRepository;
    late AddReading useCase;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
      useCase = AddReading(mockRepository);
    });

    test('should add valid reading successfully', () async {
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
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Right>());
      verify(mockRepository.addReading(reading));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return validation failure for invalid systolic (too low)', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 49, // Invalid low value
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      expect(failure.toString(),
             contains('Systolic must be between 50 and 300'));
      verifyNever(mockRepository.addReading(any));
    });

    test('should return validation failure for invalid systolic (too high)', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 301, // Invalid high value
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      expect(failure.toString(),
             contains('Systolic must be between 50 and 300'));
      verifyNever(mockRepository.addReading(any));
    });

    test('should return validation failure for invalid diastolic (too low)', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 29, // Invalid low value
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      expect(failure.toString(),
             contains('Diastolic must be between 30 and 200'));
      verifyNever(mockRepository.addReading(any));
    });

    test('should return validation failure for invalid diastolic (too high)', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 201, // Invalid high value
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      expect(failure.toString(),
             contains('Diastolic must be between 30 and 200'));
      verifyNever(mockRepository.addReading(any));
    });

    test('should return validation failure for invalid heart rate (too high)', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 301, // Invalid high value
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      expect(failure.toString(),
             contains('Heart rate must be between 0 and 300'));
      verifyNever(mockRepository.addReading(any));
    });

    test('should return validation failure for negative heart rate', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: -1, // Invalid negative value
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      expect(failure.toString(),
             contains('Heart rate must be between 0 and 300'));
      verifyNever(mockRepository.addReading(any));
    });

    test('should add reading with valid boundary values', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 50, // Minimum valid
        diastolic: 30, // Minimum valid
        heartRate: 0, // Minimum valid
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockRepository.addReading(reading))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Right>());
      verify(mockRepository.addReading(reading));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should add reading with maximum valid boundary values', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 300, // Maximum valid
        diastolic: 200, // Maximum valid
        heartRate: 300, // Maximum valid
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockRepository.addReading(reading))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Right>());
      verify(mockRepository.addReading(reading));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository failure when adding fails', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      const failure = DatabaseFailure('Insert failed');
      when(mockRepository.addReading(reading))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      final resultFailure = result.fold((l) => l, (r) => null);
      expect(resultFailure, equals(failure));
      verify(mockRepository.addReading(reading));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}