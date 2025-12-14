import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/neumorphic_tile.dart';
import '../../widgets/neumorphic_button.dart';
import '../../infrastructure/services/csv_export_service.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import 'cloudflare_settings_screen.dart';
import '../providers/theme_provider.dart';
import '../../widgets/settings/settings_sections.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BloodPressureProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Data Management'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sync Status Card
          _buildSyncStatusCard(context),
          const SizedBox(height: 24),

          // Cloudflare Configuration
          _buildSectionHeader(context, 'Cloudflare Configuration'),
          const SizedBox(height: 8),
          _buildCloudflareConfig(context),
          const SizedBox(height: 24),

          // Export Options
          _buildSectionHeader(context, 'Export Options'),
          const SizedBox(height: 8),
          _buildExportOptions(context, provider.readings),
          const SizedBox(height: 24),

          // Storage Information
          _buildSectionHeader(context, 'Storage Information'),
          const SizedBox(height: 8),
          _buildStorageInfo(context, provider.readings),
          const SizedBox(height: 24),

          // Data Operations
          _buildSectionHeader(context, 'Data Operations'),
          const SizedBox(height: 8),
          _buildDataOperations(context, provider),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<BloodPressureProvider>(
      builder: (context, provider, child) {
        return NeumorphicContainer(
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_sync,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cloud Sync Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Sync: ${provider.readings.isNotEmpty ? 'Never synced' : 'No data to sync'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Readings: ${provider.readings.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloudflareConfig(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          NeumorphicTile(
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Configure Cloudflare Sync'),
            subtitle: const Text('Set up Cloudflare KV for data sync'),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CloudflareSettingsScreen(),
                ),
              );
            },
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          NeumorphicTile(
            leading: Icon(
              Icons.update,
              color: Colors.blue[600],
            ),
            title: const Text('Update Credentials'),
            subtitle: const Text('Update existing Cloudflare credentials'),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CloudflareSettingsScreen(
                    updateMode: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions(BuildContext context, List<BloodPressureReading> readings) {
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          NeumorphicTile(
            leading: Icon(
              Icons.file_download,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Export All Data'),
            subtitle: const Text('Export complete readings as CSV'),
            onTap: () => _exportAll(context, readings),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          NeumorphicTile(
            leading: Icon(
              Icons.analytics,
              color: Colors.purple[600],
            ),
            title: const Text('Export Summary'),
            subtitle: const Text('Export statistics and averages'),
            onTap: () => _exportSummary(context, readings),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          NeumorphicTile(
            leading: Icon(
              Icons.today,
              color: Colors.green[600],
            ),
            title: const Text('Export This Month'),
            subtitle: const Text('Export current month readings'),
            onTap: () => _exportMonth(context, readings),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          NeumorphicTile(
            leading: Icon(
              Icons.edit,
              color: Colors.orange[600],
            ),
            title: const Text('Edit All Readings'),
            subtitle: const Text('Edit readings in CSV format'),
            onTap: () {
              SettingsSections.navigateToCsvEditor(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(BuildContext context, List<BloodPressureReading> readings) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Local Storage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Readings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${readings.length}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Database Size',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '~${(readings.length * 0.2).toStringAsFixed(1)} KB',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataOperations(BuildContext context, BloodPressureProvider provider) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          NeumorphicTile(
            leading: Icon(
              Icons.refresh,
              color: Colors.blue[600],
            ),
            title: const Text('Refresh Data'),
            subtitle: const Text('Reload all readings from database'),
            onTap: () {
              provider.loadReadings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data refreshed'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          NeumorphicTile(
            leading: Icon(
              Icons.delete_outline,
              color: Colors.orange[600],
            ),
            title: const Text('Clear All Readings'),
            subtitle: const Text('Remove all readings (keep settings)'),
            onTap: () {
              _showClearConfirmDialog(context, provider);
            },
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          NeumorphicTile(
            leading: Icon(
              Icons.restore,
              color: Colors.red[600],
            ),
            title: const Text('Rebuild Database'),
            subtitle: const Text('Delete all data and recreate'),
            onTap: () {
              _showRebuildConfirmDialog(context, provider);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportAll(BuildContext context, List<BloodPressureReading> readings) async {
    HapticFeedback.lightImpact();
    try {
      await CsvExportService.exportToCsv(readings);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportSummary(BuildContext context, List<BloodPressureReading> readings) async {
    HapticFeedback.lightImpact();
    try {
      await CsvExportService.exportSummaryStats(readings);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Summary exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportMonth(BuildContext context, List<BloodPressureReading> readings) async {
    HapticFeedback.lightImpact();
    try {
      await CsvExportService.exportCurrentMonth(readings);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monthly data exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showClearConfirmDialog(BuildContext context, BloodPressureProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Readings?'),
        content: const Text(
          'This will permanently delete all blood pressure readings.\n\n'
          'Your settings and sync configuration will remain intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.clearAllReadings();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All readings cleared'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showRebuildConfirmDialog(BuildContext context, BloodPressureProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rebuild Database?'),
        content: const Text(
          '⚠️ WARNING: This will delete ALL data including:\n\n'
          '• All blood pressure readings\n'
          '• All user settings\n'
          '• Cloudflare sync configuration\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.rebuildDatabase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database rebuilt successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to rebuild: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rebuild'),
          ),
        ],
      ),
    );
  }
}