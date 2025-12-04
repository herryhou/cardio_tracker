import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  String _selectedTimeFilter = 'All';

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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _selectedTimeFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All Time'),
              ),
              const PopupMenuItem<String>(
                value: 'Month',
                child: Text('This Month'),
              ),
              const PopupMenuItem<String>(
                value: 'Season',
                child: Text('This Season'),
              ),
              const PopupMenuItem<String>(
                value: 'Year',
                child: Text('This Year'),
              ),
            ],
          ),
        ],
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

          final filteredReadings = _getFilteredReadings(provider.readings);

          if (filteredReadings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReadings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(filteredReadings),
                  const SizedBox(height: 16),

                  // Scatter Plot Chart
                  _buildScatterPlotChart(filteredReadings),
                  const SizedBox(height: 16),

                  // Legend
                  _buildLegend(),
                  const SizedBox(height: 16),

                  // Zone Analysis
                  _buildZoneAnalysis(filteredReadings),
                ],
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
                Icons.scatter_plot,
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

  Widget _buildSummaryCards(List<BloodPressureReading> readings) {
    final zoneCounts = _getZoneCounts(readings);

    return Row(
      children: [
        Expanded(child: _buildZoneCard('Normal', zoneCounts['normal'] ?? 0, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildZoneCard('Elevated', zoneCounts['elevated'] ?? 0, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _buildZoneCard('High', zoneCounts['high'] ?? 0, Colors.red)),
      ],
    );
  }

  Widget _buildZoneCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScatterPlotChart(List<BloodPressureReading> readings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Pressure Distribution with Medical Zones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zone indicators below chart show blood pressure categories',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: ScatterChart(
                ScatterChartData(
                  scatterSpots: readings.map<ScatterSpot>((reading) {
                    final category = reading.category;
                    return ScatterSpot(
                      reading.systolic.toDouble(),
                      reading.diastolic.toDouble(),
                      color: _getCategoryColor(category),
                      radius: 6,
                    );
                  }).cast<ScatterSpot>().toList(),
                  minX: 70,
                  maxX: 200,
                  minY: 40,
                  maxY: 140,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    verticalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      // Highlight important boundaries
                      if (value == 80 || value == 90 || value == 120) {
                        return FlLine(
                          color: _getBoundaryLineColor(value),
                          strokeWidth: 2,
                        );
                      }
                      return FlLine(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      // Highlight important boundaries
                      if (value == 120 || value == 130 || value == 140 || value == 180) {
                        return FlLine(
                          color: _getBoundaryLineColor(value),
                          strokeWidth: 2,
                        );
                      }
                      return FlLine(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          Color? textColor;
                          FontWeight? fontWeight;

                          // Highlight important values
                          if (value == 80) {
                            textColor = Colors.orange;
                            fontWeight = FontWeight.bold;
                          } else if (value == 90) {
                            textColor = Colors.red;
                            fontWeight = FontWeight.bold;
                          } else if (value == 120) {
                            textColor = Colors.purple;
                            fontWeight = FontWeight.bold;
                          }

                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: fontWeight ?? FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          Color? textColor;
                          FontWeight? fontWeight;

                          // Highlight important values
                          if (value == 120) {
                            textColor = Colors.orange;
                            fontWeight = FontWeight.bold;
                          } else if (value == 130) {
                            textColor = Colors.deepOrange;
                            fontWeight = FontWeight.bold;
                          } else if (value == 140) {
                            textColor = Colors.red;
                            fontWeight = FontWeight.bold;
                          } else if (value == 180) {
                            textColor = Colors.purple;
                            fontWeight = FontWeight.bold;
                          }

                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: fontWeight ?? FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Systolic (mmHg)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Diastolic (mmHg)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Add zone indicators below the chart
            _buildZoneIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Pressure Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendItem('Normal', '< 120 / < 80', Colors.green),
            _buildLegendItem('Elevated', '121-129 / < 80', Colors.orange),
            _buildLegendItem('Stage 1', '130-139 / 80-89', Colors.deepOrange),
            _buildLegendItem('Stage 2', '≥ 140 / ≥ 90', Colors.red),
            _buildLegendItem('Crisis', '≥ 180 / ≥ 120', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              range,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneAnalysis(List<BloodPressureReading> readings) {
    final zoneCounts = _getZoneCounts(readings);
    final total = readings.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zone Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const Text('No data to analyze')
            else ...[
              _buildAnalysisRow('Normal', zoneCounts['normal'] ?? 0, total, Colors.green),
              _buildAnalysisRow('Elevated', zoneCounts['elevated'] ?? 0, total, Colors.orange),
              _buildAnalysisRow('Stage 1', zoneCounts['stage1'] ?? 0, total, Colors.deepOrange),
              _buildAnalysisRow('Stage 2', zoneCounts['stage2'] ?? 0, total, Colors.red),
              _buildAnalysisRow('Crisis', zoneCounts['crisis'] ?? 0, total, Colors.purple),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              '$count readings',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BloodPressureReading> _getFilteredReadings(List<BloodPressureReading> readings) {
    final now = DateTime.now();

    switch (_selectedTimeFilter) {
      case 'Month':
        final monthAgo = now.subtract(const Duration(days: 30));
        return readings.where((r) => r.timestamp.isAfter(monthAgo)).toList();
      case 'Season':
        final seasonAgo = now.subtract(const Duration(days: 90));
        return readings.where((r) => r.timestamp.isAfter(seasonAgo)).toList();
      case 'Year':
        final yearAgo = now.subtract(const Duration(days: 365));
        return readings.where((r) => r.timestamp.isAfter(yearAgo)).toList();
      default:
        return readings;
    }
  }

  Map<String, int> _getZoneCounts(List<BloodPressureReading> readings) {
    final counts = <String, int>{
      'normal': 0,
      'elevated': 0,
      'stage1': 0,
      'stage2': 0,
      'crisis': 0,
    };

    for (final reading in readings) {
      switch (reading.category) {
        case BloodPressureCategory.normal:
          counts['normal'] = (counts['normal'] ?? 0) + 1;
          break;
        case BloodPressureCategory.elevated:
          counts['elevated'] = (counts['elevated'] ?? 0) + 1;
          break;
        case BloodPressureCategory.stage1:
          counts['stage1'] = (counts['stage1'] ?? 0) + 1;
          break;
        case BloodPressureCategory.stage2:
          counts['stage2'] = (counts['stage2'] ?? 0) + 1;
          break;
        case BloodPressureCategory.crisis:
          counts['crisis'] = (counts['crisis'] ?? 0) + 1;
          break;
        case BloodPressureCategory.low:
          // Count low readings as normal for simplicity
          counts['normal'] = (counts['normal'] ?? 0) + 1;
          break;
      }
    }

    return counts;
  }

  Color _getCategoryColor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return Colors.blue;
      case BloodPressureCategory.normal:
        return Colors.green;
      case BloodPressureCategory.elevated:
        return Colors.orange;
      case BloodPressureCategory.stage1:
        return Colors.deepOrange;
      case BloodPressureCategory.stage2:
        return Colors.red;
      case BloodPressureCategory.crisis:
        return Colors.purple;
    }
  }

  /// Get boundary line color based on value
  Color _getBoundaryLineColor(double value) {
    switch (value.toInt()) {
      case 80: // Diastolic boundary
        return Colors.orange.withOpacity(0.4);
      case 90: // Diastolic boundary
        return Colors.red.withOpacity(0.4);
      case 120: // Both systolic and diastolic boundary
        return Colors.purple.withOpacity(0.4);
      case 130: // Systolic boundary
        return Colors.deepOrange.withOpacity(0.4);
      case 140: // Systolic boundary
        return Colors.red.withOpacity(0.4);
      case 180: // Crisis threshold
        return Colors.purple.withOpacity(0.4);
      default:
        return Colors.grey.withOpacity(0.4);
    }
  }

  /// Build zone indicators showing blood pressure categories
  Widget _buildZoneIndicators() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Normal zone
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Normal\n<120/<80',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ),
          ),
          // Elevated zone
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Elevated\n121-129\n<80',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ),
          ),
          // Stage 1 zone
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                border: Border.all(
                  color: Colors.deepOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Stage 1\n130-139/\n80-89',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
              ),
            ),
          ),
          // Stage 2 zone
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Stage 2\n≥140/≥90',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ),
          // Crisis zone
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Crisis\n≥180/≥120',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}