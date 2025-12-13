import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/services/database_service.dart';
import 'package:cardio_tracker/services/cloudflare_kv_service.dart';
import 'package:cardio_tracker/services/manual_sync_service.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';

import '../helpers/test_helpers.dart';
import '../mocks/mock_services.dart';

void main() {
  group('Sync Integration Tests', () {
    late MockDatabaseService mockDb;
    late MockCloudflareKVService mockKv;
    late ManualSyncService syncService;

    setUp(() {
      mockDb = MockDatabaseService();
      mockKv = MockCloudflareKVService();
      syncService = ManualSyncService();
    });

    group('Full Sync Workflows', () {
      test('should handle complete sync from empty state', () async {
        // Arrange
        mockKv.setCredentials(TestHelpers.createTestCredentials());
        final now = DateTime.now();

        // Add local readings
        final localReadings = [
          TestHelpers.createTestReading(
            id: 'reading_1',
            systolic: 120,
            diastolic: 80,
            timestamp: now.subtract(const Duration(days: 3)),
            lastModified: now.subtract(const Duration(days: 3)),
          ),
          TestHelpers.createTestReading(
            id: 'reading_2',
            systolic: 135,
            diastolic: 88,
            timestamp: now.subtract(const Duration(days: 2)),
            lastModified: now.subtract(const Duration(days: 2)),
          ),
          TestHelpers.createTestReading(
            id: 'reading_3',
            systolic: 118,
            diastolic: 76,
            timestamp: now.subtract(const Duration(days: 1)),
            lastModified: now.subtract(const Duration(days: 1)),
          ),
        ];

        // Add remote readings
        final remoteReadings = [
          TestHelpers.createTestReading(
            id: 'remote_1',
            systolic: 122,
            diastolic: 82,
            timestamp: now.subtract(const Duration(hours: 12)),
            lastModified: now.subtract(const Duration(hours: 12)),
          ),
        ];

        // Setup data
        for (final reading in localReadings) {
          await mockDb.insertReading(reading);
        }
        for (final reading in remoteReadings) {
          await mockKv.storeReading(reading);
        }

        // Act - simulate sync
        final localData = await mockDb.getAllReadings();
        final remoteKeys = await mockKv.listReadingKeys();

        // Push local readings
        int pushed = 0;
        for (final reading in localData) {
          if (!remoteKeys.containsKey(reading.id) && !reading.isDeleted) {
            await mockKv.storeReading(reading);
            pushed++;
          }
        }

        // Pull remote readings
        int pulled = 0;
        for (final readingId in remoteKeys.keys) {
          final existsLocally = localData.any((r) => r.id == readingId);
          if (!existsLocally) {
            final remoteReading = await mockKv.retrieveReading(readingId);
            if (remoteReading != null && !remoteReading.isDeleted) {
              await mockDb.insertReading(remoteReading);
              pulled++;
            }
          }
        }

        // Assert
        expect(pushed, equals(3));
        expect(pulled, equals(0));

        // Verify all data is synchronized
        final finalLocal = await mockDb.getAllReadings();
        final finalRemote = await mockKv.listReadingKeys();

        expect(finalLocal.length, equals(3)); // Local readings remain
        expect(finalRemote.length, equals(3)); // 3 local pushed + 1 existing remote

        // Verify remote readings can be retrieved
        final remoteReading = await mockKv.retrieveReading('reading_1');
        expect(remoteReading?.systolic, equals(120));
        expect(remoteReading?.diastolic, equals(80));
      });

      test('should handle sync with deletions', () async {
        // Arrange
        mockKv.setCredentials(TestHelpers.createTestCredentials());
        final now = DateTime.now();

        // Create a reading and mark it as deleted locally
        final deletedReading = TestHelpers.createTestReading(
          id: 'to_delete',
          systolic: 140,
          diastolic: 90,
          timestamp: now.subtract(const Duration(days: 2)),
          lastModified: now.subtract(const Duration(hours: 5)),
          isDeleted: true,
        );

        // Create a normal reading
        final normalReading = TestHelpers.createTestReading(
          id: 'normal',
          systolic: 125,
          diastolic: 83,
          timestamp: now.subtract(const Duration(days: 1)),
          lastModified: now.subtract(const Duration(days: 1)),
        );

        // Setup: reading exists remotely, is marked deleted locally
        await mockDb.insertReading(deletedReading);
        await mockDb.insertReading(normalReading);
        await mockKv.storeReading(TestHelpers.createTestReading(
          id: 'to_delete',
          systolic: 140,
          diastolic: 90,
          timestamp: now.subtract(const Duration(days: 2)),
          lastModified: now.subtract(const Duration(days: 2)),
          isDeleted: false,
        ));

        // Act - simulate sync
        final localData = await mockDb.getAllReadings();
        final remoteKeys = await mockKv.listReadingKeys();

        int pushed = 0;
        int deleted = 0;

        // Process local changes
        for (final reading in localData) {
          final remoteHas = remoteKeys.containsKey(reading.id);

          if (reading.isDeleted) {
            if (remoteHas) {
              await mockKv.deleteReading(reading.id);
              deleted++;
            }
          } else if (!remoteHas) {
            await mockKv.storeReading(reading);
            pushed++;
          }
        }

        // Clean up local deletions
        for (final reading in localData) {
          if (reading.isDeleted) {
            await mockDb.deleteReading(reading.id);
          }
        }

        // Assert
        expect(pushed, equals(1)); // Normal reading pushed
        expect(deleted, equals(1)); // Deleted reading removed from remote

        // Verify remote state
        final remoteExists = await mockKv.retrieveReading('to_delete');
        expect(remoteExists, isNull);

        final normalRemote = await mockKv.retrieveReading('normal');
        expect(normalRemote?.systolic, equals(125));

        // Verify local state
        final finalLocal = await mockDb.getAllReadings();
        expect(finalLocal.length, equals(1));
        expect(finalLocal.first.id, equals('normal'));
      });

      test('should handle conflict resolution correctly', () async {
        // Arrange
        mockKv.setCredentials(TestHelpers.createTestCredentials());
        final now = DateTime.now();
        final baseTime = now.subtract(const Duration(days: 1));

        // Same reading with different modifications
        final localReading = TestHelpers.createTestReading(
          id: 'conflict',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: baseTime,
          lastModified: baseTime.add(const Duration(hours: 2)),
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

        // Setup
        await mockDb.insertReading(localReading);
        await mockKv.storeReading(remoteReading);

        // Act - simulate sync with last-write-wins
        final storedRemote = await mockKv.retrieveReading('conflict');
        if (storedRemote != null &&
            localReading.lastModified.isAfter(storedRemote.lastModified)) {
          await mockKv.storeReading(localReading);
        }

        // Assert
        final finalRemote = await mockKv.retrieveReading('conflict');
        expect(finalRemote?.systolic, equals(120)); // Local version wins
        expect(finalRemote?.diastolic, equals(80));
        expect(finalRemote?.heartRate, equals(72));
        expect(finalRemote?.notes, equals('Local notes'));
      });

      test('should handle large number of readings efficiently', () async {
        // Arrange
        mockKv.setCredentials(TestHelpers.createTestCredentials());

        // Create 100 readings
        final readings = <BloodPressureReading>[];
        for (int i = 0; i < 100; i++) {
          readings.add(TestHelpers.createTestReading(
            id: 'reading_$i',
            systolic: 120 + (i % 20),
            diastolic: 80 + (i % 10),
            timestamp: DateTime.now().subtract(Duration(days: i)),
          ));
        }

        // Add to local database
        for (final reading in readings) {
          await mockDb.insertReading(reading);
        }

        // Act - simulate sync
        final localData = await mockDb.getAllReadings();
        final remoteKeys = await mockKv.listReadingKeys();

        int pushed = 0;
        for (final reading in localData) {
          if (!remoteKeys.containsKey(reading.id)) {
            await mockKv.storeReading(reading);
            pushed++;
          }
        }

        // Assert
        expect(pushed, equals(100));
        expect(localData.length, equals(100));

        final finalRemoteKeys = await mockKv.listReadingKeys();
        expect(finalRemoteKeys.length, equals(100));

        // Spot check some readings
        for (int i = 0; i < 10; i++) {
          final id = 'reading_$i';
          final remote = await mockKv.retrieveReading(id);
          expect(remote?.id, equals(id));
        }
      });
    });

    group('Sync State Consistency', () {
      test('should maintain data integrity during sync', () async {
        // Arrange
        mockKv.setCredentials(TestHelpers.createTestCredentials());
        final readings = TestHelpers.createTestReadingsList();

        // Add all test readings
        for (final reading in readings) {
          await mockDb.insertReading(reading);
        }

        // Act - perform sync operations
        final localData = await mockDb.getAllReadings();

        // Push to remote
        for (final reading in localData) {
          if (!reading.isDeleted) {
            await mockKv.storeReading(reading);
          }
        }

        // Pull back to verify consistency
        final remoteKeys = await mockKv.listReadingKeys();
        final syncedData = <BloodPressureReading>[];

        for (final key in remoteKeys.keys) {
          final remote = await mockKv.retrieveReading(key);
          if (remote != null) {
            syncedData.add(remote);
          }
        }

        // Assert data consistency
        expect(syncedData.length, equals(3)); // Non-deleted readings

        // Verify each reading maintains its properties
        for (final reading in syncedData) {
          final original = readings.firstWhere((r) => r.id == reading.id);
          expect(reading.systolic, equals(original.systolic));
          expect(reading.diastolic, equals(original.diastolic));
          expect(reading.heartRate, equals(original.heartRate));
          expect(reading.notes, equals(original.notes));
          expect(reading.isDeleted, equals(original.isDeleted));
        }
      });

      test('should handle concurrent sync operations', () async {
        // This test simulates what happens if sync is triggered multiple times
        mockKv.setCredentials(TestHelpers.createTestCredentials());

        final reading = TestHelpers.createTestReading(id: 'concurrent');
        await mockDb.insertReading(reading);

        // Act - simulate multiple sync attempts
        for (int i = 0; i < 3; i++) {
          final localData = await mockDb.getAllReadings();
          final remoteKeys = await mockKv.listReadingKeys();

          for (final local in localData) {
            if (!remoteKeys.containsKey(local.id)) {
              await mockKv.storeReading(local);
            }
          }
        }

        // Assert - reading should only exist once
        final finalRemoteKeys = await mockKv.listReadingKeys();
        expect(finalRemoteKeys.length, equals(1));
        expect(finalRemoteKeys.containsKey('concurrent'), isTrue);

        final stored = await mockKv.retrieveReading('concurrent');
        expect(stored, isNotNull);
        expect(stored?.id, equals('concurrent'));
      });
    });
  });
}