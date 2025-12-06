import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/blood_pressure_reading.dart';

/// Time range options for chart data aggregation
enum TimeRange {
  day,
  week,
  month,
  year,
}

/// Extended time range with season option
enum ExtendedTimeRange {
  day,
  week,
  month,
  season,
  year,
}

/// Time series data model with aggregation support
class TimeSeriesData {
  final DateTime timestamp;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final String? notes;
  final BloodPressureCategory category;
  final List<BloodPressureReading> originalReadings;

  // Performance optimization: Static cache for aggregated data
  static final Map<String, List<TimeSeriesData>> _aggregationCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  const TimeSeriesData({
    required this.timestamp,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.notes,
    required this.category,
    this.originalReadings = const [],
  });

  /// Create TimeSeriesData from a single reading
  factory TimeSeriesData.fromReading(BloodPressureReading reading) {
    return TimeSeriesData(
      timestamp: reading.timestamp,
      systolic: reading.systolic,
      diastolic: reading.diastolic,
      heartRate: reading.heartRate,
      notes: reading.notes,
      category: reading.category,
      originalReadings: [reading],
    );
  }

  /// Aggregate readings by day (returns average for multiple readings on same day)
  static List<TimeSeriesData> aggregateByDay(List<BloodPressureReading> readings) {
    // Performance optimization: Check cache first
    final cacheKey = 'day_${readings.length}_${readings.first.timestamp.millisecondsSinceEpoch}_${readings.last.timestamp.millisecondsSinceEpoch}';

    if (_aggregationCache.containsKey(cacheKey)) {
      return _aggregationCache[cacheKey]!;
    }

    // Clear old cache entries periodically
    _clearExpiredCache();

    final Map<String, List<BloodPressureReading>> dayGroups = {};

    for (final reading in readings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(reading.timestamp);
      dayGroups.putIfAbsent(dateKey, () => []).add(reading);
    }

    final aggregatedData = <TimeSeriesData>[];
    for (final entry in dayGroups.entries) {
      final dayReadings = entry.value;

      if (dayReadings.isEmpty) continue;

      // Calculate averages
      final avgSystolic = dayReadings
          .map((r) => r.systolic)
          .reduce((a, b) => a + b) ~/ dayReadings.length;
      final avgDiastolic = dayReadings
          .map((r) => r.diastolic)
          .reduce((a, b) => a + b) ~/ dayReadings.length;

      final avgHeartRate = dayReadings
          .where((r) => r.heartRate != null)
          .map((r) => r.heartRate!)
          .isNotEmpty
          ? dayReadings
              .where((r) => r.heartRate != null)
              .map((r) => r.heartRate!)
              .reduce((a, b) => a + b) ~/
              dayReadings.where((r) => r.heartRate != null).length
          : null;

      // Use most common category for aggregated data
      final categoryCounts = <BloodPressureCategory, int>{};
      for (final reading in dayReadings) {
        categoryCounts[reading.category] = (categoryCounts[reading.category] ?? 0) + 1;
      }
      final dominantCategory = categoryCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      // Get first reading's timestamp and notes
      final firstReading = dayReadings.first;
      final allNotes = dayReadings
          .where((r) => r.notes?.isNotEmpty ?? false)
          .map((r) => r.notes!)
          .where((notes) => notes.trim().isNotEmpty)
          .toList();

      aggregatedData.add(TimeSeriesData(
        timestamp: DateTime(
          firstReading.timestamp.year,
          firstReading.timestamp.month,
          firstReading.timestamp.day,
          12, // Noon for better chart positioning
        ),
        systolic: avgSystolic,
        diastolic: avgDiastolic,
        heartRate: avgHeartRate,
        notes: allNotes.isNotEmpty ? allNotes.join('; ') : null,
        category: dominantCategory,
        originalReadings: dayReadings,
      ));
    }

    final sortedData = aggregatedData..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Cache the result
    _aggregationCache[cacheKey] = sortedData;

    return sortedData;
  }

  // Performance optimization: Clear expired cache entries
  static void _clearExpiredCache() {
    _aggregationCache.removeWhere((key, value) => _aggregationCache.length > 20);
  }

  /// Aggregate readings by week
  static List<TimeSeriesData> aggregateByWeek(List<BloodPressureReading> readings) {
    final dailyData = aggregateByDay(readings);
    final Map<int, List<TimeSeriesData>> weekGroups = {};

    for (final data in dailyData) {
      final weekNumber = _getWeekNumber(data.timestamp);
      weekGroups.putIfAbsent(weekNumber, () => []).add(data);
    }

    final aggregatedData = <TimeSeriesData>[];
    for (final entry in weekGroups.entries) {
      final weekReadings = entry.value;

      if (weekReadings.isEmpty) continue;

      final avgSystolic = weekReadings
          .map((r) => r.systolic)
          .reduce((a, b) => a + b) ~/ weekReadings.length;
      final avgDiastolic = weekReadings
          .map((r) => r.diastolic)
          .reduce((a, b) => a + b) ~/ weekReadings.length;

      final avgHeartRate = weekReadings
          .where((r) => r.heartRate != null)
          .map((r) => r.heartRate!)
          .isNotEmpty
          ? weekReadings
              .where((r) => r.heartRate != null)
              .map((r) => r.heartRate!)
              .reduce((a, b) => a + b) ~/
              weekReadings.where((r) => r.heartRate != null).length
          : null;

      final firstData = weekReadings.first;
      aggregatedData.add(TimeSeriesData(
        timestamp: firstData.timestamp, // Use first day's timestamp
        systolic: avgSystolic,
        diastolic: avgDiastolic,
        heartRate: avgHeartRate,
        notes: 'Weekly average',
        category: firstData.category,
        originalReadings: weekReadings.expand((d) => d.originalReadings).toList(),
      ));
    }

    return aggregatedData..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Aggregate readings by month
  static List<TimeSeriesData> aggregateByMonth(List<BloodPressureReading> readings) {
    final Map<String, List<BloodPressureReading>> monthGroups = {};

    for (final reading in readings) {
      final monthKey = DateFormat('yyyy-MM').format(reading.timestamp);
      monthGroups.putIfAbsent(monthKey, () => []).add(reading);
    }

    final aggregatedData = <TimeSeriesData>[];
    for (final entry in monthGroups.entries) {
      final monthReadings = entry.value;

      if (monthReadings.isEmpty) continue;

      final avgSystolic = monthReadings
          .map((r) => r.systolic)
          .reduce((a, b) => a + b) ~/ monthReadings.length;
      final avgDiastolic = monthReadings
          .map((r) => r.diastolic)
          .reduce((a, b) => a + b) ~/ monthReadings.length;

      final avgHeartRate = monthReadings
          .where((r) => r.heartRate != null)
          .map((r) => r.heartRate!)
          .isNotEmpty
          ? monthReadings
              .where((r) => r.heartRate != null)
              .map((r) => r.heartRate!)
              .reduce((a, b) => a + b) ~/
              monthReadings.where((r) => r.heartRate != null).length
          : null;

      final firstReading = monthReadings.first;
      aggregatedData.add(TimeSeriesData(
        timestamp: DateTime(
          firstReading.timestamp.year,
          firstReading.timestamp.month,
          15, // Mid-month for better chart positioning
        ),
        systolic: avgSystolic,
        diastolic: avgDiastolic,
        heartRate: avgHeartRate,
        notes: 'Monthly average (${monthReadings.length} readings)',
        category: firstReading.category,
        originalReadings: monthReadings,
      ));
    }

    return aggregatedData..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Aggregate readings by season
  static List<TimeSeriesData> aggregateBySeason(List<BloodPressureReading> readings) {
    final Map<String, List<BloodPressureReading>> seasonGroups = {};

    for (final reading in readings) {
      final seasonKey = _getSeasonKey(reading.timestamp);
      seasonGroups.putIfAbsent(seasonKey, () => []).add(reading);
    }

    final aggregatedData = <TimeSeriesData>[];
    final seasonOrder = ['Winter', 'Spring', 'Summer', 'Fall'];

    for (final season in seasonOrder) {
      final seasonReadings = seasonGroups[season] ?? [];

      if (seasonReadings.isEmpty) continue;

      final avgSystolic = seasonReadings
          .map((r) => r.systolic)
          .reduce((a, b) => a + b) ~/ seasonReadings.length;
      final avgDiastolic = seasonReadings
          .map((r) => r.diastolic)
          .reduce((a, b) => a + b) ~/ seasonReadings.length;

      final avgHeartRate = seasonReadings
          .where((r) => r.heartRate != null)
          .map((r) => r.heartRate!)
          .isNotEmpty
          ? seasonReadings
              .where((r) => r.heartRate != null)
              .map((r) => r.heartRate!)
              .reduce((a, b) => a + b) ~/
              seasonReadings.where((r) => r.heartRate != null).length
          : null;

      final firstReading = seasonReadings.first;
      final seasonStart = _getSeasonStart(firstReading.timestamp, season);

      aggregatedData.add(TimeSeriesData(
        timestamp: seasonStart,
        systolic: avgSystolic,
        diastolic: avgDiastolic,
        heartRate: avgHeartRate,
        notes: '$season average (${seasonReadings.length} readings)',
        category: firstReading.category,
        originalReadings: seasonReadings,
      ));
    }

    return aggregatedData..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Aggregate readings by year
  static List<TimeSeriesData> aggregateByYear(List<BloodPressureReading> readings) {
    final Map<int, List<BloodPressureReading>> yearGroups = {};

    for (final reading in readings) {
      yearGroups.putIfAbsent(reading.timestamp.year, () => []).add(reading);
    }

    final aggregatedData = <TimeSeriesData>[];
    for (final entry in yearGroups.entries) {
      final yearReadings = entry.value;

      if (yearReadings.isEmpty) continue;

      final avgSystolic = yearReadings
          .map((r) => r.systolic)
          .reduce((a, b) => a + b) ~/ yearReadings.length;
      final avgDiastolic = yearReadings
          .map((r) => r.diastolic)
          .reduce((a, b) => a + b) ~/ yearReadings.length;

      final avgHeartRate = yearReadings
          .where((r) => r.heartRate != null)
          .map((r) => r.heartRate!)
          .isNotEmpty
          ? yearReadings
              .where((r) => r.heartRate != null)
              .map((r) => r.heartRate!)
              .reduce((a, b) => a + b) ~/
              yearReadings.where((r) => r.heartRate != null).length
          : null;

      aggregatedData.add(TimeSeriesData(
        timestamp: DateTime(entry.key, 6, 15), // Mid-year
        systolic: avgSystolic,
        diastolic: avgDiastolic,
        heartRate: avgHeartRate,
        notes: 'Annual average (${yearReadings.length} readings)',
        category: yearReadings.first.category,
        originalReadings: yearReadings,
      ));
    }

    return aggregatedData..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get week number for a given date
  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday - 1) / 7).floor() + 1;
  }

  /// Get season key for a given date
  static String _getSeasonKey(DateTime date) {
    final month = date.month;
    if (month >= 12 || month <= 2) return 'Winter';
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    return 'Fall';
  }

  /// Get season start date for a given date and season
  static DateTime _getSeasonStart(DateTime date, String season) {
    final year = date.year;
    switch (season) {
      case 'Winter':
        return DateTime(year <= date.month ? year - 1 : year, 12, 21);
      case 'Spring':
        return DateTime(year, 3, 20);
      case 'Summer':
        return DateTime(year, 6, 21);
      case 'Fall':
        return DateTime(year, 9, 22);
      default:
        return DateTime(year, 1, 1);
    }
  }

  /// Filter data by time range and return appropriate aggregation
  static List<TimeSeriesData> filterAndAggregate(
    List<BloodPressureReading> readings,
    ExtendedTimeRange timeRange,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    // Filter by date range if specified
    List<BloodPressureReading> filteredReadings = readings;
    if (startDate != null) {
      filteredReadings = filteredReadings
          .where((r) => r.timestamp.isAfter(startDate.subtract(const Duration(days: 1))))
          .toList();
    }
    if (endDate != null) {
      filteredReadings = filteredReadings
          .where((r) => r.timestamp.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    }

    // Apply aggregation based on time range
    switch (timeRange) {
      case ExtendedTimeRange.day:
        return aggregateByDay(filteredReadings);
      case ExtendedTimeRange.week:
        return aggregateByWeek(filteredReadings);
      case ExtendedTimeRange.month:
        return aggregateByMonth(filteredReadings);
      case ExtendedTimeRange.season:
        return aggregateBySeason(filteredReadings);
      case ExtendedTimeRange.year:
        return aggregateByYear(filteredReadings);
    }
  }
}

/// Blood Pressure Category Colors
class TimeSeriesColors {
  static const Map<BloodPressureCategory, Color> categoryColors = {
    BloodPressureCategory.low: Color(0xFF2196F3),
    BloodPressureCategory.normal: Color(0xFF4CAF50),
    BloodPressureCategory.elevated: Color(0xFFFF9800),
    BloodPressureCategory.stage1: Color(0xFFFF5722),
    BloodPressureCategory.stage2: Color(0xFFF44336),
    BloodPressureCategory.crisis: Color(0xFF9C27B0),
  };

  static Color getCategoryColor(BloodPressureCategory category) {
    return categoryColors[category] ?? Colors.grey;
  }
}

/// Custom tooltip renderer for time series chart
class TimeSeriesTooltipRenderer {
  static Widget buildTooltip(BuildContext context, TimeSeriesData data) {
    final color = TimeSeriesColors.getCategoryColor(data.category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM dd, yyyy').format(data.timestamp),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTooltipRow('Systolic:', '${data.systolic} mmHg'),
          _buildTooltipRow('Diastolic:', '${data.diastolic} mmHg'),
          if (data.heartRate != null)
            _buildTooltipRow('Heart Rate:', '${data.heartRate} bpm'),
          _buildTooltipRow('Category:', _getCategoryName(data.category)),
          if (data.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data.notes!,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildTooltipRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  static String _getCategoryName(BloodPressureCategory category) {
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
        return 'Hypertensive Crisis';
    }
  }
}

/// Time Series Chart Widget
class TimeSeriesChart extends StatefulWidget {
  const TimeSeriesChart({
    super.key,
    required this.readings,
    this.selectedReading,
    this.onReadingSelected,
    this.initialTimeRange = ExtendedTimeRange.month,
    this.startDate,
    this.endDate,
    this.onTimeRangeChanged,
    this.showTimeRangeSelector = true,
  });

  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;
  final Function(BloodPressureReading?)? onReadingSelected;
  final ExtendedTimeRange initialTimeRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(ExtendedTimeRange, DateTime?, DateTime?)? onTimeRangeChanged;
  final bool showTimeRangeSelector;

  @override
  TimeSeriesChartState createState() => TimeSeriesChartState();
}

class TimeSeriesChartState extends State<TimeSeriesChart> with WidgetsBindingObserver {
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;
  DateTime? _startDate;
  DateTime? _endDate;
  List<TimeSeriesData> _timeSeriesData = [];
  TooltipBehavior? _tooltipBehavior;
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentTimeRange = widget.initialTimeRange;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _updateTimeSeriesData();

    // Initialize tooltip behavior
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        if (data is TimeSeriesData) {
          return TimeSeriesTooltipRenderer.buildTooltip(context, data);
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void didUpdateWidget(TimeSeriesChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.readings != oldWidget.readings ||
        widget.initialTimeRange != oldWidget.initialTimeRange ||
        widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      setState(() {
        _currentTimeRange = widget.initialTimeRange;
        _startDate = widget.startDate;
        _endDate = widget.endDate;
      });
      _updateTimeSeriesData();
    }
  }

  void _updateTimeSeriesData() {
    setState(() {
      // Use all readings - don't filter by date range unless explicitly provided
      _timeSeriesData = TimeSeriesData.filterAndAggregate(
        widget.readings,
        _currentTimeRange,
        null, // No start date filter
        null, // No end date filter
      );
    });
  }

  // Try the simplest possible format strings
  String _getSimpleDateFormat() {
    switch (_currentTimeRange) {
      case ExtendedTimeRange.day:
        return 'M/d';
      case ExtendedTimeRange.week:
        return 'M/d';
      case ExtendedTimeRange.month:
        return 'MMM';
      case ExtendedTimeRange.season:
        return 'MMM';
      case ExtendedTimeRange.year:
        return 'yyyy';
    }
  }

  // Get appropriate interval for x-axis labels
  double? _getXAxisInterval() {
    switch (_currentTimeRange) {
      case ExtendedTimeRange.day:
        return 1; // 1 day interval
      case ExtendedTimeRange.week:
        return 7; // 7 days (1 week) interval
      case ExtendedTimeRange.month:
        return 30; // ~1 month interval
      case ExtendedTimeRange.season:
        return 90; // ~3 months (1 season) interval
      case ExtendedTimeRange.year:
        return 365; // ~1 year interval
    }
  }

  // Accessibility helper methods
  Widget _buildAccessibleHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Blood Pressure Trends',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: 'Chart instructions',
          child: Text(
            'Tap on any data point for details • ${_getTimeRangeDescription()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibleTimeRangeSelector() {
    return Semantics(
      label: 'Time range selector: ${_getTimeRangeDescription()}',
      hint: 'Buttons to change the time period displayed in the chart',
      child: _buildTimeRangeSelector(),
    );
  }

  Widget _buildAccessibleChart(BuildContext context) {
    return Semantics(
      label: 'Time series chart with ${_timeSeriesData.length} data points',
      hint: 'Shows blood pressure trends over ${_getTimeRangeDescription().toLowerCase()}. Blue line for systolic, red line for diastolic pressure.',
      child: _buildChart(),
    );
  }

  Widget _buildAccessibleEmptyState() {
    return Semantics(
      label: 'No blood pressure data available',
      hint: 'Start recording blood pressure readings to see trend analysis',
      child: _buildEmptyState(),
    );
  }

  String _getTimeRangeDescription() {
    switch (_currentTimeRange) {
      case ExtendedTimeRange.day:
        return 'Daily view';
      case ExtendedTimeRange.week:
        return 'Weekly view';
      case ExtendedTimeRange.month:
        return 'Monthly view';
      case ExtendedTimeRange.season:
        return 'Seasonal view';
      case ExtendedTimeRange.year:
        return 'Yearly view';
    }
  }

  // Public method to update time range from parent
  void updateTimeRange(ExtendedTimeRange timeRange, DateTime? startDate, DateTime? endDate) {
    if (_currentTimeRange != timeRange || _startDate != startDate || _endDate != endDate) {
      setState(() {
        _currentTimeRange = timeRange;
        _startDate = startDate;
        _endDate = endDate;
      });
      _updateTimeSeriesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_timeSeriesData.isEmpty) {
      return _buildAccessibleEmptyState();
    }

    return Semantics(
      label: 'Blood Pressure Trends Chart',
      hint: 'Interactive time series showing blood pressure trends over time. Navigate with arrow keys, select with Space.',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccessibleHeader(context),
            if (widget.showTimeRangeSelector) ...[
              const SizedBox(height: 16),
              _buildAccessibleTimeRangeSelector(),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 32),
            ],
            Expanded(
              child: _buildAccessibleChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start recording blood pressure to see trends here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SegmentedButton<ExtendedTimeRange>(
      segments: const [
        ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.day,
          label: Text('Day'),
        ),
        ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.week,
          label: Text('Week'),
        ),
        ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.month,
          label: Text('Month'),
        ),
        ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.season,
          label: Text('Season'),
        ),
        ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.year,
          label: Text('Year'),
        ),
      ],
      selected: {_currentTimeRange},
      onSelectionChanged: (Set<ExtendedTimeRange> selection) {
        if (selection.isNotEmpty) {
          setState(() {
            _currentTimeRange = selection.first;
          });
          widget.onTimeRangeChanged?.call(_currentTimeRange, _startDate, _endDate);
        }
      },
    );
  }

  Widget _buildChart() {
    return SfCartesianChart(
      tooltipBehavior: _tooltipBehavior,
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(
          text: 'Date',
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        // Try the simplest possible format strings
        labelFormat: _getSimpleDateFormat(),
        labelStyle: const TextStyle(fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'Blood Pressure (mmHg)',
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        minimum: 60,
        maximum: 200,
        interval: 20,
        labelStyle: const TextStyle(fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
        axisLine: const AxisLine(width: 1, color: Colors.black54),
      ),
      series: <CartesianSeries>[
        // Systolic line
        LineSeries<TimeSeriesData, DateTime>(
          dataSource: _timeSeriesData,
          xValueMapper: (TimeSeriesData data, _) => data.timestamp,
          yValueMapper: (TimeSeriesData data, _) => data.systolic.toDouble(),
          name: 'Systolic',
          color: const Color(0xFF1976D2),
          width: 3,
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: const Color(0xFF1976D2),
            borderWidth: 2,
            borderColor: Colors.white,
            width: 6,
            height: 6,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: false,
          ),
        animationDuration: 800,
        ),

        // Diastolic line
        LineSeries<TimeSeriesData, DateTime>(
          dataSource: _timeSeriesData,
          xValueMapper: (TimeSeriesData data, _) => data.timestamp,
          yValueMapper: (TimeSeriesData data, _) => data.diastolic.toDouble(),
          name: 'Diastolic',
          color: const Color(0xFF03A9F4),
          width: 2,
          dashArray: const <double>[5, 5],
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: const Color(0xFF03A9F4),
            borderWidth: 2,
            borderColor: Colors.white,
            width: 6,
            height: 6,
            shape: DataMarkerType.diamond,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: false,
          ),
          animationDuration: 800,
        ),
      ],
      selectionGesture: ActivationMode.singleTap,
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: const InteractiveTooltip(
          enable: true,
          color: Colors.white,
        ),
      ),
    );
  }
}