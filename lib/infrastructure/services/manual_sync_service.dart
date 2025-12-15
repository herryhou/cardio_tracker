import '../mappers/blood_pressure_reading_mapper.dart';
import 'cloudflare_kv_service.dart';
import 'package:flutter/foundation.dart';
import '../data_sources/local_database_source.dart';
import '../utils/reading_id_generator.dart';
import '../../domain/entities/blood_pressure_reading.dart';

class SyncResult {
  final int pushed;
  final int pulled;
  final int deleted;
  final String? error;

  const SyncResult({
    this.pushed = 0,
    this.pulled = 0,
    this.deleted = 0,
    this.error,
  });
}

class ManualSyncService {
  final LocalDatabaseSource _dataSource = LocalDatabaseSource();
  final CloudflareKVService _kvService = CloudflareKVService();

  // Expose kvService for external access
  CloudflareKVService get kvService => _kvService;

  Future<SyncResult> performSync() async {
    try {
      debugPrint('SyncService: Starting sync...');

      // Check if Cloudflare KV is configured
      if (!await _kvService.isConfigured()) {
        debugPrint('SyncService: Cloudflare KV not configured');
        return const SyncResult(error: 'Cloudflare KV not configured');
      }

      // Get all local readings
      final localReadingsMap = await _dataSource.getAllReadings();
      final localReadings = localReadingsMap
          .map((map) => BloodPressureReadingMapper.fromJson(map))
          .where((r) => !r.isDeleted) // Filter out deleted readings
          .toList();

      // Get all remote readings
      final remoteKeys = await _kvService.listReadingKeys();
      final remoteReadings = <BloodPressureReading>[];

      for (final readingId in remoteKeys.keys) {
        try {
          final remoteReading = await _kvService.retrieveReading(readingId);
          if (remoteReading != null && !remoteReading.isDeleted) {
            remoteReadings.add(remoteReading);
          }
        } catch (e) {
          print('SyncService: Error retrieving remote reading $readingId: $e');
          continue;
        }
      }

      // Merge and deduplicate readings
      final mergedReadings = await _mergeReadings(localReadings, remoteReadings);

      // Clear local database and insert merged readings
      await _dataSource.clearAllReadings();
      for (final reading in mergedReadings) {
        await _dataSource.insertReading(reading.toJson());
      }

      // Update remote storage with merged readings
      int updated = 0;
      for (final reading in mergedReadings) {
        try {
          await _kvService.storeReading(reading);
          updated++;
        } catch (e) {
          print('SyncService: Error storing reading ${reading.id}: $e');
        }
      }

      debugPrint('SyncService: Sync completed successfully. Updated $updated readings.');

      // Calculate changes for reporting
      final pulled = remoteReadings.length;
      final pushed = localReadings.length;

      return SyncResult(
        pushed: pushed,
        pulled: pulled,
        deleted: 0,
      );
    } catch (e) {
      return SyncResult(error: e.toString());
    }
  }

  // Check if sync is available (credentials configured)
  Future<bool> isSyncAvailable() async {
    return await _kvService.isConfigured();
  }

  /// Deduplicate readings by content, preferring the one with the most recent lastModified timestamp
  /// This is used during sync to prevent duplicate entries from different devices
  List<BloodPressureReading> _deduplicateReadings(
      List<BloodPressureReading> readings) {
    if (readings.isEmpty) return readings;

    // Group readings by their deterministic ID (content-based)
    final Map<String, List<BloodPressureReading>> groupedReadings = {};

    for (final reading in readings) {
      // Generate deterministic ID based on content
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
        debugPrint('SyncService: Deduplicated ${group.length} readings with same content');
      }
    }

    return deduplicated;
  }

  /// Merge local and remote readings with deduplication
  Future<List<BloodPressureReading>> _mergeReadings(
      List<BloodPressureReading> localReadings,
      List<BloodPressureReading> remoteReadings) async {

    // Combine all readings
    final allReadings = [...localReadings, ...remoteReadings];

    // Deduplicate by content
    final deduplicated = _deduplicateReadings(allReadings);

    // Sort by timestamp descending
    deduplicated.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    debugPrint('SyncService: Merged ${localReadings.length} local + ${remoteReadings.length} remote = ${deduplicated.length} unique');

    return deduplicated;
  }
}
