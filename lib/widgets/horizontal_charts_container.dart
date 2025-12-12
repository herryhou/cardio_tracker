import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blood_pressure_reading.dart';
import '../models/chart_types.dart';
import '../providers/dual_chart_provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../widgets/clinical_scatter_plot.dart';
import '../widgets/bp_range_bar_chart.dart';
import '../widgets/bp_legend.dart';

/// Horizontal scrollable charts container for dashboard
class HorizontalChartsContainer extends StatefulWidget {
  const HorizontalChartsContainer({
    super.key,
    required this.readings,
  });

  final List<BloodPressureReading> readings;

  @override
  State<HorizontalChartsContainer> createState() =>
      _HorizontalChartsContainerState();
}

class _HorizontalChartsContainerState extends State<HorizontalChartsContainer> {
  late final PageController _pageController;
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readings.isEmpty) {
      return Container(
        height: 320,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Card(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No Data Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add readings to see charts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Common Time Range Selector (applies to both charts)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ExtendedTimeRange>(
            segments: const [
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
              }
            },
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal scrollable charts
        SizedBox(
          height: 320,
          child: Consumer2<BloodPressureProvider, DualChartProvider>(
            builder: (context, bpProvider, chartProvider, child) {
              // Filter readings for current time range
              final filteredReadings =
                  _filterReadingsByTimeRange(widget.readings);

              return PageView(
                controller: _pageController,
                children: [
                  // BP Range Bar Chart (Trends)
                  Container(
                    margin: const EdgeInsets.all(0),
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: BPRangeBarChart(
                        readings: filteredReadings,
                        selectedReading: chartProvider.selectedReading,
                        onReadingSelected: chartProvider.selectReading,
                        initialTimeRange: _currentTimeRange,
                        showTimeRangeSelector: false,
                        currentTimeRange: _currentTimeRange,
                      ),
                    ),
                  ),
                  // Clinical Scatter Plot
                  Container(
                    margin: const EdgeInsets.all(0),
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InteractiveScatterPlot(
                        readings: filteredReadings,
                        selectedReading: chartProvider.selectedReading,
                        onReadingSelected: chartProvider.selectReading,
                        showResetButton: false,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<BloodPressureReading> _filterReadingsByTimeRange(
      List<BloodPressureReading> allReadings) {
    if (allReadings.isEmpty) {
      return [];
    }

    final now = DateTime.now();
    DateTime rangeStart;
    DateTime rangeEnd;

    switch (_currentTimeRange) {
      case ExtendedTimeRange.week:
        rangeStart = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        rangeEnd = rangeStart.add(const Duration(days: 7));
        break;
      case ExtendedTimeRange.month:
        rangeStart = DateTime(now.year, now.month, 1);
        int nextMonth = now.month + 1;
        int nextYear = now.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        rangeEnd = DateTime(nextYear, nextMonth, 1);
        break;
      case ExtendedTimeRange.season:
        rangeStart = now.subtract(const Duration(days: 90));
        rangeEnd = now.add(const Duration(days: 1));
        break;
      case ExtendedTimeRange.year:
        rangeStart = DateTime(now.year, 1, 1);
        rangeEnd = DateTime(now.year + 1, 1, 1);
        break;
    }

    return allReadings
        .where((reading) =>
            reading.timestamp.isAfter(
                rangeStart.subtract(const Duration(milliseconds: 1))) &&
            reading.timestamp.isBefore(rangeEnd))
        .toList();
  }

  String _getCurrentRangeLabel() {
    switch (_currentTimeRange) {
      case ExtendedTimeRange.week:
        return 'Last 7 days';
      case ExtendedTimeRange.month:
        return 'This month';
      case ExtendedTimeRange.season:
        return 'Last 3 months';
      case ExtendedTimeRange.year:
        return 'This year';
    }
  }
}
