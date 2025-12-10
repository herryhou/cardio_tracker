import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardio_tracker/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      themeProvider = ThemeProvider();
    });

    test('should initialize with system theme mode by default', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('should load saved theme mode from preferences', () async {
      // Save dark mode preference
      await prefs.setString('theme_mode', 'dark');

      // Create new provider to test loading
      final newProvider = ThemeProvider();
      await newProvider.loadThemeMode();

      expect(newProvider.themeMode, ThemeMode.dark);
    });

    test('should save theme mode to preferences', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);

      final savedTheme = prefs.getString('theme_mode');
      expect(savedTheme, 'dark');
    });

    test('should notify listeners when theme mode changes', () {
      bool notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      themeProvider.setThemeMode(ThemeMode.dark);

      expect(notified, true);
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('should get correct theme mode string', () {
      expect(themeProvider.getThemeModeString(ThemeMode.light), 'light');
      expect(themeProvider.getThemeModeString(ThemeMode.dark), 'dark');
      expect(themeProvider.getThemeModeString(ThemeMode.system), 'system');
    });

    test('should parse theme mode string correctly', () {
      expect(themeProvider.parseThemeMode('light'), ThemeMode.light);
      expect(themeProvider.parseThemeMode('dark'), ThemeMode.dark);
      expect(themeProvider.parseThemeMode('system'), ThemeMode.system);
      expect(themeProvider.parseThemeMode('invalid'), ThemeMode.system);
    });

    test('should toggle between light and dark themes', () {
      // Start with light theme
      themeProvider.setThemeMode(ThemeMode.light);

      // Toggle to dark
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);

      // Toggle to system
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('should handle system theme toggle correctly', () {
      themeProvider.setThemeMode(ThemeMode.system);

      // First toggle should go to light
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);

      // Second toggle should go to dark
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);

      // Third toggle should go back to system
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.system);
    });
  });
}