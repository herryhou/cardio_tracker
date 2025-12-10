import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/reading_card_neu.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/export_bottom_sheet.dart';
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
      appBar: _buildAppBar(context),
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
            child: GestureDetector(
              onLongPress: () async {
                await HapticFeedback.mediumImpact();
                showExportBottomSheet(
                  context,
                  readings: provider.readings,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                  // Minimalist Header with extra spacing
                  SizedBox(height: AppSpacing.xl),

                  // Centered Reading Card - Main Feature
                  if (provider.latestReading != null) ...[
                    _buildCenteredReadingCard(context, provider.latestReading!),
                    SizedBox(height: AppSpacing.xxl),
                  ] else ...[
                    _buildEmptyStateCard(context),
                    SizedBox(height: AppSpacing.xxl),
                  ],

                  // Recent Readings Section with neumorphic styling
                  Padding(
                    padding: AppSpacing.screenMargins,
                    child: _buildRecentReadingsSection(context, provider.recentReadings),
                  ),

                  // Extra bottom spacing for minimalist feel
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildNeumorphicFAB(context),
    );
  }

  // Neumorphic AppBar with minimalist design
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const AppLogo(showText: true, size: 32),
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
    );
  }

  // Main centered reading card with neumorphic design
  Widget _buildCenteredReadingCard(BuildContext context, BloodPressureReading reading) {
    return Padding(
      padding: AppSpacing.screenMargins,
      child: ReadingCardNeu(
        reading: reading,
        size: ReadingCardSize.large,
        showHeartAnimation: true,
      ),
    );
  }

  // Empty state card with neumorphic styling
  Widget _buildEmptyStateCard(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenMargins,
      child: NeumorphicContainer(
        borderRadius: 30.0,
        padding: EdgeInsets.all(AppSpacing.xl + AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 80,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: AppSpacing.lg),
            const Text(
              'No readings yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            const Text(
              'Tap the + button to add your first reading',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Recent readings section with neumorphic styling
  Widget _buildRecentReadingsSection(
      BuildContext context, List<BloodPressureReading> recentReadings) {
    return NeumorphicContainer(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Readings',
            style: AppTheme.headerStyle.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          if (recentReadings.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.history,
                    size: 32,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  const Text(
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
            Column(
              children: recentReadings.take(5).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final reading = entry.value;
                final isLast = index == recentReadings.length - 1 || index == 4;

                return Column(
                  children: [
                    RecentReadingItem(
                      reading: reading,
                      onDelete: () => _deleteReading(reading),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        indent: 0,
                        endIndent: 0,
                      ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Neumorphic Floating Action Button
  Widget _buildNeumorphicFAB(BuildContext context) {
    return NeumorphicButton(
      onPressed: () {
        _showAddReadingModal(context);
      },
      borderRadius: 28.0,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            AppIcons.add,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          const Text(
            'New',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg + AppSpacing.md),
        child: NeumorphicContainer(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
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
              SizedBox(height: AppSpacing.lg),
              const Text(
                'Unable to load data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              NeumorphicButton(
                onPressed: () =>
                    context.read<BloodPressureProvider>().loadReadings(),
                borderRadius: 12.0,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh),
                    SizedBox(width: AppSpacing.sm),
                    const Text('Retry'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _deleteReading(BloodPressureReading reading) {
    final provider = context.read<BloodPressureProvider>();
    provider.deleteReading(reading.id);
  }
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
              SizedBox(height: AppSpacing.lg),

              // Header
              Row(
                children: [
                  NeumorphicContainer(
                    borderRadius: 12.0,
                    padding: EdgeInsets.all(AppSpacing.md),
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
              SizedBox(height: AppSpacing.lg),

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