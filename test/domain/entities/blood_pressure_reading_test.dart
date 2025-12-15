import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/value_objects/blood_pressure_category.dart';

void main() {
  group('BloodPressureReading', () {
    test('should create reading with required fields', () {
      // Arrange
      final timestamp = DateTime.now();
      final lastModified = DateTime.now();

      // Act
      final reading = BloodPressureReading(
        id: 'test-id',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp,
        lastModified: lastModified,
      );

      // Assert
      expect(reading.id, 'test-id');
      expect(reading.systolic, 120);
      expect(reading.diastolic, 80);
      expect(reading.heartRate, 72);
      expect(reading.timestamp, timestamp);
      expect(reading.lastModified, lastModified);
      expect(reading.notes, null);
      expect(reading.isDeleted, false);
    });

    test('should calculate correct category', () {
      // Arrange
      final reading = BloodPressureReading(
        id: 'test-id',
        systolic: 125,
        diastolic: 82,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act & Assert
      expect(reading.category, BloodPressureCategory.elevated);
    });

    test('should return hasHeartRate correctly', () {
      // Arrange
      final readingWithHR = BloodPressureReading(
        id: 'test-id',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      final readingWithoutHR = BloodPressureReading(
        id: 'test-id-2',
        systolic: 120,
        diastolic: 80,
        heartRate: 0,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act & Assert
      expect(readingWithHR.hasHeartRate, true);
      expect(readingWithoutHR.hasHeartRate, false);
    });

    test('should copy with new values', () {
      // Arrange
      final original = BloodPressureReading(
        id: 'test-id',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
        notes: 'Original notes',
      );

      final newTimestamp = DateTime.now().add(const Duration(days: 1));

      // Act
      final updated = original.copyWith(
        systolic: 130,
        notes: 'Updated notes',
        timestamp: newTimestamp,
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.systolic, 130);
      expect(updated.diastolic, original.diastolic);
      expect(updated.heartRate, original.heartRate);
      expect(updated.timestamp, newTimestamp);
      expect(updated.notes, 'Updated notes');
      expect(updated.lastModified, original.lastModified);
      expect(updated.isDeleted, original.isDeleted);
    });

    test('should compare equality correctly', () {
      // Arrange
      final timestamp = DateTime.now();
      final reading1 = BloodPressureReading(
        id: 'test-id',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp,
        lastModified: timestamp,
      );

      final reading2 = BloodPressureReading(
        id: 'test-id',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp,
        lastModified: timestamp,
      );

      final reading3 = BloodPressureReading(
        id: 'different-id',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp,
        lastModified: timestamp,
      );

      // Act & Assert
      expect(reading1, equals(reading2));
      expect(reading1, isNot(equals(reading3)));
    });
  });
}
