import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/semantics.dart';
import '../models/blood_pressure_reading.dart';
import '../models/chart_types.dart';
import '../providers/dual_chart_provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../widgets/clinical_scatter_plot.dart';
import '../widgets/bp_range_bar_chart.dart';
import '../widgets/swipe_hint.dart';

/// Horizontal scrollable charts container for dashboard
class HorizontalChartsContainer extends StatefulWidget {
  const HorizontalChartsContainer({
    super.key,
    required this.readings,
    this.showSwipeHint = true,
  });

  final List<BloodPressureReading> readings;
  final bool showSwipeHint;

  @override
  State<HorizontalChartsContainer> createState() =>
      _HorizontalChartsContainerState();
}

class _HorizontalChartsContainerState extends State<HorizontalChartsContainer> {
  late final PageController _pageController;
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;
  bool _showSwipeHint = true;

  static const List<Map<String, String>> _chartInfo = [
    {
      'title': 'Trends',
      'description': 'Track your blood pressure over time',
    },
    {
      'title': 'Distribution',
      'description': 'See readings in clinical zones',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _loadHintState();
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

        // Swipe hint (only show on first visit)
        if (_showSwipeHint && widget.showSwipeHint) ...[
          const SwipeHint(disableAnimation: true),
          const SizedBox(height: 8),
        ],

        // Horizontal scrollable charts
        SizedBox(
          height: 320,
          child: Consumer2<BloodPressureProvider, DualChartProvider>(
            builder: (context, bpProvider, chartProvider, child) {
              // Filter readings for current time range
              final filteredReadings =
                  _filterReadingsByTimeRange(widget.readings);

              return PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _showSwipeHint = false;
                  });
                  _saveHintState();
                  SemanticsService.announce(
                    'Now showing ${_chartInfo[index]['title']} chart',
                    TextDirection.ltr,
                  );
                },
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Semantics(
                    label: 'Chart ${index + 1} of 2: ${_chartInfo[index]['title']}',
                    hint: 'Swipe left or right to see other charts',
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _chartInfo[index]['title']!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _chartInfo[index]['description']!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: index == 0
                                  ? BPRangeBarChart(
                                      readings: filteredReadings,
                                      selectedReading: chartProvider.selectedReading,
                                      onReadingSelected: chartProvider.selectReading,
                                      initialTimeRange: _currentTimeRange,
                                      showTimeRangeSelector: false,
                                      currentTimeRange: _currentTimeRange,
                                    )
                                  : InteractiveScatterPlot(
                                      readings: filteredReadings,
                                      selectedReading: chartProvider.selectedReading,
                                      onReadingSelected: chartProvider.selectReading,
                                      showResetButton: false,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Page indicator
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageController,
          count: 2,
          effect: ExpandingDotsEffect(
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Theme.of(context).colorScheme.outline,
            dotHeight: 8,
            dotWidth: 8,
            expansionFactor: 3,
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

  void _loadHintState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHint = prefs.getBool('has_seen_swipe_hint') ?? false;
    if (mounted) {
      setState(() {
        _showSwipeHint = !hasSeenHint;
      });
    }
  }

  void _saveHintState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_swipe_hint', true);
  }

  }
