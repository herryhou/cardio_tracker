import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blood_pressure_reading.dart';
import '../providers/dual_chart_provider.dart';
import 'clinical_scatter_plot.dart';
import 'time_series_chart.dart';

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
  final GlobalKey<TimeSeriesChartState> _timeSeriesChartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentTimeRange = widget.initialTimeRange;
  }

  void _handleTimeRangeChanged(ExtendedTimeRange timeRange, DateTime? startDate, DateTime? endDate) {
    setState(() {
      _currentTimeRange = timeRange;
    });
    // Update time series chart
    _timeSeriesChartKey.currentState?.updateTimeRange(timeRange, startDate, endDate);
    widget.onTimeRangeChanged?.call(timeRange, startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readings.isEmpty) {
      return _buildAccessibleEmptyState();
    }

    return Semantics(
      label: 'Blood Pressure Analysis Dashboard',
      hint: 'Comprehensive blood pressure analysis with clinical classification chart and time trends. Use Tab to navigate between sections.',
      child: Consumer<DualChartProvider>(
        builder: (context, chartProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Enhanced responsive breakpoints
            final isMobile = constraints.maxWidth < 400;
            final isSmallMobile = constraints.maxWidth < 360;
            final isTablet = constraints.maxWidth > 600;
            final isLargeTablet = constraints.maxWidth > 900;
            final isDesktop = constraints.maxWidth > 1200;

            // Dynamic height calculations based on screen size
            final availableHeight = constraints.maxHeight;
            final headerHeight = isMobile ? 80.0 : 100.0;
            final timeRangeHeight = isMobile ? 50.0 : 60.0;
            final spacing = isMobile ? 8.0 : 16.0;

            // Calculate scatter plot height (60% of available space on mobile, 80% on tablet) - doubled
            final scatterHeight = isMobile
                ? (availableHeight - headerHeight - timeRangeHeight - spacing * 2) * 0.6
                : isLargeTablet
                    ? 800.0  // Doubled from 400
                    : (availableHeight - headerHeight - timeRangeHeight - spacing * 2) * 0.8;

            // Cap minimum heights for usability - doubled
            final finalScatterHeight = scatterHeight.clamp(isMobile ? 360.0 : 560.0, isMobile ? 560.0 : 900.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and clear selection button
                _buildHeader(chartProvider),

                SizedBox(height: spacing),

                // Time Range Selector (shared between both charts)
                _buildSharedTimeRangeSelector(chartProvider),

                SizedBox(height: spacing * 2),

                // Clinical Scatter Plot
                Container(
                  height: finalScatterHeight,
                  margin: EdgeInsets.only(bottom: spacing),
                  child: Card(
                    elevation: chartProvider.hasSelection ? 6 : 2,
                    shadowColor: chartProvider.hasSelection
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: chartProvider.hasSelection
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: chartProvider.hasSelection
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Blood Pressure Distribution',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: chartProvider.hasSelection
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
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
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              chartProvider.hasSelection
                                  ? 'Selected: ${_formatReading(chartProvider.selectedReading!)}'
                                  : 'Tap data points to see details in the timeline below',
                              key: ValueKey(chartProvider.hasSelection),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: chartProvider.hasSelection
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[600],
                                fontWeight: chartProvider.hasSelection
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ClinicalScatterPlot(
                              readings: widget.readings,
                              selectedReading: chartProvider.selectedReading,
                              onReadingSelected: chartProvider.selectReading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Time Series Chart
                Container(
                  height: finalScatterHeight * 0.8, // 0.8x the scatter plot height
                  child: Card(
                    elevation: chartProvider.hasSelection ? 6 : 2,
                    shadowColor: chartProvider.hasSelection
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: chartProvider.hasSelection
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: chartProvider.hasSelection
                            ? LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              )
                            : null,
                      ),
                      child: TimeSeriesChart(
                        key: _timeSeriesChartKey,
                        readings: widget.readings,
                        selectedReading: chartProvider.selectedReading,
                        onReadingSelected: chartProvider.selectReading,
                        initialTimeRange: _currentTimeRange,
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                        onTimeRangeChanged: _handleTimeRangeChanged,
                        showTimeRangeSelector: false,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildHeader(DualChartProvider chartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Pressure Analysis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.readings.length} readings • ${_getCurrentRangeLabel()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        if (chartProvider.hasSelection)
          TextButton.icon(
            onPressed: chartProvider.clearSelection,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear Selection'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
      ],
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
          value: ExtendedTimeRange.day,
          label: Text('D'),
        ),
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
            _handleTimeRangeChanged(selection.first, widget.startDate, widget.endDate);
          }
        },
      );
    } else {
      // For larger screens, use all segments with full width expansion
      List<ButtonSegment<ExtendedTimeRange>> segments = [
        const ButtonSegment<ExtendedTimeRange>(
          value: ExtendedTimeRange.day,
          label: Text('Day'),
        ),
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
            _handleTimeRangeChanged(selection.first, widget.startDate, widget.endDate);
          }
        },
      );
    }

    return Container(
      width: double.infinity, // Ensure container spans full width
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(isMobile ? 2.0 : 4.0),
      child: selectorWidget,
    );
  }

  
  String _getCurrentRangeLabel() {
    switch (_currentTimeRange) {
      case ExtendedTimeRange.day:
        return 'Daily View';
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
    return '${reading.systolic}/${reading.diastolic} mmHg ($category)';
  }

  // Accessibility helper methods
  Widget _buildAccessibleEmptyState() {
    return Semantics(
      label: 'No blood pressure data available',
      hint: 'Start recording blood pressure readings to see comprehensive analysis with clinical classification and trends',
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