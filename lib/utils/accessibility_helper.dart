import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for accessibility features
class AccessibilityHelper {
  /// Adds semantic properties to blood pressure readings
  static Widget wrapReadingWithSemantics({
    required Widget child,
    required int systolic,
    required int diastolic,
    required int pulse,
    required String category,
    required DateTime timestamp,
  }) {
    return Semantics(
      label: 'Blood pressure reading: $systolic over $diastolic millimeters of mercury, '
          'pulse $pulse beats per minute, category: $category, '
          'recorded on ${_formatDate(timestamp)}',
      child: child,
    );
  }

  /// Adds semantic properties to charts
  static Widget wrapChartWithSemantics({
    required Widget child,
    required String chartTitle,
    required String chartDescription,
    required List<String> dataPoints,
  }) {
    return Semantics(
      label: chartTitle,
      hint: chartDescription,
      child: child,
    );
  }

  /// Ensures minimum touch target of 48dp
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    double? minSize,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    final targetSize = minSize ?? 48.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: targetSize,
          minHeight: targetSize,
        ),
        child: child,
      ),
    );
  }

  /// Adds haptic feedback based on interaction type
  static Future<void> triggerHapticFeedback({
    required HapticFeedbackType type,
  }) async {
    try {
      switch (type) {
        case HapticFeedbackType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selection:
          await HapticFeedback.selectionClick();
          break;
      }
    } catch (e) {
      // Haptic feedback might not be available on all devices
      debugPrint('Haptic feedback not available: $e');
    }
  }

  /// Creates accessible color indicators with patterns
  static Widget createAccessibleIndicator({
    required Color color,
    required String label,
    required bool showPattern,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          // Add pattern for colorblind users
          child: showPattern
              ? Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 12,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Formats date for accessibility
  static String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Checks if the current platform supports accessibility features
  static bool get isAccessibilitySupported {
    try {
      return true; // Both iOS and Android support accessibility features
    } catch (e) {
      return false;
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}