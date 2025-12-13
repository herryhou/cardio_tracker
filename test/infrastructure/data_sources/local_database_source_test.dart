import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cardio_tracker/infrastructure/data_sources/local_database_source.dart';

void main() {
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Set database factory
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalDatabaseSource', () {
    late LocalDatabaseSource dataSource;

    setUp(() async {
      dataSource = LocalDatabaseSource();
      await dataSource.initDatabase(':memory:');
    });

    tearDown(() async {
      await dataSource.closeDatabase();
    });

    test('should insert and retrieve reading', () async {
      // Arrange
      final readingMap = {
        'id': '1',
        'systolic': 120,
        'diastolic': 80,
        'heartRate': 72,
        'timestamp': DateTime.now().toIso8601String(),
        'notes': null,
        'lastModified': DateTime.now().toIso8601String(),
        'isDeleted': 0,
      };

      // Act
      await dataSource.insertReading(readingMap);
      final result = await dataSource.getAllReadings();

      // Assert
      expect(result.length, 1);
      expect(result.first['id'], '1');
      expect(result.first['systolic'], 120);
    });

    test('should get readings by date range', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));

      final readings = [
        {
          'id': '1',
          'systolic': 120,
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': now.toIso8601String(),
          'notes': null,
          'lastModified': now.toIso8601String(),
          'isDeleted': 0,
        },
        {
          'id': '2',
          'systolic': 130,
          'diastolic': 85,
          'heartRate': 75,
          'timestamp': yesterday.toIso8601String(),
          'notes': null,
          'lastModified': yesterday.toIso8601String(),
          'isDeleted': 0,
        },
        {
          'id': '3',
          'systolic': 115,
          'diastolic': 75,
          'heartRate': 70,
          'timestamp': twoDaysAgo.toIso8601String(),
          'notes': null,
          'lastModified': twoDaysAgo.toIso8601String(),
          'isDeleted': 0,
        },
      ];

      for (final reading in readings) {
        await dataSource.insertReading(reading);
      }

      // Act
      final startDate = now.subtract(const Duration(days: 1, hours: 1));
      final endDate = now.add(const Duration(hours: 1));
      final result = await dataSource.getReadingsByDateRange(startDate, endDate);

      // Assert
      expect(result.length, 2);
      expect(result.first['id'], '1');
      expect(result.last['id'], '2');
    });

    test('should update reading', () async {
      // Arrange
      final originalReading = {
        'id': '1',
        'systolic': 120,
        'diastolic': 80,
        'heartRate': 72,
        'timestamp': DateTime.now().toIso8601String(),
        'notes': null,
        'lastModified': DateTime.now().toIso8601String(),
        'isDeleted': 0,
      };
      await dataSource.insertReading(originalReading);

      // Act
      final updatedReading = Map<String, dynamic>.from(originalReading);
      updatedReading['systolic'] = 130;
      updatedReading['diastolic'] = 85;
      updatedReading['lastModified'] = DateTime.now().toIso8601String();
      await dataSource.updateReading(updatedReading);

      // Assert
      final result = await dataSource.getAllReadings();
      expect(result.length, 1);
      expect(result.first['systolic'], 130);
      expect(result.first['diastolic'], 85);
    });

    test('should soft delete reading', () async {
      // Arrange
      final reading = {
        'id': '1',
        'systolic': 120,
        'diastolic': 80,
        'heartRate': 72,
        'timestamp': DateTime.now().toIso8601String(),
        'notes': null,
        'lastModified': DateTime.now().toIso8601String(),
        'isDeleted': 0,
      };
      await dataSource.insertReading(reading);

      // Act
      await dataSource.deleteReading('1');

      // Assert
      final result = await dataSource.getAllReadings();
      expect(result.length, 0);
    });

    test('should get latest reading', () async {
      // Arrange
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));

      final readings = [
        {
          'id': '1',
          'systolic': 120,
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': earlier.toIso8601String(),
          'notes': null,
          'lastModified': earlier.toIso8601String(),
          'isDeleted': 0,
        },
        {
          'id': '2',
          'systolic': 130,
          'diastolic': 85,
          'heartRate': 75,
          'timestamp': now.toIso8601String(),
          'notes': null,
          'lastModified': now.toIso8601String(),
          'isDeleted': 0,
        },
      ];

      for (final reading in readings) {
        await dataSource.insertReading(reading);
      }

      // Act
      final result = await dataSource.getLatestReading();

      // Assert
      expect(result, isNotNull);
      expect(result!['id'], '2');
      expect(result['systolic'], 130);
    });

    test('should return null when no readings exist', () async {
      // Act
      final result = await dataSource.getLatestReading();

      // Assert
      expect(result, isNull);
    });

    test('should return empty list when no readings exist', () async {
      // Act
      final result = await dataSource.getAllReadings();

      // Assert
      expect(result, isEmpty);
    });
  });
}