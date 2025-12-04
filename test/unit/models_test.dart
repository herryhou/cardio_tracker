import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/blood_pressure_reading.dart';

void main() {
  group('BloodPressureReading Model Tests', () {
    test('should create BloodPressureReading from JSON', () {
      // Arrange
      final Map<String, dynamic> json = {
        'id': 'test-id-123',
        'systolic': 120,
        'diastolic': 80,
        'heartRate': 72,
        'timestamp': '2024-01-15T10:30:00.000Z',
        'notes': 'Morning reading after exercise',
      };

      // Act
      final reading = BloodPressureReading.fromJson(json);

      // Assert
      expect(reading.id, equals('test-id-123'));
      expect(reading.systolic, equals(120));
      expect(reading.diastolic, equals(80));
      expect(reading.heartRate, equals(72));
      expect(reading.notes, equals('Morning reading after exercise'));
      expect(reading.category, equals(BloodPressureCategory.normal));
    });

    test('should convert BloodPressureReading to JSON', () {
      // Arrange
      final reading = BloodPressureReading(
        id: 'test-id-456',
        systolic: 135,
        diastolic: 85,
        heartRate: 78,
        timestamp: DateTime.parse('2024-01-15T14:30:00.000Z'),
        notes: 'Afternoon reading',
      );

      // Act
      final json = reading.toJson();

      // Assert
      expect(json['id'], equals('test-id-456'));
      expect(json['systolic'], equals(135));
      expect(json['diastolic'], equals(85));
      expect(json['heartRate'], equals(78));
      expect(json['timestamp'], equals('2024-01-15T14:30:00.000Z'));
      expect(json['notes'], equals('Afternoon reading'));
    });

    test('should determine correct blood pressure category', () {
      // Test low category
      var reading = BloodPressureReading(
        id: '1',
        systolic: 90,
        diastolic: 60,
        heartRate: 70,
        timestamp: DateTime.now(),
      );
      expect(reading.category, equals(BloodPressureCategory.low));

      // Test normal category
      reading = BloodPressureReading(
        id: '2',
        systolic: 120,
        diastolic: 80,
        heartRate: 70,
        timestamp: DateTime.now(),
      );
      expect(reading.category, equals(BloodPressureCategory.normal));

      // Test elevated category
      reading = BloodPressureReading(
        id: '3',
        systolic: 125,
        diastolic: 82,
        heartRate: 70,
        timestamp: DateTime.now(),
      );
      expect(reading.category, equals(BloodPressureCategory.elevated));

      // Test stage 1 category
      reading = BloodPressureReading(
        id: '4',
        systolic: 135,
        diastolic: 85,
        heartRate: 70,
        timestamp: DateTime.now(),
      );
      expect(reading.category, equals(BloodPressureCategory.stage1));

      // Test stage 2 category
      reading = BloodPressureReading(
        id: '5',
        systolic: 155,
        diastolic: 95,
        heartRate: 70,
        timestamp: DateTime.now(),
      );
      expect(reading.category, equals(BloodPressureCategory.stage2));

      // Test crisis category
      reading = BloodPressureReading(
        id: '6',
        systolic: 185,
        diastolic: 120,
        heartRate: 70,
        timestamp: DateTime.now(),
      );
      expect(reading.category, equals(BloodPressureCategory.crisis));
    });
  });
}