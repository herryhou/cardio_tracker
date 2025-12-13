import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
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
}
