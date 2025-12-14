import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings/settings_sections.dart';
import '../../presentation/screens/data_management_screen.dart';
import '../../presentation/screens/statistics_screen.dart';

class MainMenuButton extends StatelessWidget {
  const MainMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.7),
        ),
        tooltip: 'Main Menu',
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          // Settings Section
          const PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings, size: 18),
                SizedBox(width: 12),
                Text('Settings'),
                Spacer(),
                Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),

          // Quick Actions Section
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            enabled: false,
            height: 32,
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),

          PopupMenuItem<String>(
            value: 'view_statistics',
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text('View Statistics'),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'add_reading',
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text('Add Reading'),
              ],
            ),
          ),

          // Data Management Section
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            enabled: false,
            height: 32,
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),

          PopupMenuItem<String>(
            value: 'backup_export',
            child: Row(
              children: [
                Icon(
                  Icons.backup_outlined,
                  size: 18,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 12),
                const Text('Backup & Export'),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'data_management',
            child: Row(
              children: [
                Icon(
                  Icons.storage_outlined,
                  size: 18,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 12),
                const Text('Data Management'),
              ],
            ),
          ),

          // Advanced Section
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            enabled: false,
            height: 32,
            child: Text(
              'Advanced',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),

          PopupMenuItem<String>(
            value: 'csv_editor',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.purple[600],
                ),
                const SizedBox(width: 12),
                const Text('CSV Editor'),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'about',
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                const Text('About'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'settings':
        SettingsSections.navigateToSettings(context);
        break;

      case 'view_statistics':
        SettingsSections.showStatistics(context);
        break;

      case 'add_reading':
        SettingsSections.showAddReading(context);
        break;

      case 'backup_export':
        SettingsSections.showBackupExportOptions(context);
        break;

      case 'data_management':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const DataManagementScreen(),
          ),
        );
        break;

      case 'csv_editor':
        SettingsSections.navigateToCsvEditor(context);
        break;

      case 'about':
        SettingsSections.showAbout(context);
        break;
    }
  }
}