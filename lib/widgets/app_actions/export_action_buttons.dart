import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../infrastructure/services/csv_export_service.dart';
import '../../infrastructure/services/csv_import_service.dart';
import '../../presentation/providers/blood_pressure_provider.dart';
import '../../presentation/providers/csv_editor_provider.dart';
import '../../presentation/screens/csv_editor_screen.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/injection/injection.dart';
import '../../core/validators/reading_validator.dart';

class ExportActionButtons extends StatelessWidget {
  const ExportActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.file_download_outlined,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        tooltip: 'Export Data',
        onSelected: (value) => _handleExportAction(context, value),
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'export_all',
            child: Row(
              children: [
                Icon(Icons.file_download, size: 18),
                SizedBox(width: 12),
                Text('Export All Data'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'export_month',
            child: Row(
              children: [
                Icon(Icons.today, size: 18),
                SizedBox(width: 12),
                Text('Export This Month'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'export_summary',
            child: Row(
              children: [
                Icon(Icons.assessment, size: 18),
                SizedBox(width: 12),
                Text('Export Summary'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'edit_all',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: Colors.blue),
                SizedBox(width: 12),
                Text('Edit All Readings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportAction(BuildContext context, String action) async {
    final provider = context.read<BloodPressureProvider>();
    final readings = provider.readings;

    HapticFeedback.lightImpact();

    switch (action) {
      case 'export_all':
        await _exportCsv(context, readings, 'All readings');
        break;
      case 'export_month':
        await _exportMonth(context, readings);
        break;
      case 'export_summary':
        await _exportSummary(context, readings);
        break;
      case 'edit_all':
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
        break;
    }
  }

  Future<void> _exportCsv(BuildContext context,
      List<BloodPressureReading> readings, String description) async {
    try {
      await CsvExportService.exportToCsv(readings);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$description exported successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export $description: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportMonth(
      BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportCurrentMonth(readings);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monthly data exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export monthly data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportSummary(
      BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportSummaryStats(readings);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Summary exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export summary: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
