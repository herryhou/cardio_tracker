import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';
import '../models/user_settings.dart';
import '../widgets/medical_metric_card.dart';
import '../widgets/reading_summary_card.dart';
import '../widgets/trend_indicator.dart';
import '../theme/app_theme.dart';
import '../services/csv_export_service.dart';
import '../screens/add_reading_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load readings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodPressureProvider>().loadReadings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            onSelected: (value) {
              _handleMenuAction(context, value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export_summary',
                child: Row(
                  children: [
                    Icon(Icons.summarize_outlined),
                    SizedBox(width: 8),
                    Text('Export Summary'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export_month',
                child: Row(
                  children: [
                    Icon(Icons.date_range_outlined),
                    SizedBox(width: 8),
                    Text('Export This Month'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<BloodPressureProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(context, provider.error!);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReadings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Latest Reading Section
                  _buildLatestReadingSection(context, provider.latestReading),
                  const SizedBox(height: 24),

                  // Overview Metrics Section
                  if (provider.readings.isNotEmpty) ...[
                    _buildOverviewMetrics(context, provider),
                    const SizedBox(height: 24),

                    // Recent Readings Section
                    _buildRecentReadingsSection(context, provider.recentReadings),
                  ] else ...[
                    _buildEmptyMetricsSection(context),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReadingModal(context);
        },
        child: const Icon(Icons.add),
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load data',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<BloodPressureProvider>().loadReadings(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestReadingSection(BuildContext context, BloodPressureReading? latestReading) {
    if (latestReading == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.favorite_border,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to Cardio Tracker',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first blood pressure reading to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use bottom navigation to go to Add Reading')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add First Reading'),
              ),
            ],
          ),
        ),
      );
    }

    final categoryColor = _getCategoryColor(context, latestReading.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Reading',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BloodPressureMetricCard(
          systolic: latestReading.systolic,
          diastolic: latestReading.diastolic,
          pulse: latestReading.heartRate,
          category: _getCategoryText(latestReading.category),
          categoryColor: categoryColor,
          timestamp: latestReading.timestamp,
          onTap: () {
            _showReadingDetails(context, latestReading);
          },
        ),
        if (latestReading.notes != null && latestReading.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      latestReading.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOverviewMetrics(BuildContext context, BloodPressureProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Detailed analytics coming soon')),
                );
              },
              icon: Icon(
                Icons.analytics_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'View Analytics',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Main metrics row
        Row(
          children: [
            // Average Systolic
            Expanded(
              child: MedicalMetricCard(
                title: 'Avg Systolic',
                value: provider.averageSystolic.round().toString(),
                unit: 'mmHg',
                icon: Icons.arrow_upward,
                color: Theme.of(context).colorScheme.error,
                showTrend: false,
              ),
            ),
            const SizedBox(width: 12),
            // Average Diastolic
            Expanded(
              child: MedicalMetricCard(
                title: 'Avg Diastolic',
                value: provider.averageDiastolic.round().toString(),
                unit: 'mmHg',
                icon: Icons.arrow_downward,
                color: Theme.of(context).colorScheme.primary,
                showTrend: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            // Average Pulse
            Expanded(
              child: MedicalMetricCard(
                title: 'Avg Pulse',
                value: provider.averageHeartRate.round().toString(),
                unit: 'bpm',
                icon: Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
                showTrend: false,
              ),
            ),
            const SizedBox(width: 12),
            // Total Readings
            Expanded(
              child: MedicalMetricCard(
                title: 'Total Readings',
                value: provider.readings.length.toString(),
                icon: Icons.analytics,
                color: Theme.of(context).colorScheme.tertiary,
                showTrend: false,
              ),
            ),
          ],
        ),

        // Category distribution (if we have enough readings)
        if (provider.readings.length >= 3) ...[
          const SizedBox(height: 16),
          _buildCategoryDistribution(context, provider),
        ],
      ],
    );
  }

  Widget _buildCategoryDistribution(BuildContext context, BloodPressureProvider provider) {
    final categoryCounts = _getCategoryCounts(provider.readings);
    final total = provider.readings.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCategoryItem(context, 'Normal', categoryCounts['normal']!, total, Colors.green),
                _buildCategoryItem(context, 'Elevated', categoryCounts['elevated']!, total, Colors.orange),
                _buildCategoryItem(context, 'High', categoryCounts['high']!, total, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMetricsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No data to analyze yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a few readings to see your health metrics and trends',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReadingsSection(BuildContext context, List<BloodPressureReading> recentReadings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Readings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History view coming soon')),
                );
              },
              child: Text(
                'See All',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (recentReadings.isEmpty)
          _buildEmptyRecentState(context)
        else
          Column(
            children: recentReadings.take(5).map((reading) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CompactReadingCard(
                  reading: reading,
                  onTap: () => _showReadingDetails(context, reading),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyRecentState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No recent readings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Your reading history will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    final provider = context.read<BloodPressureProvider>();

    switch (action) {
      case 'export_csv':
        await _exportCsv(context, provider.readings);
        break;
      case 'export_summary':
        await _exportSummary(context, provider.readings);
        break;
      case 'export_month':
        await _exportMonth(context, provider.readings);
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings coming soon')),
        );
        break;
    }
  }

  Future<void> _exportCsv(BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportToCsv(readings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }

  Future<void> _exportSummary(BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportSummaryStats(readings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Summary exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export summary: $e')),
      );
    }
  }

  Future<void> _exportMonth(BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportCurrentMonth(readings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export monthly data: $e')),
      );
    }
  }

  void _showAddReadingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReadingModalSheet(),
    );
  }

  void _showReadingDetails(BuildContext context, BloodPressureReading reading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReadingDetailsSheet(reading: reading),
    );
  }

  Map<String, int> _getCategoryCounts(List<BloodPressureReading> readings) {
    final counts = <String, int>{
      'normal': 0,
      'elevated': 0,
      'high': 0,
    };

    for (final reading in readings) {
      switch (reading.category) {
        case BloodPressureCategory.normal:
          counts['normal'] = (counts['normal'] ?? 0) + 1;
          break;
        case BloodPressureCategory.elevated:
          counts['elevated'] = (counts['elevated'] ?? 0) + 1;
          break;
        case BloodPressureCategory.stage1:
        case BloodPressureCategory.stage2:
        case BloodPressureCategory.crisis:
          counts['high'] = (counts['high'] ?? 0) + 1;
          break;
        case BloodPressureCategory.low:
          counts['normal'] = (counts['normal'] ?? 0) + 1; // Count low as normal
          break;
      }
    }

    return counts;
  }

  Color _getCategoryColor(BuildContext context, BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return AppTheme.getLowColor(context);
      case BloodPressureCategory.normal:
        return AppTheme.getNormalColor(context);
      case BloodPressureCategory.elevated:
        return AppTheme.getElevatedColor(context);
      case BloodPressureCategory.stage1:
        return AppTheme.getStage1Color(context);
      case BloodPressureCategory.stage2:
        return AppTheme.getStage2Color(context);
      case BloodPressureCategory.crisis:
        return AppTheme.getCrisisColor(context);
    }
  }

  String _getCategoryText(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }
}

/// Modal bottom sheet for reading details
class ReadingDetailsSheet extends StatelessWidget {
  final BloodPressureReading reading;

  const ReadingDetailsSheet({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(context, reading.category);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 24,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reading Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getCategoryText(reading.category),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reading values
              Row(
                children: [
                  Expanded(
                    child: _buildDetailValue(
                      context,
                      'Systolic',
                      '${reading.systolic}',
                      'mmHg',
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailValue(
                      context,
                      'Diastolic',
                      '${reading.diastolic}',
                      'mmHg',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailValue(
                      context,
                      'Pulse',
                      '${reading.heartRate}',
                      'bpm',
                      Colors.pink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Timestamp
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date & Time',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(reading.timestamp),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Notes (if available)
              if (reading.notes != null && reading.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reading.notes!,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit feature coming soon')),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delete feature coming soon')),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailValue(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return AppTheme.getLowColor(context);
      case BloodPressureCategory.normal:
        return AppTheme.getNormalColor(context);
      case BloodPressureCategory.elevated:
        return AppTheme.getElevatedColor(context);
      case BloodPressureCategory.stage1:
        return AppTheme.getStage1Color(context);
      case BloodPressureCategory.stage2:
        return AppTheme.getStage2Color(context);
      case BloodPressureCategory.crisis:
        return AppTheme.getCrisisColor(context);
    }
  }

  String _getCategoryText(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }
}

/// Modal bottom sheet for adding new blood pressure readings
class AddReadingModalSheet extends StatelessWidget {
  const AddReadingModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Reading',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Record your blood pressure and heart rate',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add Reading Screen content
              const AddReadingContent(
                isInModal: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}