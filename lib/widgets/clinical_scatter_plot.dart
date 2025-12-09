import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';
import '../utils/bp_format.dart';

// Default height for the clinical scatter chart when not constrained by parent
const double kClinicalScatterChartHeight =
    546.0; // 420 * 1.3 = 546 (30% increase)

/// AHA Clinical Zone definition for blood pressure categorization
class ClinicalZone {
  final String name;
  final Rect bounds;
  final Color color;
  final String description;
  final BloodPressureCategory category;

  const ClinicalZone({
    required this.name,
    required this.bounds,
    required this.color,
    required this.description,
    required this.category,
  });
}

/// AHA Clinical Zones following medical guidelines
/// SWAPPED: X-axis: Diastolic (50-120 mmHg), Y-axis: Systolic (70-170 mmHg)
/// Note: Zones are drawn from largest area to smallest for proper layering
class ClinicalZones {
  static const List<ClinicalZone> zones = [
    // Normal: < 120 systolic AND < 80 diastolic
    // SWAPPED: X: 50-80 (diastolic), Y: 70-120 (systolic)
    ClinicalZone(
      name: 'Normal',
      bounds: Rect.fromLTWH(50, 70, 30, 50), // 50-80 diastolic, 70-120 systolic
      color: Color.fromARGB(255, 185, 255, 203), // Green-500
      description: '<120/<80',
      category: BloodPressureCategory.normal,
    ),

    // Elevated: 120-129 systolic AND < 80 diastolic
    // SWAPPED: X: 50-80 (diastolic), Y: 120-129 (systolic)
    ClinicalZone(
      name: 'Elevated',
      bounds: Rect.fromLTWH(50, 120, 30, 9), // 50-80 diastolic, 120-129 systolic
      color: Color.fromARGB(255, 255, 248, 167), // Amber-500
      description: '120-129/<80',
      category: BloodPressureCategory.elevated,
    ),

    // Stage 1: 130-139 systolic OR 80-89 diastolic
    // SWAPPED: This is a complex L-shaped zone
    // We'll split it into two rectangles for simplicity
    // Rectangle 1: X: 50-120, Y: 130-139 (systolic range)
    // Rectangle 2: X: 80-120, Y: 70-170 (diastolic range)
    // For now, we'll use a bounding box
    ClinicalZone(
      name: 'Stage 1 Hypertension',
      bounds: Rect.fromLTWH(50, 70, 70, 69), // 50-120 diastolic, 70-139 systolic
      color: Color.fromARGB(255, 255, 207, 156), // Orange-600
      description: '130-139/80-89',
      category: BloodPressureCategory.stage1,
    ),

    // Stage 2: >=140 systolic OR >=90 diastolic
    // SWAPPED: X: 50-120, Y: 140-170 (full range for high readings)
    ClinicalZone(
      name: 'Stage 2 Hypertension',
      bounds:
          Rect.fromLTWH(50, 70, 70, 100), // 50-120 diastolic, 70-170 systolic
      color: Color.fromARGB(255, 255, 165, 165), // Red-600
      description: '≥140/≥90',
      category: BloodPressureCategory.stage2,
    ),
  ];

  static Color getCategoryColor(BloodPressureCategory category) {
    try {
      final zone = zones.firstWhere((z) => z.category == category);
      return zone.color;
    } catch (e) {
      return Colors.grey;
    }
  }

  static String getCategoryDescription(BloodPressureCategory category) {
    try {
      final zone = zones.firstWhere((z) => z.category == category);
      return zone.description;
    } catch (e) {
      return 'Unknown';
    }
  }
}

/// Custom painter for Vertical Bar Distribution Chart
class ClinicalBarDistributionPainter extends CustomPainter {
  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;

  const ClinicalBarDistributionPainter({
    required this.readings,
    this.selectedReading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    // Set up drawing area with padding
    const padding = 50.0;
    const leftPadding = 70.0; // Extra space for Y-axis labels
    const bottomPadding = 70.0; // Extra space for X-axis labels
    final drawArea = Rect.fromLTWH(
        leftPadding,
        padding,
        size.width - leftPadding - padding,
        size.height - padding - bottomPadding);

    // Draw background
    _drawBackground(canvas, drawArea);

    // Draw clinical zones as horizontal bands
    _drawClinicalZoneBands(canvas, drawArea);

    // Draw grid lines
    _drawGridLines(canvas, drawArea);

    // Draw axes and labels
    _drawAxes(canvas, drawArea);

    // Draw vertical bars
    _drawVerticalBars(canvas, drawArea);

    // Draw selection highlight
    if (selectedReading != null) {
      _drawSelectionHighlight(canvas, drawArea, selectedReading!);
    }
  }

  void _drawBackground(Canvas canvas, Rect drawArea) {
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(drawArea, bgPaint);
  }

  void _drawClinicalZoneBands(Canvas canvas, Rect drawArea) {
    // Draw clinical zones as horizontal bands
    final zones = [
      {'name': 'Normal', 'min': 50.0, 'max': 80.0, 'color': Color.fromARGB(255, 185, 255, 203)},
      {'name': 'Elevated', 'min': 80.0, 'max': 80.0, 'color': Color.fromARGB(255, 255, 248, 167)},
      {'name': 'Stage 1', 'min': 80.0, 'max': 90.0, 'color': Color.fromARGB(255, 255, 207, 156)},
      {'name': 'Stage 2', 'min': 90.0, 'max': 120.0, 'color': Color.fromARGB(255, 255, 165, 165)},
    ];

    for (final zone in zones) {
      final topY = drawArea.bottom - (((zone['max'] as double) - 50) / 70) * drawArea.height;
      final bottomY = drawArea.bottom - (((zone['min'] as double) - 50) / 70) * drawArea.height;

      final zoneRect = Rect.fromLTWH(drawArea.left, topY, drawArea.width, bottomY - topY);

      final zonePaint = Paint()
        ..color = (zone['color'] as Color).withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRect(zoneRect, zonePaint);
    }
  }

  void _drawGridLines(Canvas canvas, Rect drawArea) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Vertical grid lines (time)
    if (readings.isNotEmpty) {
      for (int i = 0; i < readings.length; i++) {
        final x = drawArea.left + (i * drawArea.width / (readings.length - 1));
        canvas.drawLine(
          Offset(x, drawArea.top),
          Offset(x, drawArea.bottom),
          gridPaint,
        );
      }
    }

    // Horizontal grid lines (diastolic)
    for (int i = 0; i <= 7; i++) {
      final y = drawArea.top + (i * drawArea.height / 7);
      canvas.drawLine(
        Offset(drawArea.left, y),
        Offset(drawArea.right, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Rect drawArea) {
    final axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0;

    // X-axis (time)
    canvas.drawLine(
      Offset(drawArea.left, drawArea.bottom),
      Offset(drawArea.right, drawArea.bottom),
      axisPaint,
    );

    // Y-axis (pressure)
    canvas.drawLine(
      Offset(drawArea.left, drawArea.top),
      Offset(drawArea.left, drawArea.bottom),
      axisPaint,
    );

    // Axis labels
    _drawAxisLabels(canvas, drawArea);
  }

  void _drawAxisLabels(Canvas canvas, Rect drawArea) {
    const textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    // Y-axis labels (pressure)
    for (int i = 0; i <= 7; i++) {
      final value = 50 + (i * 10);
      final x = drawArea.left - 10;
      final y = drawArea.bottom - (i * drawArea.height / 7);

      _drawText(canvas, value.toString(), Offset(x, y), textStyle,
          align: TextAlign.right);
    }

    // Axis titles
    final titleStyle = textStyle.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    _drawText(canvas, 'Time (Readings)',
        Offset(drawArea.center.dx, drawArea.bottom + 45), titleStyle,
        align: TextAlign.center);

    _drawText(canvas, 'Pressure (mmHg)',
        Offset(drawArea.left - 55, drawArea.center.dy), titleStyle,
        align: TextAlign.center, isVertical: true);
  }

  void _drawVerticalBars(Canvas canvas, Rect drawArea) {
    if (readings.isEmpty) return;

    final barWidth = drawArea.width / readings.length * 0.7;

    for (int i = 0; i < readings.length; i++) {
      final reading = readings[i];
      final x = drawArea.left + (i * drawArea.width / (readings.length - 1)) - barWidth / 2;

      // Calculate Y positions (inverted for chart coordinates)
      final systolicY = drawArea.bottom - ((reading.systolic - 50) / 70) * drawArea.height;
      final diastolicY = drawArea.bottom - ((reading.diastolic - 50) / 70) * drawArea.height;

      // Determine color based on category
      Color barColor;
      switch (reading.category) {
        case BloodPressureCategory.normal:
          barColor = const Color(0xFF10B981);
          break;
        case BloodPressureCategory.elevated:
          barColor = const Color(0xFFF59E0B);
          break;
        case BloodPressureCategory.stage1:
          barColor = const Color(0xFFF97316);
          break;
        case BloodPressureCategory.stage2:
          barColor = const Color(0xFFEF4444);
          break;
        default:
          barColor = Colors.grey;
      }

      // Draw gradient bar from diastolic to systolic
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            barColor.withOpacity(0.8), // Systolic (top)
            barColor.withOpacity(0.3), // Diastolic (bottom)
          ],
        ).createShader(Rect.fromLTWH(x, systolicY, barWidth, diastolicY - systolicY));

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, systolicY, barWidth, diastolicY - systolicY),
        const Radius.circular(3),
      );

      canvas.drawRRect(barRect, gradientPaint);

      // Highlight selected bar
      if (reading == selectedReading) {
        final highlightPaint = Paint()
          ..color = barColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(barRect, highlightPaint);
      }
    }
  }

  void _drawSelectionHighlight(
      Canvas canvas, Rect drawArea, BloodPressureReading reading) {
    // Find the bar index
    final index = readings.indexOf(reading);
    if (index == -1) return;

    final barWidth = drawArea.width / readings.length * 0.7;
    final x = drawArea.left + (index * drawArea.width / (readings.length - 1)) - barWidth / 2;
    final systolicY = drawArea.bottom - ((reading.systolic - 50) / 70) * drawArea.height;
    final diastolicY = drawArea.bottom - ((reading.diastolic - 50) / 70) * drawArea.height;

    // Draw selection indicator
    final selectionPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final selectionRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 5, systolicY - 5, barWidth + 10, diastolicY - systolicY + 10),
      const Radius.circular(5),
    );

    canvas.drawRRect(selectionRect, selectionPaint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style,
      {TextAlign align = TextAlign.left, bool isVertical = false}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );

    textPainter.layout();

    if (!isVertical) {
      final offset = align == TextAlign.center
          ? Offset(position.dx - textPainter.width / 2, position.dy)
          : align == TextAlign.right
              ? Offset(position.dx - textPainter.width, position.dy)
              : position;
      textPainter.paint(canvas, offset);
    } else {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(-math.pi / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ClinicalBarDistributionPainter oldDelegate) {
    if (readings.length != oldDelegate.readings.length) return true;
    if (selectedReading != oldDelegate.selectedReading) return true;
    return false;
  }
}

/// Custom painter for Clinical Scatter Plot
class ClinicalScatterPainter extends CustomPainter {
  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;
  final double? zoomLevel;
  final Offset? panOffset;
  final bool showTrendLine;

  // Performance optimization: Lazy loading with viewport culling
  static const int _maxVisiblePoints = 1000;

  // Grid line color following medical standards
  static const Color gridLineColor = Color(0xFFE0E0E0);

  const ClinicalScatterPainter({
    required this.readings,
    this.selectedReading,
    this.zoomLevel,
    this.panOffset,
    this.showTrendLine = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set up drawing area with padding
    const padding = 50.0;
    const leftPadding = 70.0; // Extra space for Y-axis labels
    const bottomPadding = 70.0; // Extra space for X-axis labels
    final drawArea = Rect.fromLTWH(
        leftPadding,
        padding,
        size.width - leftPadding - padding,
        size.height - padding - bottomPadding);

    // Draw background
    _drawBackground(canvas, drawArea);

    // Draw clinical zones
    _drawClinicalZones(canvas, drawArea);

    // Draw grid lines
    _drawGridLines(canvas, drawArea);

    // Draw axes and labels
    _drawAxes(canvas, drawArea);

    // Apply transformations for data points only
    canvas.save();
    if (zoomLevel != null && zoomLevel! > 1.0) {
      final center = drawArea.center;
      canvas.translate(center.dx, center.dy);
      canvas.scale(zoomLevel!, zoomLevel!);
      canvas.translate(-center.dx, -center.dy);
    }

    if (panOffset != null) {
      canvas.translate(panOffset!.dx, panOffset!.dy);
    }

    // Draw data points
    _drawDataPoints(canvas, drawArea);

    // Draw selection highlight
    if (selectedReading != null) {
      _drawSelectionHighlight(canvas, drawArea, selectedReading!);
    }

    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Rect drawArea) {
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(drawArea, bgPaint);
  }

  void _drawClinicalZones(Canvas canvas, Rect drawArea) {
    // Draw zones in order - from largest to smallest for proper layering
    final orderedZones = [
      ClinicalZones.zones
          .firstWhere((z) => z.category == BloodPressureCategory.stage2),
      ClinicalZones.zones
          .firstWhere((z) => z.category == BloodPressureCategory.stage1),
      ClinicalZones.zones
          .firstWhere((z) => z.category == BloodPressureCategory.elevated),
      ClinicalZones.zones
          .firstWhere((z) => z.category == BloodPressureCategory.normal),
    ];

    for (final zone in orderedZones) {
      // Scale zone bounds to drawing area with swapped axes
      final scaledBounds = _scaleRectToDrawingAreaSwapped(zone.bounds, drawArea);

      final zonePaint = Paint()
        ..color = zone.color.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawRect(scaledBounds, zonePaint);

      // Draw zone border only for the outermost edges
      if (zone.name != 'Normal') {
        // Skip border for Normal zone as it's overlapped
        final borderPaint = Paint()
          ..color = zone.color.withValues(alpha: 1.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        canvas.drawRect(scaledBounds, borderPaint);
      }
    }
  }

  void _drawGridLines(Canvas canvas, Rect drawArea) {
    final gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 0.5;

    // Vertical grid lines (diastolic - now on X-axis) - every 10 mmHg
    // Range: 50-120 mmHg = 70 units = 7 intervals of 10
    for (int i = 0; i <= 7; i++) {
      final x = drawArea.left + (i * drawArea.width / 7);
      canvas.drawLine(
        Offset(x, drawArea.top),
        Offset(x, drawArea.bottom),
        gridPaint,
      );
    }

    // Horizontal grid lines (systolic - now on Y-axis) - every 10 mmHg
    // Range: 70-170 mmHg = 100 units = 10 intervals of 10
    for (int i = 0; i <= 10; i++) {
      final y = drawArea.top + (i * drawArea.height / 10);
      canvas.drawLine(
        Offset(drawArea.left, y),
        Offset(drawArea.right, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Rect drawArea) {
    final axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0;

    // X-axis (systolic)
    canvas.drawLine(
      Offset(drawArea.left, drawArea.bottom),
      Offset(drawArea.right, drawArea.bottom),
      axisPaint,
    );

    // Y-axis (diastolic)
    canvas.drawLine(
      Offset(drawArea.left, drawArea.top),
      Offset(drawArea.left, drawArea.bottom),
      axisPaint,
    );

    // Axis labels
    _drawAxisLabels(canvas, drawArea);
  }

  void _drawAxisLabels(Canvas canvas, Rect drawArea) {
    const textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    // X-axis labels (diastolic - now on X-axis)
    // Range: 50-120 mmHg
    for (int i = 0; i <= 7; i++) {
      final value = 50 + (i * 10);
      final x = drawArea.left + (i * drawArea.width / 7);
      final y = drawArea.bottom + 20;

      _drawText(canvas, value.toString(), Offset(x, y), textStyle,
          align: TextAlign.center);
    }

    // Y-axis labels (systolic - now on Y-axis)
    // Range: 70-170 mmHg
    for (int i = 0; i <= 10; i++) {
      final value = 70 + (i * 10);
      final x = drawArea.left - 10;
      final y = drawArea.bottom - (i * drawArea.height / 10);

      _drawText(canvas, value.toString(), Offset(x, y), textStyle,
          align: TextAlign.right);
    }

    // Axis titles - SWAPPED for medical standards
    final titleStyle = textStyle.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // X-axis title (now Diastolic)
    _drawText(canvas, 'Diastolic (mmHg)',
        Offset(drawArea.center.dx, drawArea.bottom + 45), titleStyle,
        align: TextAlign.center);

    // Y-axis title (now Systolic)
    _drawText(canvas, 'Systolic (mmHg)',
        Offset(drawArea.left - 55, drawArea.center.dy), titleStyle,
        align: TextAlign.center, isVertical: true);
  }

  void _drawDataPoints(Canvas canvas, Rect drawArea) {
    // Performance optimization: Viewport culling and sampling for large datasets
    List<BloodPressureReading> visibleReadings = readings;

    if (readings.length > _maxVisiblePoints) {
      final step = (readings.length / _maxVisiblePoints).ceil();
      visibleReadings = List.generate(_maxVisiblePoints, (index) {
        final actualIndex = index * step;
        return readings[actualIndex.clamp(0, readings.length - 1)];
      });
    }

    // Pre-compute colors to avoid repeated lookups
    final Map<BloodPressureCategory, Color> colorCache = {};

    for (final reading in visibleReadings) {
      // SWAPPED axes: diastolic on X-axis, systolic on Y-axis
      final point = _scalePointToDrawingAreaSwapped(
          Offset(reading.diastolic.toDouble(), reading.systolic.toDouble()),
          drawArea);

      // Skip points outside viewport
      if (!_isPointInViewport(point, drawArea)) continue;

      // Use cached color lookup
      final color = colorCache.putIfAbsent(
        reading.category,
        () => ClinicalZones.getCategoryColor(reading.category),
      );

      final isSelected = reading == selectedReading;

      // Don't draw regular point if it's selected
      if (isSelected) continue;

      // Darken the color for solid circles
      final darkerColor = _darkenColor(color);

      // Main solid point - increased to 22px radius (44×44 dp total)
      final pointPaint = Paint()
        ..color = darkerColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 22, pointPaint);
    }
  }

  void _drawSelectionHighlight(
      Canvas canvas, Rect drawArea, BloodPressureReading reading) {
    // SWAPPED axes: diastolic on X-axis, systolic on Y-axis
    final point = _scalePointToDrawingAreaSwapped(
        Offset(reading.diastolic.toDouble(), reading.systolic.toDouble()),
        drawArea);

    final color = ClinicalZones.getCategoryColor(reading.category);
    final darkerColor = _darkenColor(color);

    // Outer glow - larger for 44×44 dp points
    final glowPaint = Paint()
      ..color = darkerColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(point, 35, glowPaint);

    // Selection ring
    final ringPaint = Paint()
      ..color = darkerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(point, 28, ringPaint);

    // Center solid point
    final centerPaint = Paint()
      ..color = darkerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, 22, centerPaint);
  }

  Offset _scalePointToDrawingArea(Offset dataPoint, Rect drawArea) {
    // Scale data point (systolic: 70-170, diastolic: 50-120) to drawing area
    final x =
        drawArea.left + ((dataPoint.dx - 70) / (170 - 70)) * drawArea.width;
    final y =
        drawArea.bottom - ((dataPoint.dy - 50) / (120 - 50)) * drawArea.height;
    return Offset(x, y);
  }

  Offset _scalePointToDrawingAreaSwapped(Offset dataPoint, Rect drawArea) {
    // SWAPPED: Scale data point (diastolic: 50-120 on X, systolic: 70-170 on Y) to drawing area
    final x =
        drawArea.left + ((dataPoint.dx - 50) / (120 - 50)) * drawArea.width;
    final y =
        drawArea.bottom - ((dataPoint.dy - 70) / (170 - 70)) * drawArea.height;
    return Offset(x, y);
  }

  bool _isPointInViewport(Offset point, Rect drawArea) {
    const margin = 10.0;
    return point.dx >= drawArea.left - margin &&
        point.dx <= drawArea.right + margin &&
        point.dy >= drawArea.top - margin &&
        point.dy <= drawArea.bottom + margin;
  }

  Color _darkenColor(Color color) {
    // Darken a color by reducing its brightness significantly
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.45).clamp(0.0, 1.0)).toColor();
  }

  Rect _scaleRectToDrawingArea(Rect dataRect, Rect drawArea) {
    // Scale data rectangle (systolic: 70-170, diastolic: 50-120) to drawing area
    final left =
        drawArea.left + ((dataRect.left - 70) / (170 - 70)) * drawArea.width;
    final top =
        drawArea.bottom - ((dataRect.top - 50) / (120 - 50)) * drawArea.height;
    final right =
        drawArea.left + ((dataRect.right - 70) / (170 - 70)) * drawArea.width;
    final bottom = drawArea.bottom -
        ((dataRect.bottom - 50) / (120 - 50)) * drawArea.height;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _scaleRectToDrawingAreaSwapped(Rect dataRect, Rect drawArea) {
    // SWAPPED: Scale data rectangle (diastolic: 50-120 on X, systolic: 70-170 on Y) to drawing area
    final left =
        drawArea.left + ((dataRect.left - 50) / (120 - 50)) * drawArea.width;
    final top =
        drawArea.bottom - ((dataRect.top - 70) / (170 - 70)) * drawArea.height;
    final right =
        drawArea.left + ((dataRect.right - 50) / (120 - 50)) * drawArea.width;
    final bottom = drawArea.bottom -
        ((dataRect.bottom - 70) / (170 - 70)) * drawArea.height;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style,
      {TextAlign align = TextAlign.left, bool isVertical = false}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );

    textPainter.layout();

    if (!isVertical) {
      final offset = align == TextAlign.center
          ? Offset(position.dx - textPainter.width / 2, position.dy)
          : align == TextAlign.right
              ? Offset(position.dx - textPainter.width, position.dy)
              : position;
      textPainter.paint(canvas, offset);
    } else {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(-math.pi / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ClinicalScatterPainter oldDelegate) {
    if (readings.length != oldDelegate.readings.length) return true;
    if (selectedReading != oldDelegate.selectedReading) return true;
    if (zoomLevel != oldDelegate.zoomLevel ||
        panOffset != oldDelegate.panOffset) return true;
    if (showTrendLine != oldDelegate.showTrendLine) return true;

    return false;
  }
}

/// Clinical Scatter Plot Widget
class ClinicalScatterPlot extends StatefulWidget {
  const ClinicalScatterPlot({
    super.key,
    required this.readings,
    this.selectedReading,
    this.onReadingSelected,
    this.showTrendLine = true,
  });

  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;
  final Function(BloodPressureReading?)? onReadingSelected;
  final bool showTrendLine;

  @override
  State<ClinicalScatterPlot> createState() => _ClinicalScatterPlotState();
}

class _ClinicalScatterPlotState extends State<ClinicalScatterPlot> {
  final double _zoomLevel = 1.0;
  final Offset _panOffset = Offset.zero;
  BloodPressureReading? _selectedReading;
  OverlayEntry? _tooltipEntry;

  @override
  void initState() {
    super.initState();
    _selectedReading = widget.selectedReading;
  }

  @override
  void dispose() {
    _tooltipEntry?.remove();
    super.dispose();
  }

  @override
  void didUpdateWidget(ClinicalScatterPlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedReading != oldWidget.selectedReading) {
      _selectedReading = widget.selectedReading;
    }
  }

  void _handleTap(TapUpDetails details) {
    final position = details.localPosition;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final reading = _findReadingAtPosition(position, size);

    if (reading != null) {
      HapticFeedback.lightImpact();

      setState(() {
        _selectedReading = reading;
      });
      widget.onReadingSelected?.call(reading);
      _showTooltip(reading, details.globalPosition);
    } else {
      setState(() {
        _selectedReading = null;
      });
      widget.onReadingSelected?.call(null);
      _hideTooltip();
    }
  }

  void _handleLongPress(LongPressEndDetails details) {
    final position = details.localPosition;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final reading = _findReadingAtPosition(position, size);
    if (reading != null) {
      HapticFeedback.mediumImpact();
      _showDetailedTooltip(reading, details.globalPosition);
    }
  }

  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  void _showDetailedTooltip(
      BloodPressureReading reading, Offset globalPosition) {
    _hideTooltip();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    final tooltipWidth = 280.0;
    final tooltipHeight = 200.0;

    double left = globalPosition.dx;
    double top = globalPosition.dy;

    final screenSize = MediaQuery.of(context).size;
    if (left + tooltipWidth > screenSize.width) {
      left = screenSize.width - tooltipWidth - 16;
    }
    if (top + tooltipHeight > screenSize.height) {
      top = globalPosition.dy - tooltipHeight - 16;
    }

    final overlay = Overlay.of(context);
    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: _buildTooltipCard(reading, isDetailed: true),
      ),
    );
    overlay.insert(_tooltipEntry!);
  }

  Widget _buildTooltipCard(BloodPressureReading reading,
      {required bool isDetailed}) {
    final color = ClinicalZones.getCategoryColor(reading.category);

    // Format date/time for display
    final dateFormat = DateTime.now().year == reading.timestamp.year
        ? 'EEEE, MMMM d, y • h:mm a'
        : 'EEEE, MMMM d, y • h:mm a';
    final formattedDate = dateFormat
        .replaceAll('EEEE', _getFullDayName(reading.timestamp.weekday))
        .replaceAll('MMMM', _getFullMonthName(reading.timestamp.month))
        .replaceAll('d', reading.timestamp.day.toString())
        .replaceAll('y', reading.timestamp.year.toString())
        .replaceAll('h', reading.timestamp.hour > 12
            ? (reading.timestamp.hour - 12).toString()
            : (reading.timestamp.hour == 0 ? '12' : reading.timestamp.hour.toString()))
        .replaceAll('mm', reading.timestamp.minute.toString().padLeft(2, '0'))
        .replaceAll('a', reading.timestamp.hour >= 12 ? 'PM' : 'AM');

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Blood Pressure Reading',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.cardsGap),
              _buildDetailRow('Blood Pressure:', formatBloodPressure(reading.systolic, reading.diastolic)),
              _buildDetailRow('Heart Rate:', '${reading.heartRate} bpm'),
              _buildDetailRow('Category:',
                  ClinicalZones.getCategoryDescription(reading.category)),
              SizedBox(height: AppSpacing.sm),
              _buildDetailRow('Date & Time:', formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (reading.notes?.isNotEmpty ?? false) ...[
                SizedBox(height: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Notes: ${reading.notes ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
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

  String _getFullDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  String _getFullMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  BloodPressureReading? _findReadingAtPosition(Offset position, Size size) {
    const padding = 50.0;
    const leftPadding = 70.0;
    final drawArea = Rect.fromLTWH(leftPadding, padding,
        size.width - leftPadding - padding, size.height - 2 * padding);

    // SWAPPED: Reverse calculate data coordinates from tap position
    // X-axis is now diastolic (50-120), Y-axis is now systolic (70-170)
    final diastolicValue =
        50 + ((position.dx - drawArea.left) / drawArea.width) * (120 - 50);
    final systolicValue =
        170 - ((position.dy - drawArea.top) / drawArea.height) * (170 - 70);

    // Increased tolerance for 44×44 dp points
    final tolerance = 30.0;

    BloodPressureReading? closestReading;
    double minDistance = double.infinity;

    for (final reading in widget.readings) {
      // SWAPPED axes: diastolic on X, systolic on Y
      final readingPoint = _scalePointToDrawingAreaForHitTestingSwapped(
          Offset(reading.diastolic.toDouble(), reading.systolic.toDouble()),
          drawArea);

      final distance = (position - readingPoint).distance;
      if (distance < tolerance && distance < minDistance) {
        minDistance = distance;
        closestReading = reading;
      }
    }

    return closestReading;
  }

  Offset _scalePointToDrawingAreaForHitTesting(
      Offset dataPoint, Rect drawArea) {
    final x =
        drawArea.left + ((dataPoint.dx - 60) / (200 - 60)) * drawArea.width;
    final y =
        drawArea.bottom - ((dataPoint.dy - 40) / (130 - 40)) * drawArea.height;
    return Offset(x, y);
  }

  Offset _scalePointToDrawingAreaForHitTestingSwapped(
      Offset dataPoint, Rect drawArea) {
    // SWAPPED: diastolic on X-axis (50-120), systolic on Y-axis (70-170)
    final x =
        drawArea.left + ((dataPoint.dx - 50) / (120 - 50)) * drawArea.width;
    final y =
        drawArea.bottom - ((dataPoint.dy - 70) / (170 - 70)) * drawArea.height;
    return Offset(x, y);
  }

  void _showTooltip(BloodPressureReading reading, Offset globalPosition) {
    _tooltipEntry?.remove();

    // Format date/time for display
    final dateFormat = DateTime.now().year == reading.timestamp.year
        ? 'MMM d, h:mm a'
        : 'MMM d, y, h:mm a';
    final formattedDate = dateFormat
        .replaceAll('MMM', _getMonthAbbreviation(reading.timestamp.month))
        .replaceAll('d', reading.timestamp.day.toString())
        .replaceAll('y', reading.timestamp.year.toString())
        .replaceAll('h', reading.timestamp.hour > 12
            ? (reading.timestamp.hour - 12).toString()
            : (reading.timestamp.hour == 0 ? '12' : reading.timestamp.hour.toString()))
        .replaceAll('mm', reading.timestamp.minute.toString().padLeft(2, '0'))
        .replaceAll('a', reading.timestamp.hour >= 12 ? 'PM' : 'AM');

    final overlay = Overlay.of(context);
    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: globalPosition.dx,
        top: globalPosition.dy,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.cardsGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Blood Pressure Reading',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                _buildDetailRow('Blood Pressure:', formatBloodPressure(reading.systolic, reading.diastolic)),
                _buildDetailRow('Heart Rate:', '${reading.heartRate} bpm'),
                _buildDetailRow('Category:',
                    ClinicalZones.getCategoryDescription(reading.category)),
                SizedBox(height: AppSpacing.xs),
                _buildDetailRow('Date:', formattedDate),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_tooltipEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      _tooltipEntry?.remove();
    });
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs/2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: style ?? AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          Expanded(
            child: GestureDetector(
              onTapUp: _handleTap,
              onLongPressEnd: _handleLongPress,
              onScaleStart: (details) {
                _hideTooltip();
              },
              child: CustomPaint(
                painter: ClinicalScatterPainter(
                  readings: widget.readings,
                  selectedReading: _selectedReading,
                  zoomLevel: _zoomLevel,
                  panOffset: _panOffset,
                  showTrendLine: widget.showTrendLine,
                ),
                child: Container(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md + AppSpacing.xs),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey[20],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 20,
              runSpacing: 12,
              children: ClinicalZones.zones
                  .map((zone) => _buildEnhancedLegendItem(zone))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLegendItem(ClinicalZone zone) {
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
            margin: EdgeInsets.only(top: AppSpacing.xs/2),
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
                    color: _getZoneTextColor(zone.category),
                  ),
                ),
                SizedBox(height: AppSpacing.xs/2),
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

  Color _getZoneTextColor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return const Color(0xFF1E40AF); // Dark blue
      case BloodPressureCategory.normal:
        return const Color(0xFF065F46); // Dark green
      case BloodPressureCategory.elevated:
        return const Color(0xFF92400E); // Dark amber
      case BloodPressureCategory.stage1:
        return const Color(0xFFDC2626); // Red
      case BloodPressureCategory.stage2:
        return const Color(0xFF991B1B); // Dark red
      case BloodPressureCategory.crisis:
        return const Color(0xFF7F1D1D); // Very dark red
    }
  }
}
