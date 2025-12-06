import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';
import '../services/csv_export_service.dart';
import '../screens/add_reading_screen.dart';
import '../widgets/app_icon.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const AppLogo(showText: true, size: 36),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_download_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            onPressed: () async {
              try {
                final provider = context.read<BloodPressureProvider>();
                await CsvExportService.exportToCsv(provider.readings);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV exported successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to export CSV: $e')),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              AppIcons.more,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            onSelected: (value) {
              _handleMenuAction(context, value);
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(AppIcons.export, size: 18),
                    const SizedBox(width: 12),
                    const Text('Export All Data'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'export_summary',
                child: Row(
                  children: [
                    Icon(AppIcons.analytics, size: 18),
                    const SizedBox(width: 12),
                    const Text('Export Summary'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'export_month',
                child: Row(
                  children: [
                    Icon(Icons.today, size: 18),
                    const SizedBox(width: 12),
                    const Text('Export This Month'),
                  ],
                ),
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
            return _buildErrorState(context, provider.error!);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReadings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Gradient Header Section
                  _buildGradientHeader(context, provider.latestReading),

                  // Main Content
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Metrics Grid
                          if (provider.readings.isNotEmpty) ...[
                            _buildMetricsGrid(context, provider),
                            const SizedBox(height: 24),

                            // Historical Chart Section
                            _buildHistoricalChart(context, provider),
                            const SizedBox(height: 24),

                            // Recent Readings Section
                            _buildSimpleRecentReadingsList(context, provider.recentReadings),
                          ] else ...[
                            _buildEmptyState(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddReadingModal(context);
        },
        icon: const Icon(AppIcons.add),
        label: const Text('Add Reading'),
        elevation: 4,
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
    );
  }

  // New gradient header method
  Widget _buildGradientHeader(BuildContext context, BloodPressureReading? latestReading) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF7C3AED),
            Color(0xFF6D28D9),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Blood Pressure Card
              if (latestReading != null) ...[
                _buildMainBPCard(context, latestReading),
              ] else ...[
                _buildEmptyMainCard(context),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainBPCard(BuildContext context, BloodPressureReading reading) {
    final categoryColor = _getCategoryColor(context, reading.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blood Pressure Values
          Row(
            children: [
              // Systolic
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.systolic.toString(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      'SYSTOLIC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Diastolic
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.diastolic.toString(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      'DIASTOLIC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pulse and Status Row
          Row(
            children: [
              // Pulse
              Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading.heartRate.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const Text(
                        'PULSE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryText(reading.category).toUpperCase(),
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMainCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_border,
            size: 64,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          const Text(
            'No readings yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first blood pressure reading',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, BloodPressureProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available width per card (accounting for spacing)
            final totalSpacing = 12; // Space between columns
            final cardWidth = (constraints.maxWidth - totalSpacing) / 2;

            // Use a safe minimum height that fits within Android constraints
            final cardHeight = 70.0; // Well under the 75.8px limit

            return Column(
              children: [
                // First row
                Row(
                  children: [
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildMetricCard(
                        context,
                        'Systolic',
                        provider.averageSystolic.round().toString(),
                        'mmHg',
                        const Color(0xFFEF4444),
                        Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildMetricCard(
                        context,
                        'Diastolic',
                        provider.averageDiastolic.round().toString(),
                        'mmHg',
                        const Color(0xFF3B82F6),
                        Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Second row
                Row(
                  children: [
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildMetricCard(
                        context,
                        'Pulse',
                        provider.averageHeartRate.round().toString(),
                        'bpm',
                        const Color(0xFFEF4444),
                        Icons.favorite,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildMetricCard(
                        context,
                        'Test Date',
                        _formatTestDate(provider.latestReading?.timestamp),
                        null,
                        const Color(0xFF10B981),
                        Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String? unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity, // Fill the allocated width
      height: double.infinity, // Fill the allocated height
      padding: const EdgeInsets.all(6), // Minimal padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3), // Minimal icon padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  size: 12, // Very small icon
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                size: 10, // Tiny more icon
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
          const SizedBox(height: 2), // Minimal spacing

          // Value and unit row with flexible space
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14, // Smaller font to fit
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 8, // Very small unit text
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Title at bottom
          Text(
            title,
            style: const TextStyle(
              fontSize: 8, // Very small title text
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalChart(BuildContext context, BloodPressureProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historical',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),

          // Simple chart visualization (placeholder for actual chart)
          Container(
            height: 200,
            child: _buildSimpleChart(context, provider.readings),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(BuildContext context, List<BloodPressureReading> readings) {
    if (readings.isEmpty) {
      return const Center(
        child: Text(
          'No data to display',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      );
    }

    // Get last 7 readings for the chart
    final recentReadings = readings.take(7).toList().reversed.toList();

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _BPChartPainter(recentReadings),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load data',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<BloodPressureProvider>().loadReadings(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          const Text(
            'No data yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some readings to see your metrics and history',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTestDate(DateTime? timestamp) {
    if (timestamp == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  
  Widget _buildSimpleRecentReadingsList(BuildContext context, List<BloodPressureReading> recentReadings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Readings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        if (recentReadings.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.history,
                  size: 24,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(width: 12),
                Text(
                  'No recent readings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: recentReadings.take(10).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final reading = entry.value;
                final isLast = index == recentReadings.length - 1 || index == 9;

                return Dismissible(
                  key: ValueKey(reading.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteReading(reading);
                  },
                  background: Container(
                    color: const Color(0xFFEF4444),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            // Date
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${reading.timestamp.day}/${reading.timestamp.month}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // BP Values
                            Expanded(
                              child: Text(
                                '${reading.systolic}/${reading.diastolic}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getCategoryColor(context, reading.category),
                                ),
                              ),
                            ),

                            // Pulse
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${reading.heartRate}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),

                            // Category indicator
                            const SizedBox(width: 12),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(context, reading.category),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          color: Color(0xFFE5E7EB),
                          indent: 20,
                          endIndent: 20,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  
  void _handleMenuAction(BuildContext context, String action) async {
    final provider = context.read<BloodPressureProvider>();

    switch (action) {
      case 'export_csv':
        await _exportCsv(context, provider.readings);
        break;
      case 'export_summary':
        await _exportSummary(context, provider.readings);
        break;
      case 'export_month':
        await _exportMonth(context, provider.readings);
        break;
    }
  }

  Future<void> _exportCsv(BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportToCsv(readings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }

  Future<void> _exportSummary(BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportSummaryStats(readings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Summary exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export summary: $e')),
      );
    }
  }

  Future<void> _exportMonth(BuildContext context, List<BloodPressureReading> readings) async {
    try {
      await CsvExportService.exportCurrentMonth(readings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export monthly data: $e')),
      );
    }
  }

  void _showAddReadingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReadingModalSheet(),
    );
  }

  
  Color _getCategoryColor(BuildContext context, BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return AppTheme.getLowColor(context);
      case BloodPressureCategory.normal:
        return AppTheme.getNormalColor(context);
      case BloodPressureCategory.elevated:
        return AppTheme.getElevatedColor(context);
      case BloodPressureCategory.stage1:
        return AppTheme.getStage1Color(context);
      case BloodPressureCategory.stage2:
        return AppTheme.getStage2Color(context);
      case BloodPressureCategory.crisis:
        return AppTheme.getCrisisColor(context);
    }
  }

  String _getCategoryText(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }

  void _deleteReading(BloodPressureReading reading) {
    final provider = context.read<BloodPressureProvider>();
    provider.deleteReading(reading.id);
  }
}


/// Custom painter for blood pressure chart
class _BPChartPainter extends CustomPainter {
  final List<BloodPressureReading> readings;

  _BPChartPainter(this.readings);

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final padding = const EdgeInsets.all(20);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // Find min and max values for scaling
    int maxSystolic = 140;
    int minSystolic = 100;
    int maxDiastolic = 90;
    int minDiastolic = 60;

    for (final reading in readings) {
      maxSystolic = math.max(maxSystolic, reading.systolic);
      minSystolic = math.min(minSystolic, reading.systolic);
      maxDiastolic = math.max(maxDiastolic, reading.diastolic);
      minDiastolic = math.min(minDiastolic, reading.diastolic);
    }

    // Add some padding to the ranges
    final systolicRange = maxSystolic - minSystolic + 20;
    final diastolicRange = maxDiastolic - minDiastolic + 20;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final textPaint = Paint()
      ..color = const Color(0xFF6B7280)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = padding.top + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );
    }

    // Draw systolic line
    if (readings.isNotEmpty) {
      final systolicPaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final systolicPath = Path();

      for (int i = 0; i < readings.length; i++) {
        final x = padding.left + (chartWidth / (readings.length - 1)) * i;
        final y = padding.top + chartHeight -
                  ((readings[i].systolic - minSystolic + 10) / systolicRange) * chartHeight;

        if (i == 0) {
          systolicPath.moveTo(x, y);
        } else {
          systolicPath.lineTo(x, y);
        }
      }

      canvas.drawPath(systolicPath, systolicPaint);

      // Draw diastolic line
      final diastolicPaint = Paint()
        ..color = const Color(0xFF3B82F6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final diastolicPath = Path();

      for (int i = 0; i < readings.length; i++) {
        final x = padding.left + (chartWidth / (readings.length - 1)) * i;
        final y = padding.top + chartHeight -
                  ((readings[i].diastolic - minDiastolic + 10) / diastolicRange) * chartHeight;

        if (i == 0) {
          diastolicPath.moveTo(x, y);
        } else {
          diastolicPath.lineTo(x, y);
        }
      }

      canvas.drawPath(diastolicPath, diastolicPaint);

      // Draw data points
      for (int i = 0; i < readings.length; i++) {
        final x = padding.left + (chartWidth / (readings.length - 1)) * i;

        // Systolic point
        final systolicY = padding.top + chartHeight -
                         ((readings[i].systolic - minSystolic + 10) / systolicRange) * chartHeight;
        canvas.drawCircle(Offset(x, systolicY), 4, systolicPaint);

        // Diastolic point
        final diastolicY = padding.top + chartHeight -
                          ((readings[i].diastolic - minDiastolic + 10) / diastolicRange) * chartHeight;
        canvas.drawCircle(Offset(x, diastolicY), 4, diastolicPaint);
      }
    }

    // Draw legend
    final legendY = padding.top;

    // Systolic legend
    final systolicLegendPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(size.width - 120, legendY), 4, systolicLegendPaint);
    _drawText(canvas, 'Systolic', size.width - 100, legendY - 6, const Color(0xFF6B7280));

    // Diastolic legend
    final diastolicLegendPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(size.width - 120, legendY + 20), 4, diastolicLegendPaint);
    _drawText(canvas, 'Diastolic', size.width - 100, legendY + 14, const Color(0xFF6B7280));
  }

  void _drawText(Canvas canvas, String text, double x, double y, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Modal bottom sheet for adding new blood pressure readings
class AddReadingModalSheet extends StatelessWidget {
  const AddReadingModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Reading',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Record your blood pressure and heart rate',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add Reading Screen content
              const AddReadingContent(
                isInModal: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}