import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/blood_pressure_provider.dart';
import 'cloudflare_settings_screen.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/neumorphic_tile.dart';
import '../../widgets/neumorphic_slider_theme_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),

          NeumorphicContainer(
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
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Theme'),
                      subtitle:
                          Text(_getThemeSubtitle(themeProvider.themeMode)),
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
          ),
          const SizedBox(height: 24),

          // Data Management Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),

          NeumorphicContainer(
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
                  subtitle: const Text('Sync data with Cloudflare KV'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                Consumer<BloodPressureProvider>(
                  builder: (context, provider, child) {
                    return NeumorphicTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: Colors.orange[600],
                      ),
                      title: const Text('Clear All Readings'),
                      subtitle:
                          const Text('Remove all blood pressure readings'),
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
                      subtitle:
                          const Text('Delete all data and recreate database'),
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        _showRebuildDatabaseConfirmation(context, provider);
                      },
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
                    // TODO: Implement about screen
                    HapticFeedback.lightImpact();
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Cardio Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.favorite, size: 48),
      children: [
        const Text(
          'A comprehensive cardiovascular health tracking application for monitoring blood pressure, heart rate, and other vital metrics.',
        ),
      ],
    );
  }

  void _showClearReadingsConfirmation(
      BuildContext context, BloodPressureProvider provider) {
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

  void _showRebuildDatabaseConfirmation(
      BuildContext context, BloodPressureProvider provider) {
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

  void _clearAllReadings(
      BuildContext context, BloodPressureProvider provider) async {
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

  void _rebuildDatabase(
      BuildContext context, BloodPressureProvider provider) async {
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
