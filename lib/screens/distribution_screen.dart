import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../providers/dual_chart_provider.dart';
import '../widgets/dual_chart_container.dart';
import '../models/chart_types.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;
  DateTime? _startDate;
  DateTime? _endDate;
  List<BloodPressureReading> _filteredReadings = [];

  @override
  void initState() {
    super.initState();
    // Load readings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodPressureProvider>().loadReadings();
    });
  }

  List<BloodPressureReading> _filterReadingsByTimeRange(List<BloodPressureReading> allReadings) {
    if (allReadings.isEmpty) {
      return [];
    }

    DateTime rangeStart;
    DateTime rangeEnd;

    if (_startDate != null && _endDate != null) {
      rangeStart = _startDate!;
      rangeEnd = _endDate!;
    } else {
      // Calculate based on predefined time range
      final now = DateTime.now();
      switch (_currentTimeRange) {
        case ExtendedTimeRange.day:
          rangeStart = DateTime(now.year, now.month, now.day);
          rangeEnd = rangeStart.add(const Duration(days: 1));
          break;
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
    }

    return allReadings
        .where((reading) =>
            reading.timestamp.isAfter(rangeStart.subtract(const Duration(milliseconds: 1))) &&
            reading.timestamp.isBefore(rangeEnd))
        .toList();
  }

  void _updateFilteredReadings() {
    if (mounted) {
      final provider = context.read<BloodPressureProvider>();
      final filtered = _filterReadingsByTimeRange(provider.readings);
      setState(() {
        _filteredReadings = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure Distribution'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Consumer<BloodPressureProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Error loading data',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => provider.loadReadings(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.readings.isEmpty) {
            return _buildEmptyState();
          }

          // Schedule filtering after build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateFilteredReadings();
          });

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: RefreshIndicator(
              onRefresh: () {
                return provider.loadReadings().then((_) {
                  // Filter again after refresh
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateFilteredReadings();
                  });
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                child: DualChartContainer(
                  readings: _filteredReadings,
                  onTimeRangeChanged: (timeRange, startDate, endDate) {
                    setState(() {
                      _currentTimeRange = timeRange;
                      _startDate = startDate;
                      _endDate = endDate;
                    });
                    // Schedule filtering after state update
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateFilteredReadings();
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg + AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Data Available',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add some blood pressure readings to see the distribution chart',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to add reading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use bottom navigation to go to Add Reading')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Reading'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}