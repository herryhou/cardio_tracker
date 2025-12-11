import 'package:flutter/material.dart';

/// Modern Trend Indicator Component
/// Displays trend data with visual indicators and statistics
class TrendIndicator extends StatelessWidget {
  final double currentValue;
  final double previousValue;
  final String? label;
  final String unit;
  final bool showPercentage;
  final Color? color;
  final IconData? icon;
  final TrendDisplayMode displayMode;
  final bool showDetails;

  const TrendIndicator({
    super.key,
    required this.currentValue,
    required this.previousValue,
    this.label,
    this.unit = '',
    this.showPercentage = true,
    this.color,
    this.icon,
    this.displayMode = TrendDisplayMode.compact,
    this.showDetails = false,
  });

  bool get isUpwardTrend => currentValue > previousValue;
  bool get isNeutral => (currentValue - previousValue).abs() < 0.01;
  double get percentageChange => previousValue != 0
      ? ((currentValue - previousValue) / previousValue.abs()) * 100
      : 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendColor = _getTrendColor(theme);

    switch (displayMode) {
      case TrendDisplayMode.compact:
        return _buildCompactIndicator(context, trendColor);
      case TrendDisplayMode.detailed:
        return _buildDetailedIndicator(context, trendColor);
      case TrendDisplayMode.minimal:
        return _buildMinimalIndicator(context, trendColor);
    }
  }

  Widget _buildCompactIndicator(BuildContext context, Color trendColor) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: trendColor,
            ),
            const SizedBox(width: 6),
          ],
          if (!isNeutral) ...[
            Icon(
              isUpwardTrend ? Icons.trending_up : Icons.trending_down,
              size: 14,
              color: trendColor,
            ),
            const SizedBox(width: 4),
          ],
          if (showPercentage && !isNeutral) ...[
            Text(
              '${percentageChange.abs().toStringAsFixed(1)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: trendColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (showDetails) ...[
            const SizedBox(width: 8),
            Text(
              '$currentValue$unit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedIndicator(BuildContext context, Color trendColor) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: trendColor,
                  ),
                  const SizedBox(width: 8),
                ],
                if (label != null) ...[
                  Text(
                    label!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isNeutral)
                        Icon(
                          isUpwardTrend
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 12,
                          color: trendColor,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        isNeutral
                            ? 'No Change'
                            : '${percentageChange.abs().toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Values comparison
            Row(
              children: [
                // Current value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currentValue$unit',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // VS indicator
                Text(
                  'VS',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Previous value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Previous',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$previousValue$unit',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Change details
            if (!isNeutral) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isUpwardTrend ? 'Increased' : 'Decreased'} by ${_formatAbsoluteChange()}$unit (${percentageChange.abs().toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: trendColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalIndicator(BuildContext context, Color trendColor) {
    if (isNeutral) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUpwardTrend ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: trendColor,
        ),
        const SizedBox(width: 2),
        Text(
          _formatAbsoluteChange(),
          style: TextStyle(
            fontSize: 11,
            color: trendColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (unit.isNotEmpty) ...[
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: trendColor.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Color _getTrendColor(ThemeData theme) {
    if (color != null) return color!;

    if (isNeutral) {
      return theme.colorScheme.onSurface.withOpacity(0.5);
    }

    // For health metrics, upward trends aren't always bad
    // This could be customized based on the metric type
    return isUpwardTrend
        ? theme.colorScheme.error // Red for upward trend
        : theme.colorScheme.primary; // Blue for downward trend
  }

  String _formatAbsoluteChange() {
    final change = (currentValue - previousValue).abs();
    if (change >= 1000) {
      return '${(change / 1000).toStringAsFixed(1)}k';
    } else if (change >= 10) {
      return change.toStringAsFixed(0);
    } else {
      return change.toStringAsFixed(1);
    }
  }
}

/// Mode for displaying trend information
enum TrendDisplayMode {
  compact, // Small inline indicator
  detailed, // Full card with comparison
  minimal, // Just arrow and value change
}

/// Specialized trend indicator for blood pressure
class BloodPressureTrendIndicator extends StatelessWidget {
  final int currentSystolic;
  final int currentDiastolic;
  final int previousSystolic;
  final int previousDiastolic;
  final String? label;
  final TrendDisplayMode displayMode;

  const BloodPressureTrendIndicator({
    super.key,
    required this.currentSystolic,
    required this.currentDiastolic,
    required this.previousSystolic,
    required this.previousDiastolic,
    this.label,
    this.displayMode = TrendDisplayMode.compact,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    if (displayMode == TrendDisplayMode.compact) {
      return _buildCompactBPTrend(context);
    } else {
      return _buildDetailedBPTrend(context);
    }
  }

  Widget _buildCompactBPTrend(BuildContext context) {
    final theme = Theme.of(context);
    final systolicChange = currentSystolic - previousSystolic;
    final diastolicChange = currentDiastolic - previousDiastolic;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              _buildBPTrendItem(
                context,
                'SYS',
                systolicChange,
                theme.colorScheme.error,
              ),
              const SizedBox(width: 16),
              _buildBPTrendItem(
                context,
                'DIA',
                diastolicChange,
                theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBPTrendItem(
    BuildContext context,
    String label,
    int change,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isUp = change > 0;
    final isNeutral = change == 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        if (!isNeutral) ...[
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
        ],
        Text(
          isNeutral ? '→' : '${change.abs()}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: isNeutral
                ? theme.colorScheme.onSurface.withOpacity(0.5)
                : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedBPTrend(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TrendIndicator(
                    currentValue: currentSystolic.toDouble(),
                    previousValue: previousSystolic.toDouble(),
                    label: 'Systolic',
                    unit: 'mmHg',
                    displayMode: TrendDisplayMode.detailed,
                    color: theme.colorScheme.error,
                    icon: Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TrendIndicator(
                    currentValue: currentDiastolic.toDouble(),
                    previousValue: previousDiastolic.toDouble(),
                    label: 'Diastolic',
                    unit: 'mmHg',
                    displayMode: TrendDisplayMode.detailed,
                    color: theme.colorScheme.primary,
                    icon: Icons.arrow_downward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
