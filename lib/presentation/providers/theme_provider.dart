import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardio_tracker/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeProvider() {
    _loadPreferences();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  // Get the appropriate theme data based on current mode
  ThemeData getThemeData(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
  }

  // Initialize and load preferences
  Future<void> _loadPreferences() async {
    _prefs = _prefs ?? await SharedPreferences.getInstance();
    await loadThemeMode();
  }

  // Load theme mode from preferences
  Future<void> loadThemeMode() async {
    _prefs = _prefs ?? await SharedPreferences.getInstance();

    final savedTheme = _prefs!.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = parseThemeMode(savedTheme);
      notifyListeners();
    }
  }

  // Set theme mode and persist it
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    await _saveThemeMode();
  }

  // Toggle between themes in order: system -> light -> dark -> system
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  // Save theme mode to preferences
  Future<void> _saveThemeMode() async {
    _prefs = _prefs ?? await SharedPreferences.getInstance();
    await _prefs!.setString(_themeKey, getThemeModeString(_themeMode));
  }

  // Helper methods
  String getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode parseThemeMode(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}