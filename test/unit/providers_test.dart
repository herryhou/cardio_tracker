import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../lib/models/blood_pressure_reading.dart';
import '../../lib/providers/blood_pressure_provider.dart';
import '../../lib/services/database_service.dart';

void main() {
  // Initialize Flutter test bindings
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize ffi loader
    sqfliteFfiInit();
    // Set global factory
    databaseFactory = databaseFactoryFfi;
  });

  group('BloodPressureProvider Tests', () {
    late DatabaseService databaseService;
    late BloodPressureProvider provider;

    setUp(() async {
      databaseService = DatabaseService.instance;
      await databaseService.init('test_db.db');
      provider = BloodPressureProvider(databaseService: databaseService);
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('should add a new reading', () async {
      final reading = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        notes: 'Test reading',
      );

      await provider.addReading(reading);

      expect(provider.readings.contains(reading), isTrue);
      expect(provider.readings.length, equals(1));
    });

    test('should load readings from database', () async {
      final readings = [
        BloodPressureReading(
          id: 'test-1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
        ),
        BloodPressureReading(
          id: 'test-2',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: DateTime.now().subtract(Duration(days: 1)),
        ),
      ];

      // Add readings directly to database
      for (final reading in readings) {
        await databaseService.insertReading(reading);
      }

      await provider.loadReadings();

      expect(provider.readings.length, equals(2));
      // Should be sorted by timestamp descending
      expect(provider.readings.first.id, equals('test-1'));
      expect(provider.readings.last.id, equals('test-2'));
    });

    test('should calculate average systolic pressure', () async {
      // Add test readings
      final reading1 = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
      );

      final reading2 = BloodPressureReading(
        id: 'test-2',
        systolic: 130,
        diastolic: 85,
        heartRate: 75,
        timestamp: DateTime.now(),
      );

      await provider.addReading(reading1);
      await provider.addReading(reading2);

      expect(provider.averageSystolic, equals(125.0));
    });

    test('should calculate average diastolic pressure', () async {
      // Add test readings
      final reading1 = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
      );

      final reading2 = BloodPressureReading(
        id: 'test-2',
        systolic: 130,
        diastolic: 85,
        heartRate: 75,
        timestamp: DateTime.now(),
      );

      await provider.addReading(reading1);
      await provider.addReading(reading2);

      expect(provider.averageDiastolic, equals(82.5));
    });

    test('should get latest reading', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));

      final reading1 = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: yesterday,
      );

      final reading2 = BloodPressureReading(
        id: 'test-2',
        systolic: 130,
        diastolic: 85,
        heartRate: 75,
        timestamp: now,
      );

      await provider.addReading(reading1);
      await provider.addReading(reading2);

      expect(provider.latestReading, equals(reading2));
    });

    test('should return null when no latest reading', () {
      expect(provider.latestReading, isNull);
    });

    test('should update reading', () async {
      final originalReading = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
      );

      final updatedReading = originalReading.copyWith(
        systolic: 125,
        diastolic: 82,
      );

      await provider.addReading(originalReading);
      await provider.updateReading(updatedReading);

      expect(provider.readings.contains(originalReading), isFalse);
      expect(provider.readings.contains(updatedReading), isTrue);
    });

    test('should delete reading', () async {
      final reading = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
      );

      await provider.addReading(reading);
      expect(provider.readings.contains(reading), isTrue);

      await provider.deleteReading('test-1');
      expect(provider.readings.contains(reading), isFalse);
    });

    test('should filter readings by date range', () async {
      final baseDate = DateTime(2024, 1, 15);

      final reading1 = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: baseDate,
      );

      final reading2 = BloodPressureReading(
        id: 'test-2',
        systolic: 130,
        diastolic: 85,
        heartRate: 75,
        timestamp: baseDate.add(Duration(days: 2)),
      );

      final reading3 = BloodPressureReading(
        id: 'test-3',
        systolic: 125,
        diastolic: 82,
        heartRate: 74,
        timestamp: baseDate.add(Duration(days: 5)),
      );

      await provider.addReading(reading1);
      await provider.addReading(reading2);
      await provider.addReading(reading3);

      final startDate = baseDate.add(Duration(days: 1));
      final endDate = baseDate.add(Duration(days: 3));

      final filteredReadings = provider.getReadingsByDateRange(startDate, endDate);

      expect(filteredReadings.length, equals(1));
      expect(filteredReadings.first.id, equals('test-2'));
    });

    test('should handle empty readings list', () {
      expect(provider.averageSystolic, equals(0.0));
      expect(provider.averageDiastolic, equals(0.0));
      expect(provider.averageHeartRate, equals(0.0));
      expect(provider.readings.isEmpty, isTrue);
    });
  });
}