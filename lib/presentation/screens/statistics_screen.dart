import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../widgets/neumorphic_container.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BloodPressureProvider>();
    final readings = provider.readings;

    if (readings.isEmpty) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Statistics'),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
        ),
        body: Center(
          child: NeumorphicContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Data Available',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start adding readings to see your statistics',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = _calculateStatistics(readings);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Statistics'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Overview Card
          _buildOverviewCard(context, stats),
          const SizedBox(height: 24),

          // Blood Pressure Statistics
          _buildSectionHeader(context, 'Blood Pressure'),
          const SizedBox(height: 8),
          _buildBPStats(context, stats),
          const SizedBox(height: 24),

          // Heart Rate Statistics
          _buildSectionHeader(context, 'Heart Rate'),
          const SizedBox(height: 8),
          _buildHeartRateStats(context, stats),
          const SizedBox(height: 24),

          // Trends
          _buildSectionHeader(context, 'Reading Frequency'),
          const SizedBox(height: 8),
          _buildFrequencyStats(context, stats),
          const SizedBox(height: 24),

          // Category Distribution
          _buildSectionHeader(context, 'BP Category Distribution'),
          const SizedBox(height: 8),
          _buildCategoryDistribution(context, stats),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, ReadingStatistics stats) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Total',
                  '${stats.totalReadings}',
                  Icons.format_list_numbered,
                ),
                _buildStatItem(
                  context,
                  'Days',
                  '${stats.totalDays}',
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  context,
                  'Avg/Day',
                  '${stats.averagePerDay}',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBPStats(BuildContext context, ReadingStatistics stats) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Average Readings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBPStat(
                  context,
                  'Systolic',
                  '${stats.averageSystolic}',
                  'mmHg',
                  Colors.red[400]!,
                ),
                _buildBPStat(
                  context,
                  'Diastolic',
                  '${stats.averageDiastolic}',
                  'mmHg',
                  Colors.blue[400]!,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBPStat(
                  context,
                  'Min',
                  '${stats.minSystolic}/${stats.minDiastolic}',
                  'mmHg',
                  Colors.green[400]!,
                ),
                _buildBPStat(
                  context,
                  'Max',
                  '${stats.maxSystolic}/${stats.maxDiastolic}',
                  'mmHg',
                  Colors.orange[400]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBPStat(BuildContext context, String label, String value, String unit, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeartRateStats(BuildContext context, ReadingStatistics stats) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Colors.pink[400],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Heart Rate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Average',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.averageHeartRate}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[400],
                      ),
                    ),
                    Text(
                      'bpm',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.pink[400],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Min/Max',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.minHeartRate}-${stats.maxHeartRate}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[300],
                      ),
                    ),
                    Text(
                      'bpm',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.pink[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyStats(BuildContext context, ReadingStatistics stats) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Reading History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFrequencyItem(context, 'First Reading', stats.firstReadingDate),
            const SizedBox(height: 12),
            _buildFrequencyItem(context, 'Last Reading', stats.lastReadingDate),
            const SizedBox(height: 12),
            _buildFrequencyItem(context, 'Most Active Day', stats.mostActiveDay),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDistribution(BuildContext context, ReadingStatistics stats) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Blood Pressure Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...stats.categoryDistribution.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryItem(
                  context,
                  entry.key,
                  entry.value,
                  stats.totalReadings,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String category, int count, int total) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    final categoryColor = _getCategoryColor(category);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            Text(
              '$count readings ($percentage%)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'elevated':
        return Colors.yellow[700]!;
      case 'hypertension stage 1':
        return Colors.orange;
      case 'hypertension stage 2':
        return Colors.red;
      case 'hypotension':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  ReadingStatistics _calculateStatistics(List<BloodPressureReading> readings) {
    if (readings.isEmpty) {
      return ReadingStatistics.empty();
    }

    // Create a mutable copy of the list to sort
    final sortedReadings = List<BloodPressureReading>.from(readings);
    sortedReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final totalSystolic = sortedReadings.fold<int>(0, (sum, r) => sum + r.systolic);
    final totalDiastolic = sortedReadings.fold<int>(0, (sum, r) => sum + r.diastolic);
    final readingsWithHR = sortedReadings.where((r) => r.heartRate > 0).toList();
    final totalHeartRate = readingsWithHR.fold<int>(0, (sum, r) => sum + r.heartRate);

    final averageSystolic = (totalSystolic / sortedReadings.length).round();
    final averageDiastolic = (totalDiastolic / sortedReadings.length).round();
    final averageHeartRate = readingsWithHR.isNotEmpty
        ? (totalHeartRate / readingsWithHR.length).round()
        : 0;

    final minSystolic = sortedReadings.map((r) => r.systolic).reduce((a, b) => a < b ? a : b);
    final maxSystolic = sortedReadings.map((r) => r.systolic).reduce((a, b) => a > b ? a : b);
    final minDiastolic = sortedReadings.map((r) => r.diastolic).reduce((a, b) => a < b ? a : b);
    final maxDiastolic = sortedReadings.map((r) => r.diastolic).reduce((a, b) => a > b ? a : b);

    final minHeartRate = readingsWithHR.isNotEmpty
        ? readingsWithHR.map((r) => r.heartRate).reduce((a, b) => a < b ? a : b)
        : 0;
    final maxHeartRate = readingsWithHR.isNotEmpty
        ? readingsWithHR.map((r) => r.heartRate).reduce((a, b) => a > b ? a : b)
        : 0;

    final firstDate = sortedReadings.first.timestamp;
    final lastDate = sortedReadings.last.timestamp;
    final totalDays = lastDate.difference(firstDate).inDays + 1;
    final averagePerDay = totalDays > 0 ? (sortedReadings.length / totalDays).toStringAsFixed(1) : '0';

    final categoryDistribution = <String, int>{};
    for (final reading in sortedReadings) {
      final category = _getBPCategory(reading.systolic, reading.diastolic);
      categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
    }

    final dayFrequency = <String, int>{};
    for (final reading in readings) {
      final day = reading.timestamp.weekday;
      final dayName = _getDayName(day);
      dayFrequency[dayName] = (dayFrequency[dayName] ?? 0) + 1;
    }
    final mostActiveDay = dayFrequency.entries.isEmpty
        ? 'N/A'
        : dayFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return ReadingStatistics(
      totalReadings: readings.length,
      totalDays: totalDays,
      averagePerDay: averagePerDay,
      averageSystolic: averageSystolic,
      averageDiastolic: averageDiastolic,
      averageHeartRate: averageHeartRate,
      minSystolic: minSystolic,
      maxSystolic: maxSystolic,
      minDiastolic: minDiastolic,
      maxDiastolic: maxDiastolic,
      minHeartRate: minHeartRate,
      maxHeartRate: maxHeartRate,
      firstReadingDate: _formatDate(firstDate),
      lastReadingDate: _formatDate(lastDate),
      mostActiveDay: mostActiveDay,
      categoryDistribution: categoryDistribution,
    );
  }

  String _getBPCategory(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) return 'Hypotension';
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'Hypertension Stage 1';
    if (systolic < 180 || diastolic < 120) return 'Hypertension Stage 2';
    return 'Hypertensive Crisis';
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ReadingStatistics {
  final int totalReadings;
  final int totalDays;
  final String averagePerDay;
  final int averageSystolic;
  final int averageDiastolic;
  final int averageHeartRate;
  final int minSystolic;
  final int maxSystolic;
  final int minDiastolic;
  final int maxDiastolic;
  final int minHeartRate;
  final int maxHeartRate;
  final String firstReadingDate;
  final String lastReadingDate;
  final String mostActiveDay;
  final Map<String, int> categoryDistribution;

  ReadingStatistics({
    required this.totalReadings,
    required this.totalDays,
    required this.averagePerDay,
    required this.averageSystolic,
    required this.averageDiastolic,
    required this.averageHeartRate,
    required this.minSystolic,
    required this.maxSystolic,
    required this.minDiastolic,
    required this.maxDiastolic,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.firstReadingDate,
    required this.lastReadingDate,
    required this.mostActiveDay,
    required this.categoryDistribution,
  });

  factory ReadingStatistics.empty() {
    return ReadingStatistics(
      totalReadings: 0,
      totalDays: 0,
      averagePerDay: '0',
      averageSystolic: 0,
      averageDiastolic: 0,
      averageHeartRate: 0,
      minSystolic: 0,
      maxSystolic: 0,
      minDiastolic: 0,
      maxDiastolic: 0,
      minHeartRate: 0,
      maxHeartRate: 0,
      firstReadingDate: 'N/A',
      lastReadingDate: 'N/A',
      mostActiveDay: 'N/A',
      categoryDistribution: {},
    );
  }
}