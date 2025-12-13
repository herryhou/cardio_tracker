import 'package:flutter/material.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/value_objects/blood_pressure_category.dart';
import 'package:cardio_tracker/widgets/neumorphic_container.dart';

/// A horizontal scrollable timeline carousel that displays blood pressure readings
/// with neumorphic design and interactive selection
class TimelineCarousel extends StatefulWidget {
  /// List of blood pressure readings to display
  final List<BloodPressureReading> readings;

  /// Callback when a date is selected
  final Function(String selectedDate) onDateSelected;

  /// Optional start date for filtering
  final DateTime? startDate;

  /// Optional end date for filtering
  final DateTime? endDate;

  /// Currently selected date
  final String? selectedDate;

  const TimelineCarousel({
    super.key,
    required this.readings,
    required this.onDateSelected,
    this.startDate,
    this.endDate,
    this.selectedDate,
  });

  @override
  State<TimelineCarousel> createState() => _TimelineCarouselState();
}

class _TimelineCarouselState extends State<TimelineCarousel> {
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    // Filter readings based on date range if provided
    var filteredReadings = widget.readings.where((reading) {
      if (widget.startDate != null && reading.timestamp.isBefore(widget.startDate!)) {
        return false;
      }
      if (widget.endDate != null && reading.timestamp.isAfter(widget.endDate!)) {
        return false;
      }
      return true;
    }).toList();

    // Sort readings by timestamp
    filteredReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (filteredReadings.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: filteredReadings.map((reading) {
            final isSelected = _selectedDate == _formatDate(reading.timestamp);

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TimelineItem(
                reading: reading,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedDate = _formatDate(reading.timestamp);
                  });
                  widget.onDateSelected(_selectedDate!);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

/// Individual timeline item widget
class TimelineItem extends StatefulWidget {
  final BloodPressureReading reading;
  final bool isSelected;
  final VoidCallback onTap;

  const TimelineItem({
    super.key,
    required this.reading,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barHeight = _calculateBarHeight();
    final barColor = _getBarColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedScale(
          scale: widget.isSelected ? 1.05 : _scaleAnimation.value,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: GestureDetector(
            onTapDown: (_) {
              _animationController.forward();
            },
            onTapUp: (_) {
              _animationController.reverse();
              widget.onTap();
            },
            onTapCancel: () {
              _animationController.reverse();
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _opacityAnimation.value,
              child: NeumorphicContainer(
                key: const Key('neumorphic_container'),
                isPressed: widget.isSelected,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vertical bar
                    Container(
                      key: _getBarKey(),
                      width: 12,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Date label
                    Text(
                      _formatDate(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                        color: widget.isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Key _getBarKey() {
    switch (widget.reading.category) {
      case BloodPressureCategory.normal:
      case BloodPressureCategory.low:
        return const Key('normal_bar');
      case BloodPressureCategory.elevated:
        return const Key('elevated_bar');
      case BloodPressureCategory.stage1:
        return const Key('high_bar');
      case BloodPressureCategory.stage2:
      case BloodPressureCategory.crisis:
        return const Key('very_high_bar');
    }
  }

  double _calculateBarHeight() {
    // Map systolic value to bar height (20-60 pixels)
    const minHeight = 20.0;
    const maxHeight = 60.0;
    const range = 100; // systolic range (100-200)
    final normalized = (widget.reading.systolic - 100) / range;
    return minHeight + (maxHeight - minHeight) * normalized.clamp(0.0, 1.0);
  }

  Color _getBarColor() {
    switch (widget.reading.category) {
      case BloodPressureCategory.low:
      case BloodPressureCategory.normal:
        return const Color(0xFF4CAF50);
      case BloodPressureCategory.elevated:
        return const Color(0xFFFFC107);
      case BloodPressureCategory.stage1:
        return const Color(0xFFFF9800);
      case BloodPressureCategory.stage2:
        return const Color(0xFFF44336);
      case BloodPressureCategory.crisis:
        return const Color(0xFFB71C1C);
    }
  }

  String _formatDate() {
    return '${widget.reading.timestamp.month.toString().padLeft(2, '0')}/${widget.reading.timestamp.day.toString().padLeft(2, '0')}';
  }
}