import 'package:flutter/material.dart';

/// Professional medical app icons and indicators
/// Production-ready SVG-style icons with consistent design
class AppIcons {
  // Heart/Blood Pressure Icons
  static const IconData heart = Icons.favorite;
  static const IconData heartOutline = Icons.favorite_border;
  static const IconData monitor = Icons.monitor_heart;
  static const IconData pulse = Icons.favorite_border;

  // Medical Icons
  static const IconData medical = Icons.local_hospital;
  static const IconData health = Icons.health_and_safety;
  static const IconData emergency = Icons.emergency;

  // Data & Analytics Icons
  static const IconData trend = Icons.trending_up;
  static const IconData trendDown = Icons.trending_down;
  static const IconData chart = Icons.bar_chart;
  static const IconData scatter = Icons.scatter_plot;
  static const IconData analytics = Icons.analytics;

  // Action Icons
  static const IconData add = Icons.add_circle;
  static const IconData addOutline = Icons.add_circle_outline;
  static const IconData export = Icons.file_download;
  static const IconData import = Icons.file_upload;
  static const IconData settings = Icons.settings;
  static const IconData filter = Icons.filter_list;
  static const IconData search = Icons.search;
  static const IconData more = Icons.more_vert;

  // Navigation Icons
  static const IconData home = Icons.home;
  static const IconData dashboard = Icons.dashboard;
  static const IconData distribution = Icons.pie_chart;
  static const IconData history = Icons.history;
  static const IconData calendar = Icons.calendar_today;

  // Status Icons
  static const IconData check = Icons.check_circle;
  static const IconData checkOutline = Icons.check_circle_outline;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.error;
  static const IconData info = Icons.info;

  // Category Icons
  static const IconData normal = Icons.check_circle;
  static const IconData elevated = Icons.trending_up;
  static const IconData stage1 = Icons.warning;
  static const IconData stage2 = Icons.error;
  static const IconData crisis = Icons.emergency;
}

/// Custom widget for professional medical status indicators
class MedicalStatusIndicator extends StatelessWidget {
  final String status;
  final IconData icon;
  final Color color;
  final double size;
  final bool showLabel;
  final TextStyle? labelStyle;

  const MedicalStatusIndicator({
    super.key,
    required this.status,
    required this.icon,
    required this.color,
    this.size = 24.0,
    this.showLabel = true,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size / 2),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: size * 0.6,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: labelStyle ?? TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.6,
        color: color,
      ),
    );
  }
}

/// Professional app logo widget
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 48.0,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;

    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              AppIcons.monitor,
              color: Colors.white,
              size: size * 0.6,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cardio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                Text(
                  'Tracker',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: iconColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        AppIcons.monitor,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}