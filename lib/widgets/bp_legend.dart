import 'package:flutter/material.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';
import 'package:cardio_tracker/widgets/clinical_scatter_plot.dart';

/// A shared legend widget for blood pressure clinical zones
class BPLegend extends StatelessWidget {
  const BPLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surfaceContainer
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Pressure Categories',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 20,
                runSpacing: 12,
                children: ClinicalZones.zones
                    .map((zone) => _buildLegendItem(context, zone))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, ClinicalZone zone) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: zone.color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: zone.color.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Legend text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  zone.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getZoneTextColor(context, zone.category),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  zone.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getZoneTextColor(BuildContext context, BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.normal:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87);
      case BloodPressureCategory.elevated:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87);
      case BloodPressureCategory.stage1:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87);
      case BloodPressureCategory.stage2:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87);
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87);
    }
  }
}