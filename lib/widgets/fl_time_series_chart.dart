import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/blood_pressure_reading.dart';
import '../models/chart_types.dart';
import '../theme/app_theme.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

// Chart colors
const Color _systolicColor = Color(0xFFFF0000); // Red
const Color _diastolicColor = Color(0xFF0000FF); // Blue

// Line styling
const double _systolicBarWidth = 3.0;
const double _diastolicBarWidth = 2.0;
const bool _isCurved = false;
const List<int> _diastolicDashArray = [5, 5];

// Dot styling
const double _dotRadius = 4.0;
const double _selectedDotRadius = 6.0;
const double _dotStrokeWidth = 2.0;

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

/// Time Series Chart Widget using fl_chart with clean, maintainable architecture.
class FlTimeSeriesChart extends StatefulWidget {
  const FlTimeSeriesChart({
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
  State<FlTimeSeriesChart> createState() => _FlTimeSeriesChartState();
}

class _FlTimeSeriesChartState extends State<FlTimeSeriesChart> {
  // State
  late ExtendedTimeRange _currentTimeRange;
  List<TimeSeriesData> _timeSeriesData = [];
  Map<double, int> _xValueToIndex = {};

  @override
  void initState() {
    super.initState();
    _currentTimeRange = widget.initialTimeRange;
    _updateTimeSeriesData();
  }

  @override
  void didUpdateWidget(FlTimeSeriesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldUpdateData(oldWidget)) {
      setState(() {
        _currentTimeRange = widget.initialTimeRange;
      });
      _updateTimeSeriesData();
    }
  }

  bool _shouldUpdateData(FlTimeSeriesChart oldWidget) {
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

  int? _getClosestIndexForX(double x) {
    if (_timeSeriesData.isEmpty) return null;

    // Since we're using indices directly, round to nearest index
    final index = x.round();

    if (index >= 0 && index < _timeSeriesData.length) {
      return index;
    }

    return null;
  }

  // ============================================================================
  // UI BUILD METHODS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    if (_timeSeriesData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      decoration: _buildContainerDecoration(),
      child: Column(
        children: [
          // Render only the chart (line chart) — no header or selector
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: AppTheme.getChartBackground(context),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: _shadowAlpha),
          blurRadius: _shadowBlurRadius,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 450,
      child: LineChart(
        _buildLineChartData(),
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
              ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
              : Colors.grey.withValues(alpha: _gridAlpha),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          SizedBox(height: AppSpacing.md),
          Text(
            'No data available',
            style: AppTheme.headerStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16, // Override for this context
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Start recording blood pressure to see trends here',
            style: AppTheme.bodyStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

  LineChartData _buildLineChartData() {
    if (_timeSeriesData.isEmpty) return _buildEmptyChartData();

    // Calculate averages
    final avgSystolic = _timeSeriesData.isEmpty
        ? 0.0
        : _timeSeriesData.map((d) => d.systolic).reduce((a, b) => a + b) /
            _timeSeriesData.length;
    final avgDiastolic = _timeSeriesData.isEmpty
        ? 0.0
        : _timeSeriesData.map((d) => d.diastolic).reduce((a, b) => a + b) /
            _timeSeriesData.length;

    // Build spots using indices for X-axis (simpler approach)
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    for (int i = 0; i < _timeSeriesData.length; i++) {
      final data = _timeSeriesData[i];
      systolicSpots.add(FlSpot(i.toDouble(), data.systolic));
      diastolicSpots.add(FlSpot(i.toDouble(), data.diastolic));
    }

    return LineChartData(
      lineBarsData: [
        _buildSystolicLine(systolicSpots),
        _buildDiastolicLine(diastolicSpots),
        // Add average reference lines
        _buildAverageLine(avgSystolic, _systolicColor.withValues(alpha: 0.5)),
        _buildAverageLine(avgDiastolic, _diastolicColor.withValues(alpha: 0.5)),
      ],
      titlesData: _buildTitlesData(),
      gridData: _buildGridData(),
      borderData: _buildBorderData(),
      minX: 0,
      maxX: (_timeSeriesData.length - 1).toDouble(),
      minY: _minY,
      maxY: _maxY,
      lineTouchData: _buildLineTouchData(),
    );
  }

  LineChartBarData _buildSystolicLine(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: _isCurved,
      color: _systolicColor,
      barWidth: _systolicBarWidth,
      isStrokeCapRound: true,
      dotData:
          FlDotData(show: true, getDotPainter: _getDotPainter(_systolicColor)),
      belowBarData: BarAreaData(show: false),
    );
  }

  LineChartBarData _buildDiastolicLine(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: _isCurved,
      color: _diastolicColor,
      barWidth: _diastolicBarWidth,
      isStrokeCapRound: true,
      dashArray: _diastolicDashArray,
      dotData:
          FlDotData(show: true, getDotPainter: _getDotPainter(_diastolicColor)),
      belowBarData: BarAreaData(show: false),
    );
  }

  LineChartBarData _buildAverageLine(double averageValue, Color color) {
    if (_timeSeriesData.isEmpty) {
      return LineChartBarData(spots: []);
    }

    return LineChartBarData(
      spots: [
        FlSpot(0, averageValue),
        FlSpot((_timeSeriesData.length - 1).toDouble(), averageValue),
      ],
      isCurved: false,
      color: color,
      barWidth: 1.5,
      isStrokeCapRound: false,
      dashArray: [5, 5], // Dotted line
      dotData: FlDotData(show: false), // No dots on average line
      belowBarData: BarAreaData(show: false),
    );
  }

  GetDotPainterCallback _getDotPainter(Color strokeColor) {
    return (spot, percent, barData, index) {
      final dataIndex = _getClosestIndexForX(spot.x);
      if (dataIndex == null || dataIndex >= _timeSeriesData.length) {
        return FlDotCirclePainter(
          radius: _dotRadius,
          color: Colors.white,
          strokeColor: strokeColor,
          strokeWidth: _dotStrokeWidth,
        );
      }

      final data = _timeSeriesData[dataIndex];
      final reading =
          data.originalReadings.isNotEmpty ? data.originalReadings.first : null;
      final isSelected = widget.selectedReading == reading;

      return FlDotCirclePainter(
        radius: isSelected ? _selectedDotRadius : _dotRadius,
        color: Colors.white,
        strokeColor: strokeColor,
        strokeWidth: _dotStrokeWidth,
      );
    };
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
            fontSize: 13, // Override for axis label
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        axisNameSize: 20,
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _xAxisReservedSize,
          interval: 3.0, // Show every 3rd index
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            return _buildBarXAxisLabel(index);
          },
        ),
      ),
    );
  }

  // Removed _buildBarTitlesData as we're using LineChart now

  Text _buildYAxisLabel(double value) {
    return Text(
      value.toInt().toString(),
      style: AppTheme.bodyStyle.copyWith(
        fontSize: _yAxisLabelFontSize,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildBarXAxisLabel(int index) {
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
        style: const TextStyle(
          fontSize: _xAxisLabelFontSize,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
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
        color: Colors.grey.withValues(alpha: _gridAlpha),
        strokeWidth: _gridLineWidth,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: Colors.grey.withValues(alpha: _gridAlpha),
        strokeWidth: _gridLineWidth,
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Colors.black.withValues(alpha: _borderAlpha),
        width: _borderLineWidth,
      ),
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.white,
        tooltipBorder:
            BorderSide(color: Colors.grey.withValues(alpha: _gridAlpha)),
        getTooltipItems: _buildTooltipItems,
      ),
      touchCallback: _handleTouchEvent,
      handleBuiltInTouches: true,
    );
  }

  List<LineTooltipItem?> _buildTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((spot) {
      final index = _getClosestIndexForX(spot.x);
      if (index == null || index >= _timeSeriesData.length) return null;

      final data = _timeSeriesData[index];
      final isSystolic = spot.barIndex == 0;
      final value = isSystolic ? data.systolic : data.diastolic;
      final tooltipText = isSystolic
          ? 'Systolic: $value'
          : 'Diastolic: $value\n${DateFormat('MMM dd, HH:mm').format(data.timestamp)}';

      return LineTooltipItem(
        tooltipText,
        TextStyle(
          color: isSystolic ? _systolicColor : _diastolicColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }

  // Bar chart methods are no longer needed but kept for reference
  // BarTooltipItem? _buildBarTooltipItem(group, int groupIndex, BarChartRodData rod, int rodIndex) {
  //   // Find the reading associated with this bar
  //   if (groupIndex >= _timeSeriesData.length) return null;

  //   final data = _timeSeriesData[groupIndex];
  //   final reading = data.originalReadings.isNotEmpty ? data.originalReadings.first : null;
  //   final category = reading?.category?.name ?? 'Normal';

  //   return BarTooltipItem(
  //     'Systolic: ${data.systolic}\nDiastolic: ${data.diastolic}\n$category\n${DateFormat('MMM dd, HH:mm').format(data.timestamp)}',
  //     TextStyle(
  //       color: _getCategoryColor(reading?.category ?? BloodPressureCategory.normal),
  //       fontWeight: FontWeight.bold,
  //       fontSize: 12,
  //     ),
  //   );
  // }

  // void _handleBarTouchEvent(FlTouchEvent event, BarTouchResponse? touchResponse) {
  //   if (event is! FlTapUpEvent || touchResponse == null) return;

  //   final touchedGroup = touchResponse.spot?.touchedBarGroup;
  //   if (touchedGroup == null) {
  //     widget.onReadingSelected?.call(null);
  //     return;
  //   }

  //   // Use the x value directly as the reading index
  //   final readingIndex = touchedGroup.x;

  //   if (readingIndex >= 0 && readingIndex < _timeSeriesData.length) {
  //     final reading = _timeSeriesData[readingIndex].originalReadings.isNotEmpty
  //         ? _timeSeriesData[readingIndex].originalReadings.first
  //         : null;
  //     widget.onReadingSelected?.call(reading);
  //   }
  // }

  void _handleTouchEvent(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (event is! FlTapUpEvent || touchResponse == null) return;

    final touchedSpots = touchResponse.lineBarSpots;
    if (touchedSpots == null || touchedSpots.isEmpty) {
      widget.onReadingSelected?.call(null);
      return;
    }

    final x = touchedSpots.first.x;
    final index = _getClosestIndexForX(x);

    if (index != null && index >= 0 && index < _timeSeriesData.length) {
      final reading = _timeSeriesData[index].originalReadings.isNotEmpty
          ? _timeSeriesData[index].originalReadings.first
          : null;
      widget.onReadingSelected?.call(reading);
    }
  }

  // Removed _buildEmptyBarChartData as we're using LineChart now

  LineChartData _buildEmptyChartData() {
    return LineChartData(
      lineBarsData: [],
      titlesData: _buildTitlesData(),
      gridData: FlGridData(show: false),
      borderData: _buildBorderData(),
      minX: 0,
      maxX: 1,
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

  /// Get X-axis interval based on time range.
  double getXAxisInterval() {
    switch (timeRange) {
      case ExtendedTimeRange.week:
        return 3.0; // Show every 3rd reading
      case ExtendedTimeRange.month:
        return 3.0; // Show every 3rd reading
      case ExtendedTimeRange.season:
        return 3.0; // Show every 3rd reading
      case ExtendedTimeRange.year:
        return 3.0; // Show every 3rd reading
    }
  }

  /// Get date format string based on time range.
  String getDateFormat() {
    switch (timeRange) {
      case ExtendedTimeRange.week:
        return 'MMM dd';
      case ExtendedTimeRange.month:
        return 'MMM dd'; // Changed from 'MMM yy' to show day numbers for clarity
      case ExtendedTimeRange.season:
        return 'MMM dd';
      case ExtendedTimeRange.year:
        return 'MMM';
    }
  }
}
