import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/neumorphic_tile.dart';
import '../../widgets/neumorphic_slider_theme_toggle.dart';
import '../../widgets/settings/settings_sections.dart';
import 'data_management_screen.dart';

class ReorganizedSettingsScreen extends StatelessWidget {
  const ReorganizedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildAppearanceSection(context),
          const SizedBox(height: 24),

          // Data & Sync Section
          _buildSectionHeader(context, 'Data & Sync'),
          const SizedBox(height: 8),
          _buildDataSyncSection(context),
          const SizedBox(height: 24),

          // Storage & Backup Section
          _buildSectionHeader(context, 'Storage & Backup'),
          const SizedBox(height: 8),
          _buildStorageBackupSection(context),
          const SizedBox(height: 24),

          // Advanced Section
          _buildSectionHeader(context, 'Advanced'),
          const SizedBox(height: 8),
          _buildAdvancedSection(context),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          _buildAboutSection(context),
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

  Widget _buildAppearanceSection(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Column(
            children: [
              NeumorphicTile(
                leading: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : themeProvider.themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Theme'),
                subtitle: Text(_getThemeSubtitle(themeProvider.themeMode)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: NeumorphicSliderThemeToggle(
                  value: _getThemeValue(themeProvider.themeMode),
                  onChanged: (value) {
                    final newTheme = _getThemeFromValue(value);
                    HapticFeedback.lightImpact();
                    themeProvider.setThemeMode(newTheme);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataSyncSection(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          NeumorphicTile(
            leading: Icon(
              Icons.cloud_sync,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Cloudflare Sync'),
            subtitle: const Text('Configure and manage cloud sync'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DataManagementScreen(),
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
              Icons.analytics_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Statistics'),
            subtitle: const Text('View health data analytics'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              SettingsSections.showStatistics(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBackupSection(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          NeumorphicTile(
            leading: Icon(
              Icons.backup_outlined,
              color: Colors.blue[600],
            ),
            title: const Text('Backup & Export'),
            subtitle: const Text('Export data in various formats'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              SettingsSections.showBackupExportOptions(context);
            },
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          NeumorphicTile(
            leading: Icon(
              Icons.edit_outlined,
              color: Colors.blue[600],
            ),
            title: const Text('CSV Editor'),
            subtitle: const Text('Edit readings in CSV format'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              SettingsSections.navigateToCsvEditor(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Consumer<BloodPressureProvider>(
            builder: (context, provider, child) {
              return NeumorphicTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Colors.orange[600],
                ),
                title: const Text('Clear All Readings'),
                subtitle: const Text('Remove all blood pressure readings'),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showClearReadingsConfirmation(context, provider);
                },
              );
            },
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Consumer<BloodPressureProvider>(
            builder: (context, provider, child) {
              return NeumorphicTile(
                leading: Icon(
                  Icons.restore,
                  color: Colors.red[600],
                ),
                title: const Text('Rebuild Database'),
                subtitle: const Text('Delete all data and recreate database'),
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _showRebuildDatabaseConfirmation(context, provider);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: NeumorphicTile(
        leading: Icon(
          Icons.info_outline,
          color: theme.colorScheme.primary,
        ),
        title: const Text('About'),
        subtitle: const Text('App version and information'),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          SettingsSections.showAbout(context);
        },
      ),
    );
  }

  String _getThemeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system setting';
      case ThemeMode.light:
        return 'Always light mode';
      case ThemeMode.dark:
        return 'Always dark mode';
    }
  }

  double _getThemeValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }

  ThemeMode _getThemeFromValue(double value) {
    switch (value.round()) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _showClearReadingsConfirmation(BuildContext context, BloodPressureProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Readings?'),
          content: const Text(
            'This will permanently delete all your blood pressure readings. This action cannot be undone.\n\n'
            'Your settings will remain intact.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllReadings(context, provider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showRebuildDatabaseConfirmation(BuildContext context, BloodPressureProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rebuild Database?'),
          content: const Text(
            '⚠️ WARNING: This is a drastic action!\n\n'
            'This will delete ALL data including:\n'
            '• All blood pressure readings\n'
            '• All user settings\n'
            '• Cloudflare sync configurations\n\n'
            'The database will be recreated with a fresh schema. This action cannot be undone.\n\n'
            'Only do this if you are experiencing database corruption or sync issues.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rebuildDatabase(context, provider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Rebuild'),
            ),
          ],
        );
      },
    );
  }

  void _clearAllReadings(BuildContext context, BloodPressureProvider provider) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Clearing all readings...'),
            ],
          ),
        );
      },
    );

    try {
      await provider.clearAllReadings();
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All readings cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear readings: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rebuildDatabase(BuildContext context, BloodPressureProvider provider) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Rebuilding database...'),
            ],
          ),
        );
      },
    );

    try {
      await provider.rebuildDatabase();
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database rebuilt successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to rebuild database: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}