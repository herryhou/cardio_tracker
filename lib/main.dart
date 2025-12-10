import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/blood_pressure_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'app.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CardioTrackerApp());
}

class CardioTrackerApp extends StatelessWidget {
  const CardioTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BloodPressureProvider(
            databaseService: DatabaseService.instance,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(
            databaseService: DatabaseService.instance,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Cardio Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const App(),
          );
        },
      ),
    );
  }
}
