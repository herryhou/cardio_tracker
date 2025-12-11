import 'package:flutter/material.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';
import 'neumorphic_container.dart';

/// A centered, pill-shaped neumorphic card for displaying blood pressure readings
/// Features minimalist design with soft shadows and smooth animations
class ReadingCardNeu extends StatelessWidget {
  /// The blood pressure reading to display
  final BloodPressureReading reading;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Optional custom color for accent elements
  final Color? accentColor;

  /// Whether to show the animated heart icon
  final bool showHeartAnimation;

  /// The size of the card (affects padding and font sizes)
  final ReadingCardSize size;

  const ReadingCardNeu({
    super.key,
    required this.reading,
    this.onTap,
    this.accentColor,
    this.showHeartAnimation = true,
    this.size = ReadingCardSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? _getCategoryColor(context, reading.category);

    // Size configurations
    final padding = _getPadding();
    final mainFontSize = _getMainFontSize();
    final labelFontSize = _getLabelFontSize();
    final iconSize = _getIconSize();

    return Semantics(
      label: 'Blood pressure reading',
      hint: '${reading.systolic} over ${reading.diastolic}, ${reading.category.name}',
      child: GestureDetector(
        onTap: onTap,
        child: NeumorphicContainer(
          isPressed: onTap != null,
          borderRadius: 30.0, // Pill-shaped
          padding: EdgeInsets.all(padding),
          child: Container(
            constraints: BoxConstraints(
              minHeight: _getMinHeight(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main BP Reading Display
                _buildBPDisplay(context, color, mainFontSize, labelFontSize),

                SizedBox(height: AppSpacing.lg),

                // Pulse and Status Row
                _buildPulseAndStatus(context, color, labelFontSize, iconSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main blood pressure display
  Widget _buildBPDisplay(BuildContext context, Color color, double mainFontSize, double labelFontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Systolic
        Flexible(
          child: _buildBPValue(
            context,
            reading.systolic.toString(),
            'Systolic',
            color,
            mainFontSize,
            labelFontSize,
          ),
        ),

        SizedBox(width: AppSpacing.xl),

        // Separator
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '/',
            style: TextStyle(
              fontSize: mainFontSize * 0.8,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w300,
            ),
          ),
        ),

        SizedBox(width: AppSpacing.xl),

        // Diastolic
        Flexible(
          child: _buildBPValue(
            context,
            reading.diastolic.toString(),
            'Diastolic',
            color,
            mainFontSize,
            labelFontSize,
          ),
        ),
      ],
    );
  }

  /// Builds a single blood pressure value with label
  Widget _buildBPValue(
    BuildContext context,
    String value,
    String label,
    Color color,
    double fontSize,
    double labelFontSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.0,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the pulse display and status badge row
  Widget _buildPulseAndStatus(BuildContext context, Color color, double labelFontSize, double iconSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pulse Display with Animated Heart
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              size: iconSize,
              color: Colors.red.shade400,
            ),

            SizedBox(width: AppSpacing.sm),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reading.heartRate.toString(),
                  style: TextStyle(
                    fontSize: labelFontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'bpm',
                  style: TextStyle(
                    fontSize: labelFontSize * 0.9,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Status Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _getCategoryText(reading.category),
            style: TextStyle(
              fontSize: labelFontSize,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Get padding based on card size
  double _getPadding() {
    switch (size) {
      case ReadingCardSize.small:
        return AppSpacing.lg;
      case ReadingCardSize.medium:
        return 32.0;
      case ReadingCardSize.large:
        return AppSpacing.xl;
    }
  }

  /// Get main font size based on card size
  double _getMainFontSize() {
    switch (size) {
      case ReadingCardSize.small:
        return 36.0;
      case ReadingCardSize.medium:
        return 48.0;
      case ReadingCardSize.large:
        return 64.0;
    }
  }

  /// Get label font size based on card size
  double _getLabelFontSize() {
    switch (size) {
      case ReadingCardSize.small:
        return 12.0;
      case ReadingCardSize.medium:
        return 14.0;
      case ReadingCardSize.large:
        return 16.0;
    }
  }

  /// Get icon size based on card size
  double _getIconSize() {
    switch (size) {
      case ReadingCardSize.small:
        return 20.0;
      case ReadingCardSize.medium:
        return 24.0;
      case ReadingCardSize.large:
        return 32.0;
    }
  }

  /// Get minimum height based on card size
  double _getMinHeight() {
    switch (size) {
      case ReadingCardSize.small:
        return 120.0;
      case ReadingCardSize.medium:
        return 160.0;
      case ReadingCardSize.large:
        return 200.0;
    }
  }

  /// Get color based on blood pressure category
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

  /// Get text for blood pressure category
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
}

/// Enum for different card sizes
enum ReadingCardSize {
  small,
  medium,
  large,
}