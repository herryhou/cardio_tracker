import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../domain/entities/blood_pressure_reading.dart';
import '../domain/entities/chart_types.dart';
import '../theme/app_theme.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

// Bar styling
const double _barWidth = 13.0;
// const double _barSpacing = 20.0;

// Y-axis bounds
const double _minY = 60.0;
const double _maxY = 170.0;
const double _yAxisInterval = 20.0;

// Text styling
const double _xAxisLabelFontSize = 9.0;
const double _yAxisLabelFontSize = 10.0;
const double _labelRotationAngle = 0.0; // Horizontal labels
const double _xAxisReservedSize = 40.0;
const double _yAxisReservedSize = 40.0;

// Grid styling
const double _gridAlpha = 0.3;
const double _gridLineWidth = 0.5;
const double _borderAlpha = 0.1;
const double _borderLineWidth = 1.0;

// Shadow styling
const double _shadowAlpha = 0.1;
const double _shadowBlurRadius = 8.0;

// Padding
const EdgeInsets _chartPadding = EdgeInsets.all(AppSpacing.md);

/// Blood Pressure Range Bar Chart Widget using fl_chart.
/// Displays each reading as a vertical bar showing the range from diastolic to systolic.
class BPRangeBarChart extends StatefulWidget {
  const BPRangeBarChart({
    super.key,
    required this.readings,
    this.selectedReading,
    this.onReadingSelected,
    this.initialTimeRange = ExtendedTimeRange.month,
    this.startDate,
    this.endDate,
    this.onTimeRangeChanged,
    this.showTimeRangeSelector = true,
    this.currentTimeRange,
  });

  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;
  final Function(BloodPressureReading?)? onReadingSelected;
  final ExtendedTimeRange initialTimeRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(ExtendedTimeRange, DateTime?, DateTime?)? onTimeRangeChanged;
  final bool showTimeRangeSelector;
  final ExtendedTimeRange? currentTimeRange;

  @override
  State<BPRangeBarChart> createState() => _BPRangeBarChartState();
}

class _BPRangeBarChartState extends State<BPRangeBarChart> {
  // State
  late ExtendedTimeRange _currentTimeRange;
  List<TimeSeriesData> _timeSeriesData = [];
  final Map<double, int> _xValueToIndex = {};

  @override
  void initState() {
    super.initState();
    _currentTimeRange = widget.initialTimeRange;
    _updateTimeSeriesData();
  }

  @override
  void didUpdateWidget(BPRangeBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldUpdateData(oldWidget)) {
      setState(() {
        _currentTimeRange = widget.initialTimeRange;
      });
      _updateTimeSeriesData();
    }
  }

  bool _shouldUpdateData(BPRangeBarChart oldWidget) {
    return widget.readings != oldWidget.readings ||
        widget.initialTimeRange != oldWidget.initialTimeRange ||
        widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate;
  }

  // ============================================================================
  // DATA MANAGEMENT
  // ============================================================================

  void _updateTimeSeriesData() {
    if (widget.readings.isEmpty) {
      _setTimeSeriesData([]);
      return;
    }

    final sortedReadings = _sortReadings(widget.readings);
    final filteredReadings = _filterReadingsByTimeRange(sortedReadings);
    final timeSeriesData = _convertToTimeSeriesData(filteredReadings);

    _setTimeSeriesData(timeSeriesData);
  }

  List<BloodPressureReading> _sortReadings(
      List<BloodPressureReading> readings) {
    return List<BloodPressureReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<BloodPressureReading> _filterReadingsByTimeRange(
    List<BloodPressureReading> readings,
  ) {
    if (readings.isEmpty) return [];

    final rangeInfo = _TimeRangeInfo(
      timeRange: _currentTimeRange,
      startDateOverride: widget.startDate,
      endDateOverride: widget.endDate,
    );

    final rangeStart = rangeInfo.rangeStart;
    final rangeEnd = rangeInfo.rangeEnd;

    return readings
        .where((r) =>
            r.timestamp.isAfter(rangeStart) && r.timestamp.isBefore(rangeEnd))
        .toList();
  }

  List<TimeSeriesData> _convertToTimeSeriesData(
    List<BloodPressureReading> readings,
  ) {
    return readings
        .map((reading) => TimeSeriesData(
              timestamp: reading.timestamp,
              systolic: reading.systolic.toDouble(),
              diastolic: reading.diastolic.toDouble(),
              heartRate: reading.heartRate.toDouble(),
              notes: reading.notes,
              category: reading.category.name,
              originalReadings: [reading],
            ))
        .toList();
  }

  void _setTimeSeriesData(List<TimeSeriesData> data) {
    setState(() {
      _timeSeriesData = data;
      _buildXValueMapping();
    });
  }

  void _buildXValueMapping() {
    _xValueToIndex.clear();
    if (_timeSeriesData.isEmpty) return;

    for (int i = 0; i < _timeSeriesData.length; i++) {
      final ts = _timeSeriesData[i].timestamp.millisecondsSinceEpoch.toDouble();
      _xValueToIndex[ts] = i;
    }
  }

  // ============================================================================
  // UI BUILD METHODS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    if (_timeSeriesData.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Render only the chart (bar chart)
        Expanded(
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 450,
      child: BarChart(
        _buildBarChartData(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: _chartPadding,
      decoration: BoxDecoration(
        color: AppTheme.getChartBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: _gridAlpha),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No data available',
            style: AppTheme.headerStyle.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              fontSize: 16, // Override for this context
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start recording blood pressure to see ranges here',
            style: AppTheme.bodyStyle.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // CHART DATA BUILDING
  // ============================================================================

  BarChartData _buildBarChartData() {
    if (_timeSeriesData.isEmpty) return _buildEmptyBarChartData();

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < _timeSeriesData.length; i++) {
      final data = _timeSeriesData[i];
      final reading =
          data.originalReadings.isNotEmpty ? data.originalReadings.first : null;

      if (reading != null) {
        barGroups.add(_createBarGroup(i, reading, data));
      }
    }

    return BarChartData(
      barGroups: barGroups,
      titlesData: _buildTitlesData(),
      gridData: _buildGridData(),
      borderData: _buildBorderData(),
      barTouchData: _buildBarTouchData(),
      alignment: BarChartAlignment.spaceAround,
      backgroundColor: Colors.transparent,
      minY: _minY,
      maxY: _maxY,
    );
  }

  BarChartGroupData _createBarGroup(
      int x, BloodPressureReading reading, TimeSeriesData data) {
    // final isSelected = widget.selectedReading == reading;
    final color = _getCategoryColor(reading.category);

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: reading.systolic.toDouble(),
          fromY: reading.diastolic.toDouble(),
          color: color.withValues(alpha: 0.8),
          width: _barWidth,
          borderRadius: BorderRadius.circular(_barWidth / 2),
        ),
      ],
    );
  }

  Color _getCategoryColor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return const Color(0xFF3B82F6); // Blue
      case BloodPressureCategory.normal:
        return const Color(0xFF10B981); // Green
      case BloodPressureCategory.elevated:
        return const Color(0xFFF59E0B); // Yellow/Amber
      case BloodPressureCategory.stage1:
        return const Color(0xFFF97316); // Orange
      case BloodPressureCategory.stage2:
        return const Color(0xFFEF4444); // Red
      case BloodPressureCategory.crisis:
        return const Color(0xFF991B1B); // Dark Red
    }
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _yAxisInterval,
          reservedSize: _yAxisReservedSize,
          getTitlesWidget: (value, meta) => _buildYAxisLabel(value),
        ),
        axisNameWidget: Text(
          'Sys/Dia',
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        axisNameSize: 20,
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _xAxisReservedSize,
          interval: 3.0, // Show every 3rd index
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            return _buildXAxisLabel(index);
          },
        ),
      ),
    );
  }

  Text _buildYAxisLabel(double value) {
    return Text(
      value.toInt().toString(),
      style: AppTheme.bodyStyle.copyWith(
        fontSize: _yAxisLabelFontSize,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildXAxisLabel(int index) {
    if (index < 0 || index >= _timeSeriesData.length) {
      return const SizedBox.shrink();
    }

    // Only show label for every 3rd index
    if (index % 3 != 0) {
      return const SizedBox.shrink();
    }

    final data = _timeSeriesData[index];
    final formattedDate = DateFormat('MM/dd').format(data.timestamp);

    return Transform.rotate(
      angle: _labelRotationAngle,
      child: Text(
        formattedDate,
        style: TextStyle(
          fontSize: _xAxisLabelFontSize,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: _yAxisInterval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: AppTheme.getChartGridColor(context),
        strokeWidth: _gridLineWidth,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: AppTheme.getChartGridColor(context),
        strokeWidth: _gridLineWidth,
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Theme.of(context)
            .colorScheme
            .outline
            .withValues(alpha: _borderAlpha),
        width: _borderLineWidth,
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) =>
            Theme.of(context).colorScheme.surfaceContainer,
        tooltipBorder: BorderSide(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        getTooltipItem: _buildTooltipItem,
      ),
      touchCallback: _handleBarTouchEvent,
      handleBuiltInTouches: true,
    );
  }

  BarTooltipItem? _buildTooltipItem(
      group, int groupIndex, BarChartRodData rod, int rodIndex) {
    // Find the reading associated with this bar
    if (groupIndex >= _timeSeriesData.length) return null;

    final data = _timeSeriesData[groupIndex];
    final reading =
        data.originalReadings.isNotEmpty ? data.originalReadings.first : null;
    final category = reading?.category.name ?? 'Normal';

    return BarTooltipItem(
      'Systolic: ${data.systolic.toInt()}\n'
      'Diastolic: ${data.diastolic.toInt()}\n'
      '$category\n'
      '${DateFormat('MMM dd, HH:mm').format(data.timestamp)}',
      TextStyle(
        color: _getCategoryColor(
            reading?.category ?? BloodPressureCategory.normal),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  void _handleBarTouchEvent(
      FlTouchEvent event, BarTouchResponse? touchResponse) {
    if (event is! FlTapUpEvent || touchResponse == null) return;

    final touchedGroup = touchResponse.spot?.touchedBarGroup;
    if (touchedGroup == null) {
      widget.onReadingSelected?.call(null);
      return;
    }

    // Use the x value directly as the reading index
    final readingIndex = touchedGroup.x;

    if (readingIndex >= 0 && readingIndex < _timeSeriesData.length) {
      final reading = _timeSeriesData[readingIndex].originalReadings.isNotEmpty
          ? _timeSeriesData[readingIndex].originalReadings.first
          : null;
      widget.onReadingSelected?.call(reading);
    }
  }

  BarChartData _buildEmptyBarChartData() {
    return BarChartData(
      barGroups: [],
      titlesData: _buildTitlesData(),
      gridData: const FlGridData(show: false),
      borderData: _buildBorderData(),
      backgroundColor: Colors.transparent,
      minY: _minY,
      maxY: _maxY,
    );
  }
}

/// Helper class to encapsulate time range logic and computations.
class _TimeRangeInfo {
  _TimeRangeInfo({
    required this.timeRange,
    required this.startDateOverride,
    required this.endDateOverride,
  });

  final ExtendedTimeRange timeRange;
  final DateTime? startDateOverride;
  final DateTime? endDateOverride;

  DateTime get rangeStart {
    if (startDateOverride != null) return startDateOverride!;
    return _computeRangeStart();
  }

  DateTime get rangeEnd {
    if (endDateOverride != null) return endDateOverride!;
    return _computeRangeEnd();
  }

  DateTime _computeRangeStart() {
    final now = DateTime.now();
    switch (timeRange) {
      case ExtendedTimeRange.week:
        return DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
      case ExtendedTimeRange.month:
        return DateTime(now.year, now.month, 1);
      case ExtendedTimeRange.season:
        return now.subtract(const Duration(days: 90));
      case ExtendedTimeRange.year:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime _computeRangeEnd() {
    final start = _computeRangeStart();
    switch (timeRange) {
      case ExtendedTimeRange.week:
        return start.add(const Duration(days: 7));
      case ExtendedTimeRange.month:
        int nextMonth = start.month + 1;
        int nextYear = start.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        return DateTime(nextYear, nextMonth, 1);
      case ExtendedTimeRange.season:
        return start.add(const Duration(days: 90));
      case ExtendedTimeRange.year:
        return DateTime(start.year + 1, 1, 1);
    }
  }

  /// Get date format string based on time range.
  String getDateFormat() {
    switch (timeRange) {
      case ExtendedTimeRange.week:
        return 'MMM dd';
      case ExtendedTimeRange.month:
        return 'MMM dd';
      case ExtendedTimeRange.season:
        return 'MMM dd';
      case ExtendedTimeRange.year:
        return 'MMM';
    }
  }
}
