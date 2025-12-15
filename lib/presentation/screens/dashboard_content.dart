import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/entities/chart_types.dart';
import '../../theme/app_theme.dart';
import '../../widgets/recent_reading_item.dart';
import '../../widgets/reading_card_neu.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/horizontal_charts_container.dart';
import '../../widgets/bp_legend.dart';
import 'add_reading_screen.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  ExtendedTimeRange _currentTimeRange = ExtendedTimeRange.month;

  @override
  Widget build(BuildContext context) {
    return Consumer<BloodPressureProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.loadReadings(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Minimalist Header with extra spacing
                const SizedBox(height: AppSpacing.xl),

                // Centered Reading Card - Main Feature
                if (provider.latestReading != null) ...[
                  _buildCenteredReadingCard(context, provider.latestReading!),
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
                  child: _buildRecentReadingsSection(
                      context, _filterReadingsByTimeRange(provider.readings)),
                ),

                // Extra bottom spacing for FAB
                const SizedBox(height: AppSpacing.xxl + 80),
              ],
            ),
          ),
        );
      },
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
      child: GestureDetector(
        onTap: () => _showAddReadingModal(context),
        child: NeumorphicContainer(
          borderRadius: 30.0,
          padding: const EdgeInsets.all(AppSpacing.xl + AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No readings yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tap here to add your first reading',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+ Add Reading',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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
              Expanded(
                child: Text(
                  'Recent Readings',
                  style: AppTheme.headerStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Show count of filtered readings
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${recentReadings.length} reading${recentReadings.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
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
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 32,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No recent readings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
