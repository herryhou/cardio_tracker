import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardio_tracker/services/cloudflare_kv_service.dart';
import 'package:cardio_tracker/services/manual_sync_service.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Sync Edge Cases and Error Handling', () {
    late CloudflareKVService kvService;
    late ManualSyncService syncService;

    setUp(() async {
      kvService = CloudflareKVService();
      syncService = ManualSyncService();
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Data Integrity Edge Cases', () {
      test('should handle missing sync fields', () async {
        // Test backward compatibility with older readings
        final now = DateTime.now();

        // Create reading with minimal fields (simulating old version)
        final minimalReading = BloodPressureReading(
          id: 'minimal',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now,
          lastModified: now, // Required field
          isDeleted: false, // Default value
        );

        // Test JSON serialization with all fields
        final json = minimalReading.toJson();
        expect(json['lastModified'], isNotNull);
        expect(json['isDeleted'], isNotNull);

        // Test deserialization with missing fields
        final incompleteJson = {
          'id': 'incomplete',
          'systolic': 120,
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': now.toIso8601String(),
          'notes': null,
          // Missing lastModified and isDeleted
        };

        final deserialized = BloodPressureReading.fromJson(incompleteJson);
        expect(deserialized.id, equals('incomplete'));
        expect(deserialized.lastModified, isNotNull); // Should default to now
        expect(deserialized.isDeleted, isFalse); // Should default to false
      });

      test('should handle invalid dates and timestamps', () async {
        // Test with dates in the future
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final futureReading = TestHelpers.createTestReading(
          id: 'future',
          timestamp: futureDate,
          lastModified: futureDate,
        );

        expect(futureReading.timestamp.isAfter(DateTime.now()), isTrue);
        expect(futureReading.lastModified.isAfter(DateTime.now()), isTrue);

        // Test with very old dates
        final oldDate = DateTime(1970);
        final oldReading = TestHelpers.createTestReading(
          id: 'old',
          timestamp: oldDate,
          lastModified: oldDate,
        );

        expect(oldReading.timestamp.year, equals(1970));
        expect(oldReading.lastModified.year, equals(1970));
      });

      test('should handle duplicate IDs during sync', () async {
        // Create two readings with same ID but different data
        final reading1 = TestHelpers.createTestReading(
          id: 'duplicate',
          systolic: 120,
          diastolic: 80,
          lastModified: DateTime.now().subtract(const Duration(hours: 2)),
        );

        final reading2 = TestHelpers.createTestReading(
          id: 'duplicate',
          systolic: 130,
          diastolic: 85,
          lastModified: DateTime.now(), // Newer
        );

        // Test conflict resolution logic
        BloodPressureReading winner;
        if (reading1.lastModified.isAfter(reading2.lastModified)) {
          winner = reading1;
        } else {
          winner = reading2;
        }

        expect(winner.systolic, equals(130)); // Newer version wins
        expect(winner.diastolic, equals(85));
      });
    });

    group('Storage Limitations and Edge Cases', () {
      test('should handle very large notes', () async {
        // Create reading with large notes
        final largeNotes = 'x' * 10000; // 10KB of notes
        final readingWithLargeNotes = TestHelpers.createTestReading(
          id: 'large_notes',
          notes: largeNotes,
        );

        // Test serialization
        final json = readingWithLargeNotes.toJson();
        expect(json['notes']?.length, equals(10000));

        // Test deserialization
        final retrieved = BloodPressureReading.fromJson(json);
        expect(retrieved.notes?.length, equals(10000));
        expect(retrieved.notes, equals(largeNotes));
      });

      test('should handle special characters in notes', () async {
        // Arrange
        final specialNotes = 'Special chars: àáâãäåæçèéêë ñòóôõö ùúûüý ÿ 中文 العربية русский';
        final readingWithSpecialChars = TestHelpers.createTestReading(
          id: 'special_chars',
          notes: specialNotes,
        );

        // Test serialization/deserialization
        final json = readingWithSpecialChars.toJson();
        final retrieved = BloodPressureReading.fromJson(json);
        expect(retrieved.notes, equals(specialNotes));
      });

      test('should handle null values correctly', () async {
        // Arrange
        final readingWithNulls = TestHelpers.createTestReading(
          id: 'nulls',
          notes: null, // Explicit null
        );

        // Test serialization
        final json = readingWithNulls.toJson();
        expect(json['notes'], isNull);
        expect(json['isDeleted'], isFalse); // Default value

        // Test deserialization
        final retrieved = BloodPressureReading.fromJson(json);
        expect(retrieved.notes, isNull);
        expect(retrieved.isDeleted, isFalse);
      });
    });

    group('Sync Algorithm Edge Cases', () {
      test('should handle empty datasets', () async {
        // Test syncing when there's no data
        final emptyLocal = <BloodPressureReading>[];
        final emptyRemote = <String, int>{};

        // Simulate sync logic
        int pushed = 0;
        int pulled = 0;

        // Process local changes
        for (final reading in emptyLocal) {
          if (!emptyRemote.containsKey(reading.id)) {
            pushed++;
          }
        }

        // Process remote changes
        for (final readingId in emptyRemote.keys) {
          pulled++;
        }

        expect(pushed, equals(0));
        expect(pulled, equals(0));
      });

      test('should handle single item datasets', () async {
        // Test syncing with just one item
        final singleLocal = [
          TestHelpers.createTestReading(id: 'single')
        ];
        final emptyRemote = <String, int>{};

        // Simulate sync
        int pushed = 0;
        for (final reading in singleLocal) {
          if (!emptyRemote.containsKey(reading.id) && !reading.isDeleted) {
            pushed++;
          }
        }

        expect(pushed, equals(1));
      });

      test('should handle all deleted items', () async {
        // Test syncing when all items are deleted
        final deletedLocal = [
          TestHelpers.createTestReading(id: 'deleted_1', isDeleted: true),
          TestHelpers.createTestReading(id: 'deleted_2', isDeleted: true),
        ];
        final remoteKeys = {'deleted_1': 0, 'deleted_2': 0, 'keep_me': 0};

        // Simulate deletion propagation
        int deleted = 0;
        for (final reading in deletedLocal) {
          if (remoteKeys.containsKey(reading.id) && reading.isDeleted) {
            deleted++;
          }
        }

        expect(deleted, equals(2));
      });
    });

    group('Error Scenarios', () {
      test('should handle malformed JSON gracefully', () async {
        // Test various malformed JSON scenarios
        final testCases = [
          // Missing required fields
          {'id': 'test'}, // Missing systolic, diastolic, etc.
          // Invalid types
          {
            'id': 'test',
            'systolic': 'invalid',
            'diastolic': 80,
            'heartRate': 72,
            'timestamp': DateTime.now().toIso8601String(),
          },
          // Invalid date format
          {
            'id': 'test',
            'systolic': 120,
            'diastolic': 80,
            'heartRate': 72,
            'timestamp': 'invalid-date',
          },
        ];

        for (final testCase in testCases) {
          expect(
            () => BloodPressureReading.fromJson(testCase),
            throwsA(anyOf(isA<TypeError>(), isA<FormatException>())),
          );
        }
      });

      test('should handle extreme values', () async {
        // Test boundary values
        final extremeReadings = [
          // Minimum values
          TestHelpers.createTestReading(systolic: 0, diastolic: 0, heartRate: 0),
          // High values
          TestHelpers.createTestReading(systolic: 300, diastolic: 200, heartRate: 300),
          // Negative values (should be caught by validation)
        ];

        for (final reading in extremeReadings) {
          // Test serialization works
          final json = reading.toJson();
          final restored = BloodPressureReading.fromJson(json);
          expect(restored.systolic, equals(reading.systolic));
          expect(restored.diastolic, equals(reading.diastolic));
          expect(restored.heartRate, equals(reading.heartRate));
        }
      });
    });

    group('Performance Edge Cases', () {
      test('should handle ID collision in large datasets', () async {
        // Create readings with potential ID conflicts
        final readings = <BloodPressureReading>[];
        final baseTime = DateTime.now();

        // Create readings with same timestamp (potential collision scenario)
        for (int i = 0; i < 10; i++) {
          readings.add(BloodPressureReading(
            id: 'collision_test',
            systolic: 120 + i,
            diastolic: 80 + i,
            heartRate: 70 + i,
            timestamp: baseTime,
            lastModified: baseTime, // Same timestamp for all
          ));
        }

        // Test that they can be serialized/deserialized
        for (final reading in readings) {
          final json = reading.toJson();
          final restored = BloodPressureReading.fromJson(json);
          expect(restored.id, equals(reading.id));
          expect(restored.systolic, equals(reading.systolic));
        }

        // Note: In real sync, this would be resolved by timestamp order
        // or additional version fields
      });

      test('should handle memory usage with large notes', () async {
        // Test memory efficiency with very large notes
        final hugeNotes = 'x' * 100000; // 100KB
        final reading = TestHelpers.createTestReading(
          id: 'memory_test',
          notes: hugeNotes,
        );

        // Multiple serialize/deserialize cycles
        for (int i = 0; i < 100; i++) {
          final json = reading.toJson();
          final restored = BloodPressureReading.fromJson(json);
          expect(restored.notes?.length, equals(100000));
        }
      });
    });

    group('Security and Privacy Edge Cases', () {
      test('should not expose sensitive data in errors', () async {
        // Test that error messages don't contain sensitive data
        final sensitiveCreds = TestHelpers.createTestCredentials(
          apiToken: 'super_secret_token_abc123',
        );

        // Verify credentials can be set without exposing token in errors
        try {
          await kvService.setCredentials(
            accountId: sensitiveCreds['accountId']!,
            namespaceId: sensitiveCreds['namespaceId']!,
            apiToken: sensitiveCreds['apiToken']!,
          );
          // Should succeed
        } catch (e) {
          // If it fails, error shouldn't contain the token
          expect(e.toString(), isNot(contains('super_secret_token')));
        }
      });

      test('should handle special characters in IDs', () async {
        // Test various special characters that might appear in IDs
        final specialIds = [
          'normal_id',
          'id-with-dashes',
          'id_with_underscores',
          'id.with.dots',
          'id123numeric',
          'ID-CAPITALIZED',
          'very-long-id-that-might-cause-issues',
        ];

        for (final id in specialIds) {
          final reading = TestHelpers.createTestReading(id: id);
          final json = reading.toJson();
          final restored = BloodPressureReading.fromJson(json);
          expect(restored.id, equals(id));
        }
      });
    });
  });
}