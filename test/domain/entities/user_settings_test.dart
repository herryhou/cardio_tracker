import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/domain/entities/user_settings.dart';
import 'package:cardio_tracker/domain/value_objects/blood_pressure_category.dart';

void main() {
  group('UserSettings', () {
    test('should create user settings with required fields', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final settings = UserSettings(
        id: 'user-123',
        name: 'John Doe',
        age: 45,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00', '21:00'],
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(settings.id, 'user-123');
      expect(settings.name, 'John Doe');
      expect(settings.age, 45);
      expect(settings.gender, 'male');
      expect(settings.targetMinCategory, BloodPressureCategory.normal);
      expect(settings.targetMaxCategory, BloodPressureCategory.normal);
      expect(settings.medicationTimes, ['08:00', '20:00']);
      expect(settings.reminderTimes, ['09:00', '21:00']);
      expect(settings.notificationsEnabled, true);
      expect(settings.dataSharingEnabled, false);
    });

    test('should copy with new values', () {
      // Arrange
      final original = UserSettings(
        id: 'user-123',
        name: 'John Doe',
        age: 45,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00', '21:00'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final updated = original.copyWith(
        name: 'Jane Doe',
        age: 46,
        notificationsEnabled: false,
        dataSharingEnabled: true,
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.name, 'Jane Doe');
      expect(updated.age, 46);
      expect(updated.gender, original.gender);
      expect(updated.notificationsEnabled, false);
      expect(updated.dataSharingEnabled, true);
    });

    test('should compare equality correctly', () {
      // Arrange - Use fixed DateTime to ensure consistency
      final now = DateTime.utc(2025, 1, 1);
      final settings1 = UserSettings(
        id: 'user-123',
        name: 'John Doe',
        age: 45,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00', '21:00'],
        createdAt: now,
        updatedAt: now,
      );

      final settings2 = UserSettings(
        id: 'user-123',
        name: 'John Doe',
        age: 45,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00', '21:00'],
        createdAt: now,
        updatedAt: now,
      );

      // Use a different ID for the third setting to ensure inequality
      final settings3 = UserSettings(
        id: 'user-456',
        name: 'John Doe',
        age: 45,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00', '21:00'],
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });
}