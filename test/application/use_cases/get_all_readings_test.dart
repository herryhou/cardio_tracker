import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/application/use_cases/get_all_readings.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/core/errors/failures.dart';
import 'package:cardio_tracker/core/usecases/usecase.dart';

import 'get_all_readings_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('GetAllReadings', () {
    late MockBloodPressureRepository mockRepository;
    late GetAllReadings useCase;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
      useCase = GetAllReadings(mockRepository);
    });

    test('should return readings when repository succeeds', () async {
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
      final result = await useCase(const NoParams());

      // Assert
      expect(result, isA<Right>());
      expect(result.fold((l) => l, (r) => r), equals(readings));
      verify(mockRepository.getAllReadings());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Database error');
      when(mockRepository.getAllReadings())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, isA<Left>());
      expect(result.fold((l) => l, (r) => r), equals(failure));
      verify(mockRepository.getAllReadings());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}