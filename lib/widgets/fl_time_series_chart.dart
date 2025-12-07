import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/blood_pressure_reading.dart';
import 'time_series_chart.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

// Chart colors
const Color _systolicColor = Color(0xFF1976D2);
const Color _diastolicColor = Color(0xFF03A9F4);

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
const double _labelRotationAngle = -0.3;
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
const EdgeInsets _chartPadding = EdgeInsets.all(16);
const double _labelTopPadding = 8.0;

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
              systolic: reading.systolic,
              diastolic: reading.diastolic,
              heartRate: reading.heartRate,
              notes: reading.notes,
              category: reading.category,
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

    final first = _timeSeriesData.first.timestamp;
    final last = _timeSeriesData.last.timestamp;
  }

  int? _getClosestIndexForX(double x) {
    if (_xValueToIndex.isEmpty) return null;

    double minDistance = double.infinity;
    double? closestX;

    for (final xValue in _xValueToIndex.keys) {
      final distance = (x - xValue).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestX = xValue;
      }
    }

    final idx = closestX != null ? _xValueToIndex[closestX] : null;
    return idx;
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
      padding: EdgeInsets.zero,
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _shadowAlpha),
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
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: _chartPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: _gridAlpha)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
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

  // ============================================================================
  // CHART DATA BUILDING
  // ============================================================================

  LineChartData _buildLineChartData() {
    if (_timeSeriesData.isEmpty) return _buildEmptyChartData();

    final systolicSpots = _buildSpots((d) => d.systolic.toDouble());
    final diastolicSpots = _buildSpots((d) => d.diastolic.toDouble());

    final rangeInfo = _TimeRangeInfo(
      timeRange: _currentTimeRange,
      startDateOverride: widget.startDate,
      endDateOverride: widget.endDate,
    );

    final rangeStart = rangeInfo.rangeStart.millisecondsSinceEpoch.toDouble();
    final rangeEnd = rangeInfo.rangeEnd.millisecondsSinceEpoch.toDouble();

    return LineChartData(
      lineBarsData: [
        _buildSystolicLine(systolicSpots),
        _buildDiastolicLine(diastolicSpots),
      ],
      titlesData: _buildTitlesData(rangeInfo),
      gridData: _buildGridData(),
      borderData: _buildBorderData(),
      minX: rangeStart,
      maxX: rangeEnd,
      minY: _minY,
      maxY: _maxY,
      lineTouchData: _buildTouchData(),
    );
  }

  List<FlSpot> _buildSpots(double Function(TimeSeriesData) accessor) {
    return _timeSeriesData.asMap().entries.map((e) {
      final x = _getXValueForIndex(e.key);
      return FlSpot(x, accessor(e.value).toDouble());
    }).toList();
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

  FlTitlesData _buildTitlesData(_TimeRangeInfo rangeInfo) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _yAxisInterval,
          reservedSize: _yAxisReservedSize,
          getTitlesWidget: (value, meta) => _buildYAxisLabel(value),
        ),
        axisNameWidget: const Text(
          'Sys/Dia',
          style: TextStyle(
            fontSize: 13,
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
          interval: rangeInfo.getXAxisInterval(),
          getTitlesWidget: (value, meta) => _buildXAxisLabel(value, rangeInfo),
        ),
      ),
    );
  }

  Text _buildYAxisLabel(double value) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(
        fontSize: _yAxisLabelFontSize,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildXAxisLabel(double value, _TimeRangeInfo rangeInfo) {
    try {
      final xMs = value.toInt();
      final date = DateTime.fromMillisecondsSinceEpoch(xMs);
      final formattedDate = DateFormat(rangeInfo.getDateFormat()).format(date);

      return Padding(
        padding: const EdgeInsets.only(top: _labelTopPadding),
        child: Transform.rotate(
          angle: _labelRotationAngle,
          child: Text(
            formattedDate,
            style: const TextStyle(
              fontSize: _xAxisLabelFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
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

  LineTouchData _buildTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (group) => Colors.white,
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

  LineChartData _buildEmptyChartData() {
    return LineChartData(
      lineBarsData: [],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _yAxisInterval,
            reservedSize: _yAxisReservedSize,
            getTitlesWidget: (value, meta) => _buildYAxisLabel(value),
          ),
          axisNameWidget: const Text(
            'Sys/Dia',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          axisNameSize: 20,
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
      ),
      gridData: FlGridData(show: false),
      borderData: _buildBorderData(),
      minX: 0,
      maxX: 1,
      minY: _minY,
      maxY: _maxY,
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  double _getXValueForIndex(int index) {
    if (index < 0 || index >= _timeSeriesData.length) return 0.0;
    return _timeSeriesData[index].timestamp.millisecondsSinceEpoch.toDouble();
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
      case ExtendedTimeRange.day:
        return DateTime(now.year, now.month, now.day);
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
      case ExtendedTimeRange.day:
        return start.add(const Duration(days: 1));
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

  /// Get X-axis interval in milliseconds based on time range.
  double getXAxisInterval() {
    switch (timeRange) {
      case ExtendedTimeRange.day:
        return Duration(hours: 4).inMilliseconds.toDouble();
      case ExtendedTimeRange.week:
        return Duration(days: 1).inMilliseconds.toDouble();
      case ExtendedTimeRange.month:
        return Duration(days: 3)
            .inMilliseconds
            .toDouble(); // Changed from 7 to 3 days for better label distribution
      case ExtendedTimeRange.season:
        return Duration(days: 14)
            .inMilliseconds
            .toDouble(); // Changed from 21 to 14 days
      case ExtendedTimeRange.year:
        return Duration(days: 30)
            .inMilliseconds
            .toDouble(); // Changed from 60 to 30 days
    }
  }

  /// Get date format string based on time range.
  String getDateFormat() {
    switch (timeRange) {
      case ExtendedTimeRange.day:
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
