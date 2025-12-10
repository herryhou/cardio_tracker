import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';
import '../services/csv_export_service.dart';
import '../services/manual_sync_service.dart';
import '../screens/add_reading_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/cloudflare_settings_screen.dart';
import '../widgets/app_icon.dart';
import '../widgets/recent_reading_item.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ManualSyncService _syncService = ManualSyncService();

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const AppLogo(showText: true, size: 36),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: false,
        actions: [
          // Cloudflare sync status indicator
          FutureBuilder<bool>(
            future: _syncService.isSyncAvailable(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (snapshot.hasError) {
                // Silently handle error, don't show sync button
                return const SizedBox.shrink();
              }

              if (snapshot.hasData && snapshot.data == true) {
                return Container(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  child: IconButton(
                    icon: Icon(
                      Icons.cloud_sync_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CloudflareSettingsScreen(),
                        ),
                      );
                    },
                    tooltip: 'Cloudflare Sync',
                    padding: EdgeInsets.zero,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: IconButton(
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
              padding: EdgeInsets.zero,
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: PopupMenuButton<String>(
              icon: Icon(
                AppIcons.more,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              onSelected: (value) {
                _handleMenuAction(context, value);
              },
            itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings, size: 18),
                      SizedBox(width: AppSpacing.cardsGap),
                      const Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'export_csv',
                  child: Row(
                    children: [
                      Icon(AppIcons.export, size: 18),
                      SizedBox(width: AppSpacing.cardsGap),
                      const Text('Export All Data'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'export_summary',
                  child: Row(
                    children: [
                      Icon(AppIcons.analytics, size: 18),
                      SizedBox(width: AppSpacing.cardsGap),
                      const Text('Export Summary'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'export_month',
                  child: Row(
                    children: [
                      Icon(Icons.today, size: 18),
                      SizedBox(width: AppSpacing.cardsGap),
                      const Text('Export This Month'),
                    ],
                  ),
                ),
              ],
            ),
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
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: AppSpacing.cardPaddingInsets,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Historical Chart Section - full-width
                          if (provider.readings.isNotEmpty) ...[
                            _buildHistoricalChart(context, provider),
                            SizedBox(height: AppSpacing.sectionGap),

                            // Recent Readings Section
                            _buildSimpleRecentReadingsList(
                                context, provider.recentReadings),
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
      floatingActionButton: Container(
        constraints: const BoxConstraints(
          minWidth: 56,
          minHeight: 56,
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            _showAddReadingModal(context);
          },
          icon: const Icon(AppIcons.add),
          label: const Text('New'),
          elevation: 4,
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // New gradient header method - simplified without greeting
  Widget _buildGradientHeader(
      BuildContext context, BloodPressureReading? latestReading) {
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
          padding: AppSpacing.cardPaddingInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Blood Pressure Card - enlarged (2x height)
              if (latestReading != null) ...[
                _buildMainBPCard(context, latestReading),
              ] else ...[
                _buildEmptyMainCard(context),
              ],
              SizedBox(height: AppSpacing.md + AppSpacing.xs),
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
      padding: EdgeInsets.all(5 * AppSpacing.gridUnit), // Increased padding for larger card
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
          // Blood Pressure Values - enlarged
          Row(
            children: [
              // Systolic
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.systolic.toString(),
                      style: AppTheme.displayStyle.copyWith(
                        fontSize: 48, // Override display size for this specific context
                        color: categoryColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'Systolic',
                      style: AppTheme.bodyStyle.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.lg + AppSpacing.xs), // Increased spacing
              // Diastolic
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.diastolic.toString(),
                      style: AppTheme.displayStyle.copyWith(
                        fontSize: 48, // Override display size for this specific context
                        color: categoryColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'Diastolic',
                      style: AppTheme.bodyStyle.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xl + AppSpacing.md), // Increased spacing

          // Mini 7-day sparkline trend
          Container(
            height: 60, // Small height for sparkline
            child: _buildMiniSparkline(context, reading),
          ),

          SizedBox(height: AppSpacing.lg + AppSpacing.sm), // Increased spacing

          // Pulse and Status Row - enlarged
          Row(
            children: [
              // Pulse
              Row(
                children: [
                  HeartIcon(
                    size: 28, // Increased from 20
                    color: const Color(0xFFEF4444),
                  ),
                  SizedBox(width: AppSpacing.cardsGap), // Increased spacing
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading.heartRate.toString(),
                        style: const TextStyle(
                          fontSize: 32, // Increased from 20
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Pulse',
                        style: AppTheme.bodyStyle.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Status Badge - enlarged
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + AppSpacing.xs), // Increased padding
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16), // Increased radius
                ),
                child: Text(
                  _getCategoryText(reading.category),
                  style: AppTheme.headerStyle.copyWith(
                    color: categoryColor,
                    fontSize: 16, // Override header size for this context
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
      padding: EdgeInsets.all(AppSpacing.xl + AppSpacing.md), // Increased padding for larger empty card
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
            size: 96, // Increased size
            color: Color(0xFFD1D5DB),
          ),
          SizedBox(height: AppSpacing.sectionGap),
          const Text(
            'No readings yet',
            style: TextStyle(
              fontSize: 28, // Increased size
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: AppSpacing.cardsGap),
          const Text(
            'Add your first blood pressure reading',
            style: TextStyle(
              fontSize: 18, // Increased size
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // Mini 7-day sparkline trend widget
  Widget _buildMiniSparkline(BuildContext context, BloodPressureReading reading) {
    // For now, return a placeholder - this would show the last 7 readings as a sparkline
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '7-day trend',
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(
      BuildContext context, BloodPressureProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTheme.headerStyle.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: AppSpacing.md),
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
                    SizedBox(width: AppSpacing.cardsGap),
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
                SizedBox(height: AppSpacing.cardsGap),
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
                        null, // Passing null to use custom HeartIcon in the widget
                      ),
                    ),
                    SizedBox(width: AppSpacing.cardsGap),
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
    IconData? icon,
  ) {
    return Container(
      width: double.infinity, // Fill the allocated width
      height: double.infinity, // Fill the allocated height
      padding: EdgeInsets.all(AppSpacing.xs + AppSpacing.xs/2), // Minimal padding
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
                padding: EdgeInsets.all(AppSpacing.xs/2), // Minimal icon padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: icon == null
                    ? HeartIcon(
                        size: 12,
                        color: color,
                      )
                    : Icon(
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
          SizedBox(height: AppSpacing.xs/2), // Minimal spacing

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
                  SizedBox(width: AppSpacing.xs/2),
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

  Widget _buildHistoricalChart(
      BuildContext context, BloodPressureProvider provider) {
    return Container(
      padding: AppSpacing.cardPaddingInsets,
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
          Text(
            'Historical',
            style: AppTheme.headerStyle.copyWith(
              color: const Color(0xFF1F2937),
              fontSize: 18, // Override header size for this context
            ),
          ),
          SizedBox(height: AppSpacing.md + AppSpacing.xs),

          // Simple chart visualization (placeholder for actual chart)
          Container(
            height: 200,
            child: _buildSimpleChart(context, provider.readings),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(
      BuildContext context, List<BloodPressureReading> readings) {
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
        padding: EdgeInsets.all(AppSpacing.lg + AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.cardPaddingInsets,
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
            SizedBox(height: AppSpacing.sectionGap),
            Text(
              'Unable to load data',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: AppSpacing.cardsGap),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            SizedBox(height: AppSpacing.sectionGap),
            FilledButton.icon(
              onPressed: () =>
                  context.read<BloodPressureProvider>().loadReadings(),
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
      padding: EdgeInsets.all(AppSpacing.xl + AppSpacing.md),
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
          SizedBox(height: AppSpacing.md),
          const Text(
            'No data yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
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

  Widget _buildSimpleRecentReadingsList(
      BuildContext context, List<BloodPressureReading> recentReadings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Readings',
          style: AppTheme.headerStyle.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        if (recentReadings.isEmpty)
          Container(
            padding: AppSpacing.cardPaddingInsets,
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

                return Column(
                  children: [
                    RecentReadingItem(
                      reading: reading,
                      onDelete: () => _deleteReading(reading),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        color: Color(0xFFE5E7EB),
                        indent: 20,
                        endIndent: 20,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  
  // Helper method for compact date formatting
  String _formatCompactDate(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (timestamp.year == now.year) {
      return '${timestamp.month}/${timestamp.day}';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year % 100}';
    }
  }

  // Helper method for time formatting
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(BuildContext context, String action) async {
    final provider = context.read<BloodPressureProvider>();

    switch (action) {
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
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

  Future<void> _exportCsv(
      BuildContext context, List<BloodPressureReading> readings) async {
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

  Future<void> _exportSummary(
      BuildContext context, List<BloodPressureReading> readings) async {
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

  Future<void> _exportMonth(
      BuildContext context, List<BloodPressureReading> readings) async {
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

  Color _getCategoryColor(
      BuildContext context, BloodPressureCategory category) {
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

  // Helper method for safe value calculation
  double safeValue(double value) => value.isFinite ? value : 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final padding = AppSpacing.cardPaddingInsets;
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

    // Draw vertical grid lines
    if (readings.length > 1) {
      for (int i = 0; i < readings.length; i++) {
        final x = padding.left + (chartWidth / (readings.length - 1)) * i;
        canvas.drawLine(
          Offset(x, padding.top),
          Offset(x, size.height - padding.bottom),
          gridPaint,
        );
      }
    }

    // Draw line charts for systolic and diastolic
    if (readings.isNotEmpty) {
      if (readings.length == 1) {
        // For single reading, just draw a point
        final x = padding.left + chartWidth / 2;
        final systolicY = safeValue(
          padding.top + chartHeight -
          ((readings[0].systolic - minSystolic + 10) / systolicRange) * chartHeight
        );
        final diastolicY = safeValue(
          padding.top + chartHeight -
          ((readings[0].diastolic - minDiastolic + 10) / diastolicRange) * chartHeight
        );

        // Draw points
        final systolicPaint = Paint()
          ..color = const Color(0xFFEF4444)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, systolicY), 6, systolicPaint);

        final diastolicPaint = Paint()
          ..color = const Color(0xFF3B82F6)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, diastolicY), 6, diastolicPaint);

        // Draw values
        _drawText(
          canvas,
          '${readings[0].systolic}',
          x,
          systolicY - 15,
          const Color(0xFFEF4444)
        );
        _drawText(
          canvas,
          '${readings[0].diastolic}',
          x,
          diastolicY + 15,
          const Color(0xFF3B82F6)
        );
        _drawText(
          canvas,
          '${readings[0].heartRate}',
          x,
          (systolicY + diastolicY) / 2,
          const Color(0xFF10B981)
        );
      } else {
        // Draw systolic line
        final systolicPath = Path();
        final systolicPaint = Paint()
          ..color = const Color(0xFFEF4444)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < readings.length; i++) {
          final x = padding.left + (chartWidth / (readings.length - 1)) * i;
          final y = safeValue(
            padding.top + chartHeight -
            ((readings[i].systolic - minSystolic + 10) / systolicRange) * chartHeight
          );

          if (i == 0) {
            systolicPath.moveTo(x, y);
          } else {
            systolicPath.lineTo(x, y);
          }
        }
        canvas.drawPath(systolicPath, systolicPaint);

        // Draw diastolic line
        final diastolicPath = Path();
        final diastolicPaint = Paint()
          ..color = const Color(0xFF3B82F6)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < readings.length; i++) {
          final x = padding.left + (chartWidth / (readings.length - 1)) * i;
          final y = safeValue(
            padding.top + chartHeight -
            ((readings[i].diastolic - minDiastolic + 10) / diastolicRange) * chartHeight
          );

          if (i == 0) {
            diastolicPath.moveTo(x, y);
          } else {
            diastolicPath.lineTo(x, y);
          }
        }
        canvas.drawPath(diastolicPath, diastolicPaint);

        // Draw pulse line
        final pulsePath = Path();
        final pulsePaint = Paint()
          ..color = const Color(0xFF10B981)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < readings.length; i++) {
          final x = padding.left + (chartWidth / (readings.length - 1)) * i;
          // Normalize pulse to fit in the chart (assuming 40-120 bpm range)
          final pulseRange = 80;
          final minPulse = 40;
          final y = safeValue(
            padding.top + chartHeight -
            ((readings[i].heartRate - minPulse) / pulseRange) * chartHeight
          );

          if (i == 0) {
            pulsePath.moveTo(x, y);
          } else {
            pulsePath.lineTo(x, y);
          }
        }
        canvas.drawPath(pulsePath, pulsePaint);

        // Draw points and values for each reading
        for (int i = 0; i < readings.length; i++) {
          final x = padding.left + (chartWidth / (readings.length - 1)) * i;
          final systolicY = safeValue(
            padding.top + chartHeight -
            ((readings[i].systolic - minSystolic + 10) / systolicRange) * chartHeight
          );
          final diastolicY = safeValue(
            padding.top + chartHeight -
            ((readings[i].diastolic - minDiastolic + 10) / diastolicRange) * chartHeight
          );

          // Draw systolic point
          final systolicPointPaint = Paint()
            ..color = const Color(0xFFEF4444)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x, systolicY), 4, systolicPointPaint);

          // Draw diastolic point
          final diastolicPointPaint = Paint()
            ..color = const Color(0xFF3B82F6)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x, diastolicY), 4, diastolicPointPaint);

          // Draw pulse point
          final pulseRange = 80;
          final minPulse = 40;
          final pulseY = safeValue(
            padding.top + chartHeight -
            ((readings[i].heartRate - minPulse) / pulseRange) * chartHeight
          );
          final pulsePointPaint = Paint()
            ..color = const Color(0xFF10B981)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x, pulseY), 3, pulsePointPaint);

          // Show values for first and last points
          if (i == 0 || i == readings.length - 1) {
            _drawText(
              canvas,
              '${readings[i].systolic}',
              x,
              systolicY - 15,
              const Color(0xFFEF4444)
            );
            _drawText(
              canvas,
              '${readings[i].diastolic}',
              x,
              diastolicY + 15,
              const Color(0xFF3B82F6)
            );
            _drawText(
              canvas,
              '${readings[i].heartRate}',
              x,
              pulseY - 10,
              const Color(0xFF10B981)
            );
          }
        }
      }
    }

    // Draw legend
    final legendY = padding.top;
    final legendX = size.width - 120;

    // Systolic legend
    final systolicPaint = Paint()
      ..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(legendX, legendY + 6), 6, systolicPaint);
    _drawText(canvas, 'Systolic', legendX + 12, legendY,
        const Color(0xFF6B7280));

    // Diastolic legend
    final diastolicPaint = Paint()
      ..color = const Color(0xFF3B82F6);
    canvas.drawCircle(Offset(legendX, legendY + 24), 6, diastolicPaint);
    _drawText(canvas, 'Diastolic', legendX + 12, legendY + 18,
        const Color(0xFF6B7280));

    // Pulse legend
    final pulsePaint = Paint()
      ..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(legendX, legendY + 42), 5, pulsePaint);
    _drawText(canvas, 'Pulse', legendX + 12, legendY + 36,
        const Color(0xFF6B7280));
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
          padding: EdgeInsets.all(AppSpacing.lg + AppSpacing.sm),
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
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sectionGap),

              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HeartIcon(
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Reading',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Record your blood pressure and heart rate',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
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
              SizedBox(height: AppSpacing.sectionGap),

              // Add Reading Screen content
              const AddReadingContent(
                isInModal: true,
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
