import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/domain/repositories/user_settings_repository.dart';
import 'package:cardio_tracker/domain/entities/user_settings.dart';
import 'package:cardio_tracker/domain/value_objects/blood_pressure_category.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'user_settings_repository_test.mocks.dart';

@GenerateMocks([UserSettingsRepository])
void main() {
  group('UserSettingsRepository', () {
    late MockUserSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockUserSettingsRepository();
    });

    test('should return user settings when getSettings succeeds', () async {
      // Arrange
      final settings = UserSettings(
        id: '1',
        name: 'John Doe',
        age: 30,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.getSettings())
          .thenAnswer((_) async => Right(settings));

      // Act
      final result = await mockRepository.getSettings();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals(settings)),
      );
    });

    test('should return failure when getSettings fails', () async {
      // Arrange
      when(mockRepository.getSettings()).thenAnswer(
          (_) async => const Left(DatabaseFailure('Settings not found')));

      // Act
      final result = await mockRepository.getSettings();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<DatabaseFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });

    test('should return void when saveSettings succeeds', () async {
      // Arrange
      final settings = UserSettings(
        id: '1',
        name: 'John Doe',
        age: 30,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.saveSettings(settings))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.saveSettings(settings);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return failure when saveSettings fails', () async {
      // Arrange
      final settings = UserSettings(
        id: '1',
        name: 'John Doe',
        age: 30,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.saveSettings(settings))
          .thenAnswer((_) async => const Left(DatabaseFailure('Save failed')));

      // Act
      final result = await mockRepository.saveSettings(settings);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<DatabaseFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });

    test('should return void when updateNotificationSettings succeeds',
        () async {
      // Arrange
      when(mockRepository.updateNotificationSettings(true))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.updateNotificationSettings(true);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return void when updateDataSharingSettings succeeds',
        () async {
      // Arrange
      when(mockRepository.updateDataSharingSettings(false))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.updateDataSharingSettings(false);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return void when updateMedicationTimes succeeds', () async {
      // Arrange
      final medicationTimes = ['08:00', '14:00', '20:00'];

      when(mockRepository.updateMedicationTimes(medicationTimes))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result =
          await mockRepository.updateMedicationTimes(medicationTimes);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return void when updateReminderTimes succeeds', () async {
      // Arrange
      final reminderTimes = ['09:00', '21:00'];

      when(mockRepository.updateReminderTimes(reminderTimes))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.updateReminderTimes(reminderTimes);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return void when updateTargetCategories succeeds', () async {
      // Arrange
      when(mockRepository.updateTargetCategories(
        BloodPressureCategory.normal,
        BloodPressureCategory.elevated,
      )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.updateTargetCategories(
        BloodPressureCategory.normal,
        BloodPressureCategory.elevated,
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('should return void when resetSettings succeeds', () async {
      // Arrange
      when(mockRepository.resetSettings())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRepository.resetSettings();

      // Assert
      expect(result.isRight(), true);
    });

    test('should return true when hasSettings with existing settings',
        () async {
      // Arrange
      when(mockRepository.hasSettings())
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await mockRepository.hasSettings();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, isTrue),
      );
    });

    test('should return false when hasSettings with no settings', () async {
      // Arrange
      when(mockRepository.hasSettings())
          .thenAnswer((_) async => const Right(false));

      // Act
      final result = await mockRepository.hasSettings();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, isFalse),
      );
    });
  });
}
