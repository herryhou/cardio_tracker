import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/csv_editor_screen.dart';
import '../../presentation/providers/blood_pressure_provider.dart';
import '../../presentation/providers/csv_editor_provider.dart';
import '../../widgets/export_bottom_sheet.dart';
import '../../presentation/screens/statistics_screen.dart';
import '../../presentation/screens/dashboard_content.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../infrastructure/services/csv_export_service.dart';
import '../../infrastructure/services/csv_import_service.dart';
import '../../core/injection/injection.dart';
import '../../core/validators/reading_validator.dart';

class SettingsSections {
  static void navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  static void navigateToCsvEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => CsvEditorProvider(
            getIt<BloodPressureRepository>(),
            CsvExportService(),
            CsvImportService(getIt<ReadingValidator>()),
          ),
          child: const CsvEditorScreen(),
        ),
      ),
    );
  }

  static void showStatistics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StatisticsScreen(),
      ),
    );
  }

  static void showAddReading(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReadingModalSheet(),
    );
  }

  static void showBackupExportOptions(BuildContext context) {
    final provider = context.read<BloodPressureProvider>();
    showExportBottomSheet(context, readings: provider.readings);
  }

  static void showAbout(BuildContext context) {
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