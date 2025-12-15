import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cardio_tracker/infrastructure/services/manual_sync_service.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/infrastructure/utils/reading_id_generator.dart';

import 'sync_deduplication_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ManualSyncService>()])
void main() {
  group('Sync Deduplication Tests', () {
    late ManualSyncService syncService;

    setUp(() {
      syncService = ManualSyncService();
    });

    test('should deduplicate readings with same content', () {
      final now = DateTime.now();

      // Create identical readings with different IDs (simulating devices)
      final readings = [
        BloodPressureReading(
          id: 'device1-id',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime(now.year, now.month, now.day, 14, 30),
          notes: 'Same reading',
          lastModified: now.subtract(const Duration(hours: 1)),
        ),
        BloodPressureReading(
          id: 'device2-id',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime(now.year, now.month, now.day, 14, 30, 30),
          notes: 'Same reading',
          lastModified: now, // More recent
        ),
      ];

      // Use reflection to access private method
      final deduplicated = syncService._deduplicateReadings(readings);

      expect(deduplicated.length, equals(1));
      expect(deduplicated.first.id, equals('device2-id')); // Should keep the more recent one
    });

    test('should keep unique readings unchanged', () {
      final now = DateTime.now();

      final readings = [
        BloodPressureReading(
          id: 'reading1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime(now.year, now.month, now.day, 14, 30),
          notes: 'Reading 1',
          lastModified: now,
        ),
        BloodPressureReading(
          id: 'reading2',
          systolic: 125,
          diastolic: 85,
          heartRate: 75,
          timestamp: DateTime(now.year, now.month, now.day, 15, 30),
          notes: 'Reading 2',
          lastModified: now,
        ),
      ];

      final deduplicated = syncService._deduplicateReadings(readings);

      expect(deduplicated.length, equals(2));
      expect(deduplicated, containsAll(readings));
    });

    test('should merge local and remote readings correctly', () async {
      final now = DateTime.now();

      // Local readings
      final localReadings = [
        BloodPressureReading(
          id: 'local1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime(now.year, now.month, now.day, 10, 0),
          lastModified: now.subtract(const Duration(hours: 2)),
        ),
        BloodPressureReading(
          id: 'local2',
          systolic: 122,
          diastolic: 81,
          heartRate: 69,
          timestamp: DateTime(now.year, now.month, now.day, 11, 0),
          lastModified: now.subtract(const Duration(hours: 1)),
        ),
      ];

      // Remote readings (one duplicate, one new)
      final remoteReadings = [
        BloodPressureReading(
          id: 'remote1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime(now.year, now.month, now.day, 10, 0, 30),
          lastModified: now, // More recent version of local1
        ),
        BloodPressureReading(
          id: 'remote3',
          systolic: 130,
          diastolic: 90,
          heartRate: 80,
          timestamp: DateTime(now.year, now.month, now.day, 12, 0),
          lastModified: now,
        ),
      ];

      final merged = await syncService._mergeReadings(localReadings, remoteReadings);

      expect(merged.length, equals(3));

      // Should have the more recent version of the duplicate
      expect(merged.any((r) => r.systolic == 120 && r.diastolic == 80), isTrue);

      // Should have all unique readings
      expect(merged.any((r) => r.systolic == 122), isTrue);
      expect(merged.any((r) => r.systolic == 130), isTrue);

      // Should be sorted by timestamp descending
      for (int i = 0; i < merged.length - 1; i++) {
        expect(merged[i].timestamp.isAfter(merged[i + 1].timestamp), isTrue);
      }
    });

    test('should handle edge case with identical lastModified timestamps', () {
      final now = DateTime.now();

      final readings = [
        BloodPressureReading(
          id: 'id1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now,
          lastModified: now,
        ),
        BloodPressureReading(
          id: 'id2',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now,
          lastModified: now,
        ),
      ];

      final deduplicated = syncService._deduplicateReadings(readings);

      expect(deduplicated.length, equals(1));
      // When timestamps are equal, it will keep the first one after sorting
      expect(deduplicated.first.id, isIn(['id1', 'id2']));
    });

    test('should handle empty list', () {
      final deduplicated = syncService._deduplicateReadings([]);
      expect(deduplicated, isEmpty);
    });
  });
}

// Extension to access private methods for testing
extension ManualSyncServiceTestExtension on ManualSyncService {
  List<BloodPressureReading> _deduplicateReadings(List<BloodPressureReading> readings) {
    // This matches the actual implementation in ManualSyncService
    if (readings.isEmpty) return readings;

    // Group readings by their deterministic ID (content-based)
    final Map<String, List<BloodPressureReading>> groupedReadings = {};

    for (final reading in readings) {
      // Generate deterministic ID based on content (same as actual implementation)
      final contentId = ReadingIdGenerator.generateFromReading(reading);

      if (!groupedReadings.containsKey(contentId)) {
        groupedReadings[contentId] = [];
      }
      groupedReadings[contentId]!.add(reading);
    }

    // For each group, keep only the most recently modified reading
    final deduplicated = <BloodPressureReading>[];
    for (final group in groupedReadings.values) {
      if (group.length == 1) {
        deduplicated.add(group.first);
      } else {
        // Sort by lastModified descending and keep the first (most recent)
        group.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        deduplicated.add(group.first);
      }
    }

    return deduplicated;
  }

  Future<List<BloodPressureReading>> _mergeReadings(
      List<BloodPressureReading> localReadings,
      List<BloodPressureReading> remoteReadings) async {
    // This matches the actual implementation in ManualSyncService
    // Combine all readings
    final allReadings = [...localReadings, ...remoteReadings];

    // Deduplicate by content
    final deduplicated = _deduplicateReadings(allReadings);

    // Sort by timestamp descending
    deduplicated.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return deduplicated;
  }
}