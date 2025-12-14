import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/blood_pressure_reading.dart';
import '../domain/entities/chart_types.dart';
import '../presentation/providers/dual_chart_provider.dart';
import '../utils/bp_format.dart';
import 'clinical_scatter_plot.dart';
import 'bp_range_bar_chart.dart';

/// Dual Chart Container with synchronized scatter plot and time series chart
class DualChartContainer extends StatefulWidget {
  const DualChartContainer({
    super.key,
    required this.readings,
    this.initialTimeRange = ExtendedTimeRange.month,
    this.startDate,
    this.endDate,
    this.onTimeRangeChanged,
  });

  final List<BloodPressureReading> readings;
  final ExtendedTimeRange initialTimeRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(ExtendedTimeRange, DateTime?, DateTime?)? onTimeRangeChanged;

  @override
  State<DualChartContainer> createState() => _DualChartContainerState();
}

class _DualChartContainerState extends State<DualChartContainer> {
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;
  final GlobalKey _flTimeSeriesChartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentTimeRange = widget.initialTimeRange;
  }

  void _handleTimeRangeChanged(
      ExtendedTimeRange timeRange, DateTime? startDate, DateTime? endDate) {
    setState(() {
      _currentTimeRange = timeRange;
    });
    // fl_chart doesn't need explicit update method, just rebuild
    widget.onTimeRangeChanged?.call(timeRange, startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readings.isEmpty) {
      return _buildAccessibleEmptyState();
    }

    return Semantics(
      label: 'Blood Pressure Analysis Dashboard',
      hint:
          'Comprehensive blood pressure analysis with clinical classification chart and time trends. Use Tab to navigate between sections.',
      child:
          Consumer<DualChartProvider>(builder: (context, chartProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Dynamic spacing based on screen size
            final isMobile = constraints.maxWidth < 400;
            final spacing = isMobile ? 8.0 : 16.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Range Selector (shared between both charts)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: _buildSharedTimeRangeSelector(chartProvider),
                ),

                SizedBox(height: spacing * 2),

                // Clinical Scatter Plot
                Container(
                  height: kClinicalScatterChartHeight * 1.3, // Increase height by 30%
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Reduced padding
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: chartProvider.hasSelection
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Blood Pressure Distribution',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: chartProvider.hasSelection
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                ),
                              ),
                              if (chartProvider.hasSelection) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Row(
                              key: ValueKey(chartProvider.hasSelection),
                              children: [
                                Expanded(
                                  child: Text(
                                    chartProvider.hasSelection
                                        ? 'Selected: ${_formatReading(chartProvider.selectedReading!)}'
                                        : 'Tap data points to see details in the timeline below',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: chartProvider.hasSelection
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.grey[600],
                                          fontWeight: chartProvider.hasSelection
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ClinicalScatterPlot(
                            readings: widget.readings,
                            selectedReading: chartProvider.selectedReading,
                            onReadingSelected: chartProvider.selectReading,
                            showTrendLine: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: spacing * 2),

                // Blood Pressure Range Bar Chart
                Container(
                  height: kClinicalScatterChartHeight * 0.533,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: BPRangeBarChart(
                    key: _flTimeSeriesChartKey,
                    readings: widget.readings,
                    selectedReading: chartProvider.selectedReading,
                    onReadingSelected: chartProvider.selectReading,
                    initialTimeRange: _currentTimeRange,
                    startDate: widget.startDate,
                    endDate: widget.endDate,
                    onTimeRangeChanged: _handleTimeRangeChanged,
                    showTimeRangeSelector: false,
                    currentTimeRange: _currentTimeRange,
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  
  Widget _buildSharedTimeRangeSelector(DualChartProvider chartProvider) {
    final isMobile = MediaQuery.of(context).size.width < 400;
    final isSmallMobile = MediaQuery.of(context).size.width < 360;

    // Segmented buttons should span available horizontal space evenly
    // according to Material Design 3 guidelines
    Widget selectorWidget;

    if (isMobile) {
      // For mobile, use abbreviated labels but still span the full width
      List<ButtonSegment<ExtendedTimeRange>> mobileSegments = [
        const ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.week,
          label: Text('W'),
        ),
        const ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.month,
          label: Text('M'),
        ),
      ];

      if (!isSmallMobile) {
        mobileSegments.add(
          const ButtonSegment<ExtendedTimeRange>(
            value: ExtendedTimeRange.season,
            label: Text('S'),
          ),
        );
      }

      selectorWidget = SegmentedButton<ExtendedTimeRange>(
        segments: mobileSegments,
        selected: {_currentTimeRange},
        onSelectionChanged: (Set<ExtendedTimeRange> selection) {
          if (selection.isNotEmpty) {
            _handleTimeRangeChanged(
                selection.first, widget.startDate, widget.endDate);
          }
        },
      );
    } else {
      // For larger screens, use all segments with full width expansion
      List<ButtonSegment<ExtendedTimeRange>> segments = [
        const ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.week,
          label: Text('Week'),
        ),
        const ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.month,
          label: Text('Month'),
        ),
        const ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.season,
          label: Text('Season'),
        ),
        const ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.year,
          label: Text('Year'),
        ),
      ];

      selectorWidget = SegmentedButton<ExtendedTimeRange>(
        segments: segments,
        selected: {_currentTimeRange},
        onSelectionChanged: (Set<ExtendedTimeRange> selection) {
          if (selection.isNotEmpty) {
            _handleTimeRangeChanged(
                selection.first, widget.startDate, widget.endDate);
          }
        },
      );
    }

    return Container(
      width: double.infinity, // Ensure container spans full width
      // decoration: BoxDecoration(
      //   color: Theme.of(context).colorScheme.surface,
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
      //     width: 1,
      //   ),
      // ),
      padding: const EdgeInsets.all(2.0),
      child: selectorWidget,
    );
  }

  String _getCurrentRangeLabel() {
    switch (_currentTimeRange) {
      case ExtendedTimeRange.week:
        return 'Weekly View';
      case ExtendedTimeRange.month:
        return 'Monthly View';
      case ExtendedTimeRange.season:
        return 'Seasonal View';
      case ExtendedTimeRange.year:
        return 'Yearly View';
    }
  }

  String _formatReading(BloodPressureReading reading) {
    final category = reading.category.name.toUpperCase();
    return '${formatBloodPressure(reading.systolic, reading.diastolic)} ($category)';
  }

  // Accessibility helper methods
  Widget _buildAccessibleEmptyState() {
    return Semantics(
      label: 'No blood pressure data available',
      hint:
          'Start recording blood pressure readings to see comprehensive analysis with clinical classification and trends',
      child: _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Blood Pressure Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start recording your blood pressure to see comprehensive analysis\nincluding distribution patterns and trends over time.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Icon(
            Icons.insights,
            size: 32,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Text(
            'Dual Chart System',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Clinical Distribution + Time Series Trends',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
        ],
      ),
    );
  }
}
