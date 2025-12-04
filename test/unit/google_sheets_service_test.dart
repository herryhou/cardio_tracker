import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';
import 'package:cardio_tracker/services/google_sheets_service.dart';

void main() {
  group('GoogleSheetsService', () {
    test('readingToRow converts BloodPressureReading to correct row format', () {
      // Arrange
      final reading = BloodPressureReading(
        id: 'test-id-123',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2023, 12, 4, 10, 30, 0),
        notes: 'Feeling good',
      );

      // Act
      // This will fail because GoogleSheetsService doesn't exist yet
      final row = GoogleSheetsService.readingToRow(reading);

      // Assert
      expect(row, contains('2023-12-04 10:30:00')); // Formatted timestamp
      expect(row, contains(120)); // Systolic
      expect(row, contains(80)); // Diastolic
      expect(row, contains(72)); // Heart rate
      expect(row, contains('Feeling good')); // Notes
      expect(row.length, equals(5)); // [timestamp, systolic, diastolic, heartRate, notes]
    });

    test('rowToReading converts row to BloodPressureReading correctly', () {
      // Arrange
      final row = [
        '2023-12-04 10:30:00', // timestamp
        120, // systolic
        80,  // diastolic
        72,  // heart rate
        'Feeling good', // notes
      ];

      // Act
      // This will fail because GoogleSheetsService doesn't exist yet
      final reading = GoogleSheetsService.rowToReading(row, 'test-id-123');

      // Assert
      expect(reading.id, equals('test-id-123'));
      expect(reading.systolic, equals(120));
      expect(reading.diastolic, equals(80));
      expect(reading.heartRate, equals(72));
      expect(reading.notes, equals('Feeling good'));
      expect(reading.timestamp.year, equals(2023));
      expect(reading.timestamp.month, equals(12));
      expect(reading.timestamp.day, equals(4));
      expect(reading.timestamp.hour, equals(10));
      expect(reading.timestamp.minute, equals(30));
    });

    test('rowToReading handles null notes correctly', () {
      // Arrange
      final row = [
        '2023-12-04 10:30:00', // timestamp
        120, // systolic
        80,  // diastolic
        72,  // heart rate
        '',  // empty notes
      ];

      // Act
      final reading = GoogleSheetsService.rowToReading(row, 'test-id-123');

      // Assert
      expect(reading.notes, equals('')); // Empty string, not null
    });

    test('readingToRow handles null notes correctly', () {
      // Arrange
      final reading = BloodPressureReading(
        id: 'test-id-123',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime(2023, 12, 4, 10, 30, 0),
        notes: null,
      );

      // Act
      final row = GoogleSheetsService.readingToRow(reading);

      // Assert
      expect(row.last, equals('')); // Convert null to empty string
    });
  });
}