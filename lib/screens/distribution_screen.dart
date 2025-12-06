import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../providers/dual_chart_provider.dart';
import '../widgets/dual_chart_container.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {

  @override
  void initState() {
    super.initState();
    // Load readings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodPressureProvider>().loadReadings();
    });
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading data',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
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

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: RefreshIndicator(
              onRefresh: () => provider.loadReadings(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                child: DualChartContainer(
                  readings: provider.readings,
                  onTimeRangeChanged: (timeRange, startDate, endDate) {
                    // Optional: Handle time range changes
                    // Could filter provider.readings based on selected range
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
          padding: const EdgeInsets.all(32.0),
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