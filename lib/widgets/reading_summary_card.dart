import 'package:flutter/material.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';
import '../utils/bp_format.dart';

/// Modern Reading Summary Card Component
/// Displays individual blood pressure readings with swipe actions
class ReadingSummaryCard extends StatelessWidget {
  final BloodPressureReading reading;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool showActions;

  const ReadingSummaryCard({
    super.key,
    required this.reading,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(context, reading.category);

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with timestamp and actions
              Row(
                children: [
                  // Date and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(reading.timestamp),
                          style: AppTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTime(reading.timestamp),
                          style: AppTheme.bodyStyle.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.cardsGap,
                        vertical: AppSpacing.xs - 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reading.category.toString().split('.').last,
                      style: AppTheme.bodyStyle.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Actions
                  if (showActions) ...[
                    SizedBox(width: AppSpacing.sm),
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 44, minHeight: 44),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit,
                                    size: 16,
                                    color: theme.colorScheme.onSurface),
                                SizedBox(width: AppSpacing.sm),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    size: 16, color: theme.colorScheme.error),
                                SizedBox(width: AppSpacing.sm),
                                const Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // Main readings display
              Row(
                children: [
                  // Blood Pressure
                  Expanded(
                    child: _buildBPDisplay(context),
                  ),

                  // Pulse section (conditionally displayed)
                  if (reading.hasHeartRate) ...[
                    Container(
                      width: 1,
                      height: 50,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    SizedBox(width: AppSpacing.md),
                    _buildPulseDisplay(context),
                  ],
                ],
              ),

              // Notes (if available)
              if (reading.notes != null && reading.notes!.isNotEmpty) ...[
                SizedBox(height: AppSpacing.cardsGap),
                Container(
                  padding: EdgeInsets.all(AppSpacing.cardsGap),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          reading.notes!,
                          style: AppTheme.bodyStyle.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBPDisplay(BuildContext context) {
    Theme.of(context);
    final categoryColor = _getCategoryColor(context, reading.category);

    return Row(
      children: [
        Text(
          formatBloodPressure(reading.systolic, reading.diastolic),
          style: AppTheme.displayStyle.copyWith(
            fontSize: 24, // Override for card context
            color: categoryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPulseDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.favorite,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reading.heartRate.toString(),
              style: AppTheme.displayStyle.copyWith(
                fontSize: 24, // Override for card context
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'BPM',
              style: AppTheme.bodyStyle.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final readingDate = DateTime(date.year, date.month, date.day);

    if (readingDate == today) {
      return 'Today';
    } else if (readingDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (readingDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Compact version for list displays
String _getMonthAbbr(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month - 1];
}

class CompactReadingCard extends StatelessWidget {
  final BloodPressureReading reading;
  final VoidCallback? onTap;
  final bool isSelected;

  const CompactReadingCard({
    super.key,
    required this.reading,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(context, reading.category);

    return Card(
      elevation: 0,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.cardsGap),
          child: Row(
            children: [
              // Date
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${reading.timestamp.day}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_getMonthAbbr(reading.timestamp.month)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // BP Values
              Expanded(
                child: Row(
                  children: [
                    Text(
                      formatBloodPressure(reading.systolic, reading.diastolic),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Pulse (if available)
              if (reading.hasHeartRate) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reading.heartRate}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],

              // Category indicator
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
