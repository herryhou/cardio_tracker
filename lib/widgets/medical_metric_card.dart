import 'package:flutter/material.dart';

/// Modern Medical Metric Card Component
/// Displays key health metrics with visual indicators and optional trend
class MedicalMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final Color? color;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isTrendUp;
  final EdgeInsets? padding;

  const MedicalMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.color,
    this.icon,
    this.subtitle,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isTrendUp = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    final padding = this.padding ?? const EdgeInsets.all(20);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and icon
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: cardColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main value
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                      height: 1.0,
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              ),

              // Optional subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],

              // Optional trend indicator
              if (showTrend && trendValue != null) ...[
                const SizedBox(height: 12),
                _buildTrendIndicator(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUpwardTrend = trendValue! > 0;
    final bool isNeutral = (trendValue!).abs() < 0.01;
    final Color trendColor =
        isUpwardTrend ? theme.colorScheme.error : theme.colorScheme.primary;

    if (isNeutral) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
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
              '$value$unit',
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

  bool get showPercentage => true;
  double get percentageChange => trendValue != null ? trendValue! : 0.0;
  bool get showDetails => false;
}

/// Specialized metric card for blood pressure
class BloodPressureMetricCard extends StatelessWidget {
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String category;
  final Color categoryColor;
  final VoidCallback? onTap;
  final DateTime? timestamp;
  final bool showTrend;
  final double? systolicTrend;
  final double? diastolicTrend;
  final double? pulseTrend;

  const BloodPressureMetricCard({
    super.key,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.category,
    required this.categoryColor,
    this.onTap,
    this.timestamp,
    this.showTrend = false,
    this.systolicTrend,
    this.diastolicTrend,
    this.pulseTrend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blood Pressure',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // BP Values
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Systolic
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          systolic.toString(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'SYS',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (showTrend && systolicTrend != null) ...[
                          const SizedBox(height: 8),
                          _buildTrendIndicator(
                            context,
                            systolicTrend!,
                            isUpTrend: systolicTrend! > 0,
                            showColor: systolicTrend!.abs() > 5.0,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Separator
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    height: 40,
                    width: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),

                  // Diastolic
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diastolic.toString(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'DIA',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (showTrend && diastolicTrend != null) ...[
                          const SizedBox(height: 8),
                          _buildTrendIndicator(
                            context,
                            diastolicTrend!,
                            isUpTrend: diastolicTrend! > 0,
                            showColor: diastolicTrend!.abs() > 5.0,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Pulse (if available)
                  if (pulse != null) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      height: 40,
                      width: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pulse.toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'PULSE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (showTrend && pulseTrend != null) ...[
                            const SizedBox(height: 8),
                            _buildTrendIndicator(
                              context,
                              pulseTrend!,
                              isUpTrend: pulseTrend! > 0,
                              showColor: pulseTrend!.abs() > 5.0,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Timestamp
              if (timestamp != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatTimestamp(timestamp!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context, double value,
      {required bool isUpTrend, required bool showColor}) {
    final theme = Theme.of(context);
    final trendColor = isUpTrend
        ? (showColor
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface.withValues(alpha: 0.6))
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUpTrend ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: trendColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${value.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
