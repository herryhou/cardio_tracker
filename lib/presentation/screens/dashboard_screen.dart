import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/entities/chart_types.dart';
import '../../theme/app_theme.dart';
import 'add_reading_screen.dart';
import '../../widgets/recent_reading_item.dart';
import '../../widgets/reading_card_neu.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/neumorphic_button.dart';
import '../../widgets/export_bottom_sheet.dart';
import '../../widgets/horizontal_charts_container.dart';
import '../../widgets/bp_legend.dart';
import '../providers/dual_chart_provider.dart';
import '../../widgets/app_actions/sync_status_indicator.dart';
import '../../widgets/app_actions/export_action_buttons.dart';
import '../../widgets/app_actions/main_menu_button.dart';
import '../../infrastructure/utils/reading_id_generator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Consumer<BloodPressureProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(context, provider.error!);
          }

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DualChartProvider()),
            ],
            child: RefreshIndicator(
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
                      const SizedBox(height: AppSpacing.xl),

                      // Centered Reading Card - Main Feature
                      if (provider.latestReading != null) ...[
                        _buildCenteredReadingCard(
                            context, provider.latestReading!),
                        const SizedBox(height: AppSpacing.xl),
                      ] else ...[
                        _buildEmptyStateCard(context),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // Horizontal Charts Section
                      HorizontalChartsContainer(
                        readings: provider.readings,
                        onTimeRangeChanged: (ExtendedTimeRange newRange) {
                          setState(() {
                            _currentTimeRange = newRange;
                          });
                        },
                        initialTimeRange: _currentTimeRange,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Blood Pressure Legend (common for both charts)
                      const BPLegend(),

                      const SizedBox(height: AppSpacing.lg),

                      // Recent Readings Section with neumorphic styling
                      Padding(
                        padding: AppSpacing.screenMargins,
                        child: _buildRecentReadingsSection(context,
                            _filterReadingsByTimeRange(provider.readings)),
                      ),

                      // Extra bottom spacing for minimalist feel
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ); // RefreshIndicator
        },
      ),
      floatingActionButton: _buildNeumorphicFAB(context),
    );
  }

  // Neumorphic AppBar with minimalist design
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Cardio Tracker',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.primary,
      centerTitle: false,
      actions: const [
        // Sync Status Indicator with dropdown menu
        SyncStatusIndicator(),
        // Export Actions
        ExportActionButtons(),
        // Main Menu
        MainMenuButton(),
      ],
    );
  }

  // Main centered reading card with neumorphic design
  Widget _buildCenteredReadingCard(
      BuildContext context, BloodPressureReading reading) {
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
      child: const NeumorphicContainer(
        borderRadius: 30.0,
        padding: EdgeInsets.all(AppSpacing.xl + AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No readings yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Readings',
                style: AppTheme.headerStyle.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              // Show count of filtered readings
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${recentReadings.length} reading${recentReadings.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Time range selector for recent readings
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          if (recentReadings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 32,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: AppSpacing.sm),
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
            Column(
              children:
                  recentReadings.take(20).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final reading = entry.value;
                final isLast =
                    index == recentReadings.length - 1 || index == 19;

                return Column(
                  children: [
                    RecentReadingItem(
                      reading: reading,
                      onDelete: () => _deleteReading(reading),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
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

  // Plain Floating Action Button
  Widget _buildNeumorphicFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showAddReadingModal(context);
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 8,
      child: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 28,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.md),
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Unable to load data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              NeumorphicButton(
                onPressed: () =>
                    context.read<BloodPressureProvider>().loadReadings(),
                borderRadius: 12.0,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: AppSpacing.sm),
                    Text('Retry'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddReadingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReadingModalSheet(),
    );
  }

  void _deleteReading(BloodPressureReading reading) {
    final provider = context.read<BloodPressureProvider>();
    provider.deleteReading(reading.id);
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
}

/// Modal bottom sheet for adding new blood pressure readings
class AddReadingModalSheet extends StatefulWidget {
  const AddReadingModalSheet({super.key});

  @override
  State<AddReadingModalSheet> createState() => _AddReadingModalSheetState();
}

class _AddReadingModalSheetState extends State<AddReadingModalSheet> {
  bool _isLoading = false;
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();
  final DateTime _selectedDateTime = DateTime.now();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // color: Theme.of(context).colorScheme.surface,
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.sm),
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
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
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
                          'Record blood pressure / heart rate',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
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
              const SizedBox(height: AppSpacing.lg),

              // Add Reading Screen content
              AddReadingContent(
                isInModal: true,
                onSave: _isLoading ? null : () => _saveReading(),
                isLoading: _isLoading,
                systolicController: _systolicController,
                diastolicController: _diastolicController,
                heartRateController: _heartRateController,
                notesController: _notesController,
                initialDateTime: _selectedDateTime,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveReading() async {
    // Check if required fields are empty
    final errors = <String>[];

    if (_systolicController.text.isEmpty) {
      errors.add('Systolic is required');
    } else {
      final systolic = int.tryParse(_systolicController.text);
      if (systolic == null) {
        errors.add('Systolic must be a valid number');
      } else if (systolic < 70 || systolic > 250) {
        errors.add('Systolic must be between 70 and 250');
      }
    }

    if (_diastolicController.text.isEmpty) {
      errors.add('Diastolic is required');
    } else {
      final diastolic = int.tryParse(_diastolicController.text);
      if (diastolic == null) {
        errors.add('Diastolic must be a valid number');
      } else if (diastolic < 40 || diastolic > 150) {
        errors.add('Diastolic must be between 40 and 150');
      }
    }

    if (_heartRateController.text.isNotEmpty) {
      final heartRate = int.tryParse(_heartRateController.text);
      if (heartRate == null) {
        errors.add('Heart rate must be a valid number');
      } else if (heartRate < 30 || heartRate > 250) {
        errors.add('Heart rate must be between 30 and 250');
      }
    }

    // If there are errors, show them
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Theme.of(context).colorScheme.onSurface, size: 20),
                  const SizedBox(width: 12),
                  const Text('Please fix the following errors:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ...errors.map((error) => Padding(
                    padding: const EdgeInsets.only(left: 32, top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 4,
                            color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Expanded(child: Text(error)),
                      ],
                    ),
                  )),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Parse values again (they've already been validated above)
    final systolic = int.parse(_systolicController.text);
    final diastolic = int.parse(_diastolicController.text);
    final heartRate = _heartRateController.text.isNotEmpty
        ? int.parse(_heartRateController.text)
        : 0;

    // Create the reading
    final reading = BloodPressureReading(
      id: ReadingIdGenerator.generateId(
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: _selectedDateTime,
        notes: _notesController.text.trim(),
      ),
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      timestamp: _selectedDateTime,
      notes: _notesController.text.trim(),
      lastModified: DateTime.now(),
    );

    try {
      await context.read<BloodPressureProvider>().addReading(reading);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20),
                const SizedBox(width: 12),
                const Text('Reading added successfully'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
