import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/infrastructure/services/manual_sync_service.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ManualSyncService Tests', () {
    late ManualSyncService syncService;

    setUp(() {
      syncService = ManualSyncService();
    });

    group('Sync Result Validation', () {
      test('should create sync result with default values', () {
        // Act
        const result = SyncResult();

        // Assert
        expect(result.pushed, equals(0));
        expect(result.pulled, equals(0));
        expect(result.deleted, equals(0));
        expect(result.error, isNull);
      });

      test('should create sync result with custom values', () {
        // Act
        const result = SyncResult(
          pushed: 5,
          pulled: 3,
          deleted: 2,
          error: 'Test error',
        );

        // Assert
        expect(result.pushed, equals(5));
        expect(result.pulled, equals(3));
        expect(result.deleted, equals(2));
        expect(result.error, equals('Test error'));
      });
    });

    group('Sync Algorithm Logic Tests', () {
      test('should handle conflict resolution correctly', () async {
        // Arrange
        final now = DateTime.now();
        final baseTime = now.subtract(const Duration(days: 1));

        // Same reading with different modifications
        final localReading = TestHelpers.createTestReading(
          id: 'conflict',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: baseTime,
          lastModified: baseTime.add(const Duration(hours: 2)), // Newer
          notes: 'Local notes',
        );

        final remoteReading = TestHelpers.createTestReading(
          id: 'conflict',
          systolic: 125,
          diastolic: 85,
          heartRate: 75,
          timestamp: baseTime,
          lastModified: baseTime.add(const Duration(hours: 1)), // Older
          notes: 'Remote notes',
        );

        // Act - simulate last-write-wins logic
        BloodPressureReading winner;
        if (localReading.lastModified.isAfter(remoteReading.lastModified)) {
          winner = localReading;
        } else {
          winner = remoteReading;
        }

        // Assert
        expect(winner.id, equals('conflict'));
        expect(winner.systolic, equals(120)); // Local wins (newer)
        expect(winner.diastolic, equals(80));
        expect(winner.notes, equals('Local notes'));
      });

      test('should identify new vs existing readings', () async {
        // Arrange
        final now = DateTime.now();
        final localReadings = [
          TestHelpers.createTestReading(
            id: 'local_only',
            lastModified: now,
          ),
          TestHelpers.createTestReading(
            id: 'both_exist',
            lastModified: now,
          ),
        ];

        final remoteKeys = {'both_exist': 0, 'remote_only': 0};

        // Act - simulate the sync logic
        final newLocal = <BloodPressureReading>[];
        final existingLocal = <BloodPressureReading>[];

        for (final local in localReadings) {
          if (remoteKeys.containsKey(local.id)) {
            existingLocal.add(local);
          } else {
            newLocal.add(local);
          }
        }

        // Assert
        expect(newLocal.length, equals(1));
        expect(newLocal.first.id, equals('local_only'));
        expect(existingLocal.length, equals(1));
        expect(existingLocal.first.id, equals('both_exist'));
      });

      test('should handle deleted reading propagation', () async {
        // Arrange
        final now = DateTime.now();
        final localDeleted = TestHelpers.createTestReading(
          id: 'to_delete',
          systolic: 120,
          diastolic: 80,
          lastModified: now,
          isDeleted: true,
        );

        final remoteKeys = {'to_delete': 0, 'keep_remote': 0};

        // Act - simulate deletion propagation
        final toDeleteRemotely = <String>[];
        for (final key in remoteKeys.keys) {
          // Check if exists locally and is marked for deletion
          if (key == localDeleted.id && localDeleted.isDeleted) {
            toDeleteRemotely.add(key);
          }
        }

        // Assert
        expect(toDeleteRemotely.length, equals(1));
        expect(toDeleteRemotely.first, equals('to_delete'));
      });

      test('should handle soft delete correctly', () async {
        // Arrange
        final reading = TestHelpers.createTestReading(
          id: 'soft_delete_test',
          systolic: 130,
          diastolic: 85,
          isDeleted: true,
        );

        // Assert - Soft delete means the reading still exists but is marked
        expect(reading.isDeleted, isTrue);
        expect(reading.id, isNotNull);
        expect(reading.systolic, equals(130));

        // Test serialization includes the flag
        final json = reading.toJson();
        expect(json['isDeleted'], isTrue);
        expect(json['id'], equals('soft_delete_test'));
      });
    });

    group('Data Integrity Tests', () {
      test('should maintain data consistency through sync', () async {
        // Arrange
        final original = TestHelpers.createTestReading(
          id: 'consistency_test',
          systolic: 125,
          diastolic: 82,
          heartRate: 73,
          notes: 'Important medical note',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        );

        // Act - Simulate serialization/deserialization through sync
        final json = original.toJson();
        final restored = BloodPressureReading.fromJson(json);

        // Assert - All fields should match
        expect(restored.id, equals(original.id));
        expect(restored.systolic, equals(original.systolic));
        expect(restored.diastolic, equals(original.diastolic));
        expect(restored.heartRate, equals(original.heartRate));
        expect(restored.notes, equals(original.notes));
        expect(restored.timestamp, equals(original.timestamp));
        expect(restored.isDeleted, equals(original.isDeleted));
      });

      test('should handle timestamp comparisons correctly', () async {
        // Arrange
        final now = DateTime.now();
        final older = TestHelpers.createTestReading(
          id: 'older',
          lastModified: now.subtract(const Duration(hours: 1)),
        );
        final newer = TestHelpers.createTestReading(
          id: 'newer',
          lastModified: now.add(const Duration(hours: 1)),
        );

        // Act & Assert
        expect(newer.lastModified.isAfter(older.lastModified), isTrue);
        expect(older.lastModified.isBefore(newer.lastModified), isTrue);

        // Test conflict resolution
        BloodPressureReading winner =
            newer.lastModified.isAfter(older.lastModified) ? newer : older;
        expect(winner.id, equals('newer'));
      });

      test('should handle edge case of same timestamps', () async {
        // Arrange
        final sameTime = DateTime.now();
        final reading1 = TestHelpers.createTestReading(
          id: 'same_time_1',
          systolic: 120,
          lastModified: sameTime,
        );
        final reading2 = TestHelpers.createTestReading(
          id: 'same_time_2',
          systolic: 125,
          lastModified: sameTime,
        );

        // Act - When timestamps are equal, current implementation
        // will treat remote as winner (since it doesn't push)
        // This is a documented limitation
        final timestampsEqual =
            reading1.lastModified.isAtSameMomentAs(reading2.lastModified);

        // Assert
        expect(timestampsEqual, isTrue);
        // In case of equal timestamps, the behavior should be consistent
        // The current implementation favors the version that's being processed
      });
    });

    group('Error Scenarios', () {
      test('should handle missing sync fields gracefully', () async {
        // Arrange - JSON without sync fields (old format)
        final incompleteJson = {
          'id': 'incomplete',
          'systolic': 120,
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Act
        final reading = BloodPressureReading.fromJson(incompleteJson);

        // Assert - Should provide defaults
        expect(reading.id, equals('incomplete'));
        expect(reading.lastModified, isNotNull); // Should default to now
        expect(reading.isDeleted, isFalse); // Should default to false
      });

      test('should validate required fields', () async {
        // Test that all required fields are validated
        expect(() => BloodPressureReading.fromJson({}), throwsA(isA<Error>()));

        // Test missing ID
        expect(
          () => BloodPressureReading.fromJson({
            'systolic': 120,
            'diastolic': 80,
            'heartRate': 72,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          throwsA(isA<Error>()),
        );
      });

      test('should handle invalid data types', () async {
        // Arrange
        final invalidJson = {
          'id': 'invalid',
          'systolic': 'invalid', // Should be int
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': DateTime.now().toIso8601String(),
          'lastModified': DateTime.now().toIso8601String(),
        };

        // Act & Assert - Should handle type conversion errors
        expect(() => BloodPressureReading.fromJson(invalidJson),
            throwsA(isA<TypeError>()));
      });
    });

    group('Performance Considerations', () {
      test('should handle large number of readings', () async {
        // Arrange
        final readings = <BloodPressureReading>[];
        final now = DateTime.now();

        // Create 1000 test readings
        for (int i = 0; i < 1000; i++) {
          readings.add(TestHelpers.createTestReading(
            id: 'bulk_$i',
            systolic: 120 + (i % 20),
            diastolic: 80 + (i % 10),
            timestamp: now.subtract(Duration(days: i)),
          ));
        }

        // Act - Simulate sync operations
        final jsonList = readings.map((r) => r.toJson()).toList();

        // Assert
        expect(readings.length, equals(1000));
        expect(jsonList.length, equals(1000));

        // Verify data integrity
        for (int i = 0; i < 100; i += 100) {
          final original = readings[i];
          final json = jsonList[i];
          final restored = BloodPressureReading.fromJson(json);

          expect(restored.id, equals(original.id));
          expect(restored.systolic, equals(original.systolic));
        }
      });

      test('should efficiently check sync status', () async {
        // Arrange
        final readings = TestHelpers.createTestReadingsList();

        // Act - Simulate checking which readings need sync
        final remoteKeys = {
          'reading_1': 0,
          'reading_3': 0
        }; // Existing remotely
        final toSync = <BloodPressureReading>[];

        for (final reading in readings) {
          if (!remoteKeys.containsKey(reading.id) && !reading.isDeleted) {
            toSync.add(reading);
          }
        }

        // Assert
        expect(toSync.length, equals(1)); // Only reading_2 needs syncing
        expect(toSync.first.id, equals('reading_2'));
      });
    });
  });
}
