import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/infrastructure/utils/reading_id_generator.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

void main() {
  group('ReadingIdGenerator', () {
    test('should generate consistent ID for same content', () {
      final timestamp = DateTime(2025, 12, 15, 14, 30);

      final id1 = ReadingIdGenerator.generateId(
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp,
        notes: 'Test reading',
      );

      final id2 = ReadingIdGenerator.generateId(
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp,
        notes: 'Test reading',
      );

      expect(id1, equals(id2));
      expect(id1.length, equals(64)); // SHA-256 hash length
    });

    test('should generate different IDs for different content', () {
      final timestamp = DateTime(2025, 12, 15, 14, 30);

      final id1 = ReadingIdGenerator.generateId(
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp,
        notes: null,
      );

      final id2 = ReadingIdGenerator.generateId(
        systolic: 125,
        diastolic: 85,
        heartRate: 75,
        timestamp: timestamp,
        notes: null,
      );

      expect(id1, isNot(equals(id2)));
    });

    test('should normalize timestamp to minute precision', () {
      final timestamp1 = DateTime(2025, 12, 15, 14, 30, 15);
      final timestamp2 = DateTime(2025, 12, 15, 14, 30, 45);

      final id1 = ReadingIdGenerator.generateId(
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp1,
      );

      final id2 = ReadingIdGenerator.generateId(
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: timestamp2,
      );

      // IDs should be the same because timestamps are normalized to minutes
      expect(id1, equals(id2));
    });

    test('should generate ID from BloodPressureReading', () {
      final reading = BloodPressureReading(
        id: 'some-random-id',
        systolic: 122,
        diastolic: 81,
        heartRate: 69,
        timestamp: DateTime(2025, 12, 5, 17, 37),
        notes: 'Elevated',
        lastModified: DateTime.now(),
      );

      final id = ReadingIdGenerator.generateFromReading(reading);
      final directId = ReadingIdGenerator.generateId(
        systolic: 122,
        diastolic: 81,
        heartRate: 69,
        timestamp: DateTime(2025, 12, 5, 17, 37),
        notes: 'Elevated',
      );

      expect(id, equals(directId));
    });

    test('should check content equality correctly', () {
      final reading1 = BloodPressureReading(
        id: 'id1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2025, 12, 15, 14, 30, 15),
        notes: 'Test',
        lastModified: DateTime.now(),
      );

      final reading2 = BloodPressureReading(
        id: 'id2', // Different ID
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2025, 12, 15, 14, 30, 45), // Different seconds
        notes: 'Test',
        lastModified: DateTime.now(),
      );

      final reading3 = BloodPressureReading(
        id: 'id3',
        systolic: 125, // Different systolic
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2025, 12, 15, 14, 30, 15),
        notes: 'Test',
        lastModified: DateTime.now(),
      );

      expect(ReadingIdGenerator.areContentEqual(reading1, reading2), isTrue);
      expect(ReadingIdGenerator.areContentEqual(reading1, reading3), isFalse);
    });

    test('should handle null/empty notes correctly', () {
      final reading1 = BloodPressureReading(
        id: 'id1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2025, 12, 15, 14, 30),
        notes: null,
        lastModified: DateTime.now(),
      );

      final reading2 = BloodPressureReading(
        id: 'id2',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2025, 12, 15, 14, 30),
        notes: '',
        lastModified: DateTime.now(),
      );

      final reading3 = BloodPressureReading(
        id: 'id3',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2025, 12, 15, 14, 30),
        notes: ' ',
        lastModified: DateTime.now(),
      );

      expect(ReadingIdGenerator.areContentEqual(reading1, reading2), isTrue);
      expect(ReadingIdGenerator.areContentEqual(reading1, reading3), isTrue);
    });
  });
}