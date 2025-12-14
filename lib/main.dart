import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/injection/injection.dart';
import 'domain/repositories/user_settings_repository.dart';
import 'app.dart';
import 'theme/app_theme.dart';
import 'presentation/providers/blood_pressure_provider.dart';
import 'application/use_cases/get_all_readings.dart';
import 'application/use_cases/add_reading.dart';
import 'application/use_cases/update_reading.dart';
import 'application/use_cases/delete_reading.dart';
import 'application/use_cases/get_reading_statistics.dart';
import 'application/use_cases/clear_all_readings.dart';
import 'application/use_cases/rebuild_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const CardioTrackerApp());
}

class CardioTrackerApp extends StatelessWidget {
  const CardioTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // New provider using DI
        ChangeNotifierProvider<BloodPressureProvider>(
          create: (context) => BloodPressureProvider(
            getAllReadings: getIt<GetAllReadings>(),
            addReading: getIt<AddReading>(),
            updateReading: getIt<UpdateReading>(),
            deleteReading: getIt<DeleteReading>(),
            getReadingStatistics: getIt<GetReadingStatistics>(),
            clearAllReadings: getIt<ClearAllReadings>(),
            rebuildDatabase: getIt<RebuildDatabase>(),
          ),
        ),
        // Keep existing providers for now until migration
        // ChangeNotifierProvider(
        //   create: (context) => BloodPressureProvider(
        //     databaseService: DatabaseService.instance,
        //   ),
        // ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        // SettingsProvider using DI
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(
            repository: getIt<UserSettingsRepository>(),
          ),
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
