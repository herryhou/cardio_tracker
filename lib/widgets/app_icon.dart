import 'package:flutter/material.dart';
import 'dart:math' as math;

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
            style: labelStyle ??
                TextStyle(
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

/// Custom heart icon widget using CustomPainter
/// Provides a professional vector heart icon for the app
class HeartIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final bool filled;

  const HeartIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.red,
    this.strokeWidth = 2.0,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HeartIconPainter(
          color: color,
          strokeWidth: strokeWidth,
          filled: filled,
        ),
      ),
    );
  }
}

/// Custom painter for drawing a heart shape
class _HeartIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool filled;

  _HeartIconPainter({
    required this.color,
    required this.strokeWidth,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint.style = PaintingStyle.stroke;
    }

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Calculate control points for the heart shape
    final centerX = width / 2;
    final centerY = height / 2;
    final heartWidth = width * 0.8;
    final heartHeight = height * 0.7;

    // Start from the top center of the heart
    final topX = centerX;
    final topY = centerY - heartHeight * 0.3;

    // Left curve control points
    final leftControlX1 = centerX - heartWidth * 0.5;
    final leftControlY1 = centerY - heartHeight * 0.5;
    final leftControlX2 = centerX - heartWidth * 0.6;
    final leftControlY2 = centerY - heartHeight * 0.1;

    // Right curve control points
    final rightControlX1 = centerX + heartWidth * 0.5;
    final rightControlY1 = centerY - heartHeight * 0.5;
    final rightControlX2 = centerX + heartWidth * 0.6;
    final rightControlY2 = centerY - heartHeight * 0.1;

    // Bottom point of the heart
    final bottomX = centerX;
    final bottomY = centerY + heartHeight * 0.5;

    // Draw the heart shape
    path.moveTo(topX, topY);

    // Left curve
    path.cubicTo(
      leftControlX1, leftControlY1,
      leftControlX2, leftControlY2,
      centerX - heartWidth * 0.3, centerY,
    );

    // Bottom left curve
    path.cubicTo(
      centerX - heartWidth * 0.3, centerY + heartHeight * 0.2,
      centerX - heartWidth * 0.1, centerY + heartHeight * 0.3,
      bottomX, bottomY,
    );

    // Bottom right curve
    path.cubicTo(
      centerX + heartWidth * 0.1, centerY + heartHeight * 0.3,
      centerX + heartWidth * 0.3, centerY + heartHeight * 0.2,
      centerX + heartWidth * 0.3, centerY,
    );

    // Right curve
    path.cubicTo(
      rightControlX2, rightControlY2,
      rightControlX1, rightControlY1,
      topX, topY,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _HeartIconPainter) {
      return oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth ||
          oldDelegate.filled != filled;
    }
    return true;
  }
}
