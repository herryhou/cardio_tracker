import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../infrastructure/services/manual_sync_service.dart';
import '../../presentation/screens/cloudflare_settings_screen.dart';
import '../../presentation/providers/blood_pressure_provider.dart';

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  final ManualSyncService _syncService = ManualSyncService();
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _syncService.isSyncAvailable(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 44,
            height: 44,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // Error or not available
        if (snapshot.hasError || !snapshot.hasData || snapshot.data != true) {
          return const SizedBox.shrink();
        }

        // Sync available - show status indicator
        return Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.cloud_sync_outlined,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
            tooltip: 'Cloudflare Sync',
            onSelected: (value) => _handleSyncAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'sync_now',
                child: Row(
                  children: [
                    Icon(
                      _isSyncing ? Icons.sync : Icons.cloud_upload,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'configure',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 12),
                    Text('Configuration'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'update_credentials',
                child: Row(
                  children: [
                    Icon(Icons.key, size: 18),
                    SizedBox(width: 12),
                    Text('Update Credentials'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'clear_sync_data',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 18, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Clear Sync Data'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSyncAction(BuildContext context, String action) async {
    switch (action) {
      case 'sync_now':
        await _performSync(context);
        break;
      case 'configure':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CloudflareSettingsScreen(),
          ),
        );
        break;
      case 'update_credentials':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CloudflareSettingsScreen(
              updateMode: true,
            ),
          ),
        );
        break;
      case 'clear_sync_data':
        await _clearSyncData(context);
        break;
    }
  }

  Future<void> _performSync(BuildContext context) async {
    if (_isSyncing) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSyncing = true);

    try {
      final result = await _syncService.performSync();

      if (mounted) {
        if (result.error != null) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${result.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sync complete: ${result.pushed} pushed, ${result.pulled} pulled',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Refresh data
          context.read<BloodPressureProvider>().loadReadings();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _clearSyncData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Data?'),
        content: const Text(
          'This will remove all Cloudflare sync configuration and stored sync data from your device.\n\n'
          'Your local readings will NOT be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final kvService = _syncService.kvService;
        await kvService.clearCredentials();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sync data cleared'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear sync data: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
