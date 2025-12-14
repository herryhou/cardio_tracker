import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/blood_pressure_provider.dart';
import '../presentation/providers/csv_editor_provider.dart';
import '../domain/entities/blood_pressure_reading.dart';
import '../domain/repositories/blood_pressure_repository.dart';
import '../presentation/screens/csv_editor_screen.dart';
import '../infrastructure/services/csv_export_service.dart';
import '../infrastructure/services/csv_import_service.dart';
import '../core/injection/injection.dart';
import '../core/validators/reading_validator.dart';
import 'neumorphic_container.dart';

/// A subtle status summary card showing key information
class StatusSummaryCard extends StatelessWidget {
  const StatusSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<BloodPressureProvider>(
      builder: (context, provider, child) {
        if (provider.readings.isEmpty) {
          return const SizedBox.shrink();
        }

        final latestReading = provider.latestReading;
        final daysSinceLastReading = latestReading != null
            ? DateTime.now().difference(latestReading.timestamp).inDays
            : null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: NeumorphicContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Stats',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.readings.length} total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
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
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusItem(
                        context,
                        'Last Reading',
                        daysSinceLastReading != null
                            ? '$daysSinceLastReading day${daysSinceLastReading == 1 ? '' : 's'} ago'
                            : 'No readings',
                        Icons.calendar_today,
                        daysSinceLastReading != null && daysSinceLastReading <= 7
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildStatusItem(
                        context,
                        'Average',
                        _getAverageText(provider.readings),
                        Icons.favorite,
                        colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _getAverageText(List<BloodPressureReading> readings) {
    if (readings.isEmpty) return 'N/A';

    final totalSystolic = readings.fold<int>(0, (sum, r) => sum + r.systolic);
    final totalDiastolic = readings.fold<int>(0, (sum, r) => sum + r.diastolic);
    final avgSystolic = (totalSystolic / readings.length).round();
    final avgDiastolic = (totalDiastolic / readings.length).round();

    return '$avgSystolic/$avgDiastolic';
  }
}