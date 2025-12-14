import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/neumorphic_tile.dart';
import '../../widgets/neumorphic_button.dart';
import '../../widgets/neumorphic_slider_theme_toggle.dart';
import '../../widgets/settings/settings_sections.dart';
import 'cloudflare_settings_screen.dart';
import 'data_management_screen.dart';

class EnhancedSettingsScreen extends StatelessWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Personalization Section
          _buildSection(context, 'Personalization', [
            _ThemeTile(),
            _buildTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Reminders',
              subtitle: 'Daily reading reminders',
              onTap: () => _showComingSoon(context, 'Reminders'),
            ),
            _buildTile(
              context,
              icon: Icons.straighten,
              title: 'Units',
              subtitle: 'mmHg, kPa',
              onTap: () => _showComingSoon(context, 'Units'),
            ),
          ]),

          const SizedBox(height: 32),

          // Data & Sync Section
          _buildSection(context, 'Data & Sync', [
            _buildTile(
              context,
              icon: Icons.cloud_sync_outlined,
              title: 'Cloudflare Sync',
              subtitle: 'Sync with cloud storage',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CloudflareSettingsScreen(),
                ),
              ),
            ),
            _buildTile(
              context,
              icon: Icons.backup_outlined,
              title: 'Backup & Export',
              subtitle: 'Export your data',
              onTap: () => SettingsSections.showBackupExportOptions(context),
            ),
            _buildTile(
              context,
              icon: Icons.file_download_outlined,
              title: 'Import Data',
              subtitle: 'Restore from backup',
              onTap: () => _showComingSoon(context, 'Import'),
            ),
          ]),

          const SizedBox(height: 32),

          // Data Management Section
          _buildSection(context, 'Data Management', [
            _buildTile(
              context,
              icon: Icons.edit_outlined,
              title: 'View All Readings',
              subtitle: 'Edit in CSV format',
              onTap: () => SettingsSections.navigateToCsvEditor(context),
            ),
            _buildTile(
              context,
              icon: Icons.analytics_outlined,
              title: 'Advanced Analytics',
              subtitle: 'Detailed statistics',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DataManagementScreen(),
                ),
              ),
            ),
            _buildDangerTile(
              context,
              icon: Icons.delete_outline,
              title: 'Clear All Readings',
              subtitle: 'Remove all readings',
              onTap: () => _showClearReadingsWarning(context),
            ),
          ]),

          const SizedBox(height: 32),

          // About Section
          _buildSection(context, 'About', [
            _buildTile(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () => SettingsSections.showAbout(context),
            ),
            _buildTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and tutorials',
              onTap: () => _showComingSoon(context, 'Help'),
            ),
            _buildTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => _showComingSoon(context, 'Privacy'),
            ),
          ]),

          const SizedBox(height: 32),

          // Destructive Actions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Danger Zone',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NeumorphicContainer(
              borderRadius: 16,
              padding: EdgeInsets.zero,
              child: _buildDangerTile(
                context,
                icon: Icons.refresh,
                title: 'Rebuild Database',
                subtitle: 'Delete all data and recreate',
                onTap: () => _showRebuildWarning(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NeumorphicContainer(
            borderRadius: 16,
            padding: EdgeInsets.zero,
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return NeumorphicTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildDangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return NeumorphicTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.error,
      ),
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.error),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.error.withValues(alpha: 0.5),
      ),
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
    );
  }

  Widget _ThemeTile() {
    return Consumer<ThemeProvider>(
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
          ],
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearReadingsWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Readings?'),
        content: const Text(
          'This will permanently delete all your blood pressure readings.\n\n'
          'Your settings and sync configuration will remain intact.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllReadings(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showRebuildWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rebuild Database?'),
        content: const Text(
          '⚠️ WARNING: This will delete ALL data including:\n'
          '• All blood pressure readings\n'
          '• All user settings\n'
          '• Cloudflare sync configuration\n\n'
          'The database will be recreated with a fresh schema.\n\n'
          'This action cannot be undone.\n\n'
          'Only do this if you are experiencing database corruption.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _rebuildDatabase(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Rebuild'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllReadings(BuildContext context) async {
    final provider = context.read<BloodPressureProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Clearing all readings...'),
          ],
        ),
      ),
    );

    try {
      await provider.clearAllReadings();
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All readings cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear readings: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _rebuildDatabase(BuildContext context) async {
    final provider = context.read<BloodPressureProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Rebuilding database...'),
          ],
        ),
      ),
    );

    try {
      await provider.rebuildDatabase();
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database rebuilt successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rebuild database: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
}