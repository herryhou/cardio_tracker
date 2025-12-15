import 'package:flutter/material.dart';
import '../domain/entities/blood_pressure_reading.dart';
import '../domain/value_objects/blood_pressure_category.dart';
import '../theme/app_theme.dart';

class RecentReadingItem extends StatelessWidget {
  final BloodPressureReading reading;
  final VoidCallback onDelete;

  const RecentReadingItem({
    super.key,
    required this.reading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(context, reading.category);

    return Dismissible(
      key: ValueKey(reading.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Reading'),
            content: Text(
                'Are you sure you want to delete the reading from ${_formatDate(reading.timestamp)}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (shouldDelete == true) {
          // Delete the reading
          onDelete();
          // Return false to prevent Dismissible from removing the widget
          // The provider will handle updating the UI
          return false;
        }

        return false;
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
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Date/Time (left)
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(reading.timestamp),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Reading (center) - with colored background badge only
              Flexible(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryBackgroundColor(reading.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reading.systolic}/${reading.diastolic}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Pulse (right) - only show if heart rate is available
              Flexible(
                flex: 2,
                child: reading.hasHeartRate
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            size: 16,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${reading.heartRate}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(), // Empty space when no pulse data
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (timestamp.year == now.year) {
      final timeStr =
          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
      return '${timestamp.month}/${timestamp.day} $timeStr';
    } else {
      final timeStr =
          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
      return '${timestamp.month}/${timestamp.day}/${timestamp.year % 100} $timeStr';
    }
  }

  // String _formatTime(DateTime timestamp) {
  //   final now = DateTime.now();
  //   final difference = now.difference(timestamp);

  //   if (difference.inDays < 7) {
  //     return '';
  //   }
  //   return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  // }

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

  Color _getCategoryBackgroundColor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.normal:
        return const Color(0xFF10B981).withValues(alpha: 0.08); // Green
      case BloodPressureCategory.elevated:
        return const Color(0xFFF59E0B).withValues(alpha: 0.08); // Orange
      case BloodPressureCategory.low:
        return const Color(0xFF3B82F6).withValues(alpha: 0.08); // Blue
      case BloodPressureCategory.stage1:
      case BloodPressureCategory.stage2:
      case BloodPressureCategory.crisis:
        return const Color(0xFFEF4444).withValues(alpha: 0.08); // Red
    }
  }
}
