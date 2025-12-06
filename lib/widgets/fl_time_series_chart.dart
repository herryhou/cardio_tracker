import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/blood_pressure_reading.dart';
import 'time_series_chart.dart';

/// Time Series Chart Widget using fl_chart - FIXED VERSION
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
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;
  List<TimeSeriesData> _timeSeriesData = [];
  // Map to store x-value to index mapping
  Map<double, int> _xValueToIndex = {};

  @override
  void initState() {
    super.initState();
    _currentTimeRange = widget.currentTimeRange ?? widget.initialTimeRange;
    _updateTimeSeriesData();
  }

  @override
  void didUpdateWidget(FlTimeSeriesChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.readings != oldWidget.readings ||
        widget.currentTimeRange != oldWidget.currentTimeRange ||
        widget.initialTimeRange != oldWidget.initialTimeRange ||
        widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      setState(() {
        _currentTimeRange = widget.currentTimeRange ?? widget.initialTimeRange;
      });
      _updateTimeSeriesData();
    }
  }

  void _updateTimeSeriesData() {
    if (widget.readings.isEmpty) {
      setState(() {
        _timeSeriesData = [];
        _xValueToIndex = {};
      });
      return;
    }

    final sortedReadings = List<BloodPressureReading>.from(widget.readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Filter readings by time range - show EXACT readings without aggregation
    List<BloodPressureReading> filteredReadings;

    if (sortedReadings.isEmpty) {
      filteredReadings = [];
    } else {
      final now = DateTime.now();

      switch (_currentTimeRange) {
        case ExtendedTimeRange.day:
          // Show readings from today only
          filteredReadings = sortedReadings.where((reading) {
            return reading.timestamp.year == now.year &&
                   reading.timestamp.month == now.month &&
                   reading.timestamp.day == now.day;
          }).toList();
          break;
        case ExtendedTimeRange.week:
          // Show readings from the last 7 days
          filteredReadings = sortedReadings.where((reading) {
            return reading.timestamp.isAfter(now.subtract(const Duration(days: 7)));
          }).toList();
          break;
        case ExtendedTimeRange.month:
          // Show readings from the current month
          filteredReadings = sortedReadings.where((reading) {
            return reading.timestamp.year == now.year &&
                   reading.timestamp.month == now.month;
          }).toList();
          break;
        case ExtendedTimeRange.season:
          // Show readings from the current season (last 3 months)
          filteredReadings = sortedReadings.where((reading) {
            return reading.timestamp.isAfter(now.subtract(const Duration(days: 90)));
          }).toList();
          break;
        case ExtendedTimeRange.year:
          // Show readings from the current year
          filteredReadings = sortedReadings.where((reading) {
            return reading.timestamp.year == now.year;
          }).toList();
          break;
      }
    }

    // Convert raw readings to TimeSeriesData format (without aggregation)
    final timeSeriesData = filteredReadings.map((reading) => TimeSeriesData(
      timestamp: reading.timestamp,
      systolic: reading.systolic,
      diastolic: reading.diastolic,
      heartRate: reading.heartRate,
      notes: reading.notes,
      category: reading.category,
      originalReadings: [reading],
    )).toList();

    setState(() {
      _timeSeriesData = timeSeriesData;
      _buildXValueMapping();
    });
  }

  void _buildXValueMapping() {
    _xValueToIndex = {};
    
    if (_timeSeriesData.isEmpty) return;
    
    final firstTimestamp = _timeSeriesData.first.timestamp.millisecondsSinceEpoch;
    final lastTimestamp = _timeSeriesData.last.timestamp.millisecondsSinceEpoch;
    final timeSpan = lastTimestamp - firstTimestamp;

    for (int i = 0; i < _timeSeriesData.length; i++) {
      final data = _timeSeriesData[i];
      final timeFromStart = data.timestamp.millisecondsSinceEpoch - firstTimestamp;
      double x;

      if (_timeSeriesData.length == 1) {
        x = 5.0; // Center single point
      } else if (timeSpan > 0) {
        x = (timeFromStart / timeSpan) * 10;
      } else {
        x = (i / (_timeSeriesData.length - 1)) * 10;
      }

      _xValueToIndex[x] = i;
    }
  }

  int? _getClosestIndexForX(double x) {
    if (_xValueToIndex.isEmpty) return null;
    
    // Find the closest x value in our mapping
    double minDistance = double.infinity;
    double? closestX;
    
    for (final xValue in _xValueToIndex.keys) {
      final distance = (x - xValue).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestX = xValue;
      }
    }
    
    return closestX != null ? _xValueToIndex[closestX] : null;
  }

  String _getXAxisLabelFormat() {
    switch (_currentTimeRange) {
      case ExtendedTimeRange.day:
      case ExtendedTimeRange.week:
        return 'MMM dd';
      case ExtendedTimeRange.month:
      case ExtendedTimeRange.season:
        return 'MMM yy';
      case ExtendedTimeRange.year:
        return 'yyyy';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_timeSeriesData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
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
          _buildHeader(),
          if (widget.showTimeRangeSelector) ...[
            const SizedBox(height: 16),
            _buildTimeRangeSelector(),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 32),
          ],
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Pressure Trends',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap on any data point for details • ${_getTimeRangeDescription()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
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
          _updateTimeSeriesData();
          widget.onTimeRangeChanged?.call(_currentTimeRange, widget.startDate, widget.endDate);
        }
      },
    );
  }

  Widget _buildChart() {
    return LineChart(
      _getLineChartData(),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData _getLineChartData() {
    if (_timeSeriesData.isEmpty) {
      return _getEmptyLineChartData();
    }

    final List<FlSpot> systolicSpots = [];
    final List<FlSpot> diastolicSpots = [];

    // Build spots using the same x-value calculation
    for (final entry in _xValueToIndex.entries) {
      final x = entry.key;
      final index = entry.value;
      final data = _timeSeriesData[index];
      
      systolicSpots.add(FlSpot(x, data.systolic.toDouble()));
      diastolicSpots.add(FlSpot(x, data.diastolic.toDouble()));
    }

    return LineChartData(
      lineBarsData: [
        // Systolic line
        LineChartBarData(
          spots: systolicSpots,
          isCurved: false,  // Straight lines
          color: const Color(0xFF1976D2),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final dataIndex = _getClosestIndexForX(spot.x);
              if (dataIndex == null || dataIndex >= _timeSeriesData.length) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeColor: const Color(0xFF1976D2),
                  strokeWidth: 2,
                );
              }

              final data = _timeSeriesData[dataIndex];
              final reading = _getOriginalReading(data);
              final isSelected = widget.selectedReading == reading;

              return FlDotCirclePainter(
                radius: isSelected ? 6 : 4,
                color: Colors.white,
                strokeColor: const Color(0xFF1976D2),
                strokeWidth: 2,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
        // Diastolic line
        LineChartBarData(
          spots: diastolicSpots,
          isCurved: false,  // Straight lines
          color: const Color(0xFF03A9F4),
          barWidth: 2,
          isStrokeCapRound: true,
          dashArray: [5, 5],
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final dataIndex = _getClosestIndexForX(spot.x);
              if (dataIndex == null || dataIndex >= _timeSeriesData.length) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeColor: const Color(0xFF03A9F4),
                  strokeWidth: 2,
                );
              }

              final data = _timeSeriesData[dataIndex];
              final reading = _getOriginalReading(data);
              final isSelected = widget.selectedReading == reading;

              return FlDotCirclePainter(
                radius: isSelected ? 6 : 4,
                color: Colors.white,
                strokeColor: const Color(0xFF03A9F4),
                strokeWidth: 2,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 2,  // Show labels at regular intervals
            getTitlesWidget: (value, meta) {
              // Find the data point that exactly matches this X value
              final xValue = value;

              // Check if this X value exists in our data mapping
              if (_xValueToIndex.containsKey(xValue)) {
                final index = _xValueToIndex[xValue]!;

                if (index >= 0 && index < _timeSeriesData.length) {
                  // Only show labels at specific intervals to prevent crowding
                  final shouldShowLabel = _shouldShowXAxisLabel(index);
                  if (!shouldShowLabel) {
                    return const SizedBox.shrink();
                  }

                  final date = _timeSeriesData[index].timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Transform.rotate(
                      angle: -0.3,  // Rotate labels slightly to prevent overlap
                      child: Text(
                        DateFormat(_getXAxisLabelFormat()).format(date),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.3),
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.3),
            strokeWidth: 0.5,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: 10,
      minY: 60,
      maxY: 200,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (group) => Colors.white,
          tooltipBorder: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = _getClosestIndexForX(spot.x);
              if (index == null || index >= _timeSeriesData.length) {
                return null;
              }

              final data = _timeSeriesData[index];
              final isSystolic = spot.barIndex == 0;
              final value = isSystolic ? data.systolic : data.diastolic;

              final tooltipText = isSystolic
                  ? 'Systolic: $value'
                  : 'Diastolic: $value\n${DateFormat('MMM dd, HH:mm').format(data.timestamp)}';

              return LineTooltipItem(
                tooltipText,
                TextStyle(
                  color: isSystolic ? const Color(0xFF1976D2) : const Color(0xFF03A9F4),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (event is FlTapUpEvent && touchResponse != null) {
            final touchedSpots = touchResponse.lineBarSpots;
            if (touchedSpots != null && touchedSpots.isNotEmpty) {
              final x = touchedSpots.first.x;
              final index = _getClosestIndexForX(x);

              if (index != null && index >= 0 && index < _timeSeriesData.length) {
                final reading = _getOriginalReading(_timeSeriesData[index]);
                widget.onReadingSelected?.call(reading);
              }
            } else {
              widget.onReadingSelected?.call(null);
            }
          }
        },
        handleBuiltInTouches: true,
      ),
    );
  }

  LineChartData _getEmptyLineChartData() {
    return LineChartData(
      lineBarsData: [],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: 1,
      minY: 60,
      maxY: 200,
    );
  }

  BloodPressureReading? _getOriginalReading(TimeSeriesData data) {
    if (data.originalReadings.isNotEmpty) {
      return data.originalReadings.first;
    }
    return null;
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

  // Calculate X-axis interval to prevent label crowding
  double _calculateXAxisInterval() {
    if (_timeSeriesData.isEmpty) return 1.0;

    final dataCount = _timeSeriesData.length;
    if (dataCount <= 5) return 2.0;  // Show all if few points
    if (dataCount <= 10) return 2.5;  // Show every other
    if (dataCount <= 20) return 3.0;  // Show every third
    return 4.0;  // Show every fourth for many points
  }

  // Determine if a label should be shown to prevent crowding
  bool _shouldShowXAxisLabel(int index) {
    if (_timeSeriesData.isEmpty) return false;

    final dataCount = _timeSeriesData.length;
    final interval = _calculateXAxisInterval().round();

    // Always show first and last labels
    if (index == 0 || index == dataCount - 1) return true;

    // Show labels at regular intervals
    return index % interval == 0;
  }

  // Get the X value for a specific data index
  double _getXValueForIndex(int index) {
    if (_xValueToIndex.isEmpty || index < 0 || index >= _timeSeriesData.length) {
      return 0.0;
    }

    // Find the X value that maps to this index
    for (final entry in _xValueToIndex.entries) {
      if (entry.value == index) {
        return entry.key;
      }
    }

    // Fallback: calculate directly
    if (_timeSeriesData.length == 1) {
      return 5.0;
    }

    return (index / (_timeSeriesData.length - 1)) * 10;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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
}