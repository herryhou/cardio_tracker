import 'database_service.dart';
import 'cloudflare_kv_service.dart';
import 'package:flutter/foundation.dart';

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
  final DatabaseService _databaseService = DatabaseService.instance;
  final CloudflareKVService _kvService = CloudflareKVService();

  Future<SyncResult> performSync() async {
    try {
      debugPrint('SyncService: Starting sync...');

      // Check if Cloudflare KV is configured
      if (!await _kvService.isConfigured()) {
        debugPrint('SyncService: Cloudflare KV not configured');
        return const SyncResult(error: 'Cloudflare KV not configured');
      }

      // Get all local readings
      final localReadings = await _databaseService.getAllReadings();

      // Get all remote keys
      final remoteKeys = await _kvService.listReadingKeys();

      // Create maps for easy comparison
      final localMap = {for (var r in localReadings) r.id: r};
      final remoteSet = remoteKeys.keys.toSet();

      int pushed = 0;
      int pulled = 0;
      int deleted = 0;

      // Process local changes (push to remote)
      for (final localReading in localReadings) {
        try {
          final remoteHas = remoteSet.contains(localReading.id);

          if (localReading.isDeleted) {
            // Local deletion - push to remote
            if (remoteHas) {
              await _kvService.deleteReading(localReading.id);
              deleted++;
            }
          } else if (!remoteHas) {
            // New reading - push to remote
            await _kvService.storeReading(localReading);
            pushed++;
          } else {
            // Check if local is newer
            try {
              final remoteReading = await _kvService.retrieveReading(localReading.id);
              if (remoteReading != null &&
                  localReading.lastModified.isAfter(remoteReading.lastModified)) {
                await _kvService.storeReading(localReading);
                pushed++;
              }
            } catch (e) {
              print('SyncService: Error checking remote reading ${localReading.id}: $e');
              // If we can't retrieve the remote version, we'll skip this reading
              continue;
            }
          }
        } catch (e) {
          print('SyncService: Error processing local reading ${localReading.id}: $e');
          // Continue with next reading
          continue;
        }
      }

      // Process remote changes (pull to local)
      for (final readingId in remoteKeys.keys) {
        try {
          if (!localMap.containsKey(readingId)) {
            // Reading exists remotely but not locally
            final remoteReading = await _kvService.retrieveReading(readingId);
            if (remoteReading != null && !remoteReading.isDeleted) {
              await _databaseService.insertReading(remoteReading);
              pulled++;
            }
          }
        } catch (e) {
          print('SyncService: Error processing remote reading $readingId: $e');
          // Continue with next reading
          continue;
        }
      }

      // Clean up locally deleted readings
      final deletedReadings = localReadings.where((r) => r.isDeleted).toList();
      for (final deletedReading in deletedReadings) {
        await _databaseService.deleteReading(deletedReading.id);
      }

      return SyncResult(
        pushed: pushed,
        pulled: pulled,
        deleted: deleted,
      );

    } catch (e) {
      return SyncResult(error: e.toString());
    }
  }

  // Check if sync is available (credentials configured)
  Future<bool> isSyncAvailable() async {
    return await _kvService.isConfigured();
  }
}