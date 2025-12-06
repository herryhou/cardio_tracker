import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../models/blood_pressure_reading.dart';

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
/// X-axis: Systolic (60-200 mmHg), Y-axis: Diastolic (40-130 mmHg)
/// Note: Zones are drawn from largest area to smallest for proper layering
class ClinicalZones {
  static const List<ClinicalZone> zones = [
    // Normal: < 120 systolic AND < 80 diastolic
    ClinicalZone(
      name: 'Normal',
      bounds: Rect.fromLTWH(60, 40, 60, 40), // 60-120 systolic, 40-80 diastolic
      color: Color(0xFFC1FACF), // Green-500
      description: 'Normal: <120/<80',
      category: BloodPressureCategory.normal,
    ),

    // Elevated: 120-129 systolic AND < 80 diastolic
    ClinicalZone(
      name: 'Elevated',
      bounds: Rect.fromLTWH(60, 40, 69, 40), // 60-129 systolic, 40-80 diastolic
      color: Color(0xFFFAF5C1), // Amber-500
      description: 'Elevated: 120-129/<80',
      category: BloodPressureCategory.elevated,
    ),

    // Stage 1: 130-139 systolic OR 80-89 diastolic
    ClinicalZone(
      name: 'Stage 1 Hypertension',
      bounds: Rect.fromLTWH(60, 40, 79, 50), // 60-139 systolic, 40-90 diastolic
      color: Color(0xFFFAD8C1), // Orange-600
      description: 'Stage 1: 130-139/80-89',
      category: BloodPressureCategory.stage1,
    ),

    // Stage 2: >=140 systolic OR >=90 diastolic
    ClinicalZone(
      name: 'Stage 2 Hypertension',
      bounds: Rect.fromLTWH(60, 40, 140, 90), // 60-200 systolic, 40-130 diastolic
      color: Color(0xFFFAC1C1), // Red-600
      description: 'Stage 2: ≥140/≥90',
      category: BloodPressureCategory.stage2,
    ),

    // Low: <90 systolic OR <60 diastolic (drawn last for visibility)
    ClinicalZone(
      name: 'Low',
      bounds: Rect.fromLTWH(60, 40, 30, 20), // 60-90 systolic, 40-60 diastolic
      color: Color(0xFFC1F2FA), // Blue-500
      description: 'Low: <90/<60',
      category: BloodPressureCategory.low,
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

/// Custom painter for Clinical Scatter Plot
class ClinicalScatterPainter extends CustomPainter {
  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;
  final double? zoomLevel;
  final Offset? panOffset;
  final bool showTrendLine;

  // Performance optimization: Lazy loading with viewport culling
  static const int _maxVisiblePoints = 1000;

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
      size.height - padding - bottomPadding
    );

    // Draw background
    _drawBackground(canvas, drawArea);

    // Draw clinical zones
    _drawClinicalZones(canvas, drawArea);

    // Draw grid lines
    _drawGridLines(canvas, drawArea);

    // Draw trend line if enabled
    if (showTrendLine && readings.isNotEmpty) {
      _drawTrendLine(canvas, drawArea);
    }

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
      ClinicalZones.zones.firstWhere((z) => z.category == BloodPressureCategory.stage2),
      ClinicalZones.zones.firstWhere((z) => z.category == BloodPressureCategory.stage1),
      ClinicalZones.zones.firstWhere((z) => z.category == BloodPressureCategory.elevated),
      ClinicalZones.zones.firstWhere((z) => z.category == BloodPressureCategory.normal),
      ClinicalZones.zones.firstWhere((z) => z.category == BloodPressureCategory.low),
    ];

    for (final zone in orderedZones) {
      // Scale zone bounds to drawing area
      final scaledBounds = _scaleRectToDrawingArea(zone.bounds, drawArea);

      final zonePaint = Paint()
        ..color = zone.color.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawRect(scaledBounds, zonePaint);

      // Draw zone border only for the outermost edges
      if (zone.name != 'Low') { // Skip border for low zone as it's overlapped
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
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    // Vertical grid lines (systolic)
    for (int i = 0; i <= 14; i++) {
      final x = drawArea.left + (i * drawArea.width / 14);
      canvas.drawLine(
        Offset(x, drawArea.top),
        Offset(x, drawArea.bottom),
        gridPaint,
      );
    }

    // Horizontal grid lines (diastolic)
    for (int i = 0; i <= 9; i++) {
      final y = drawArea.top + (i * drawArea.height / 9);
      canvas.drawLine(
        Offset(drawArea.left, y),
        Offset(drawArea.right, y),
        gridPaint,
      );
    }
  }

  void _drawTrendLine(Canvas canvas, Rect drawArea) {
    if (readings.length < 2) return;

    // Calculate linear regression
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    final n = readings.length.toDouble();

    for (final reading in readings) {
      sumX += reading.systolic;
      sumY += reading.diastolic;
      sumXY += reading.systolic * reading.diastolic;
      sumX2 += reading.systolic * reading.systolic;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Draw trend line
    final trendPaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final startX = 60.0;
    final endX = 200.0;
    final startY = slope * startX + intercept;
    final endY = slope * endX + intercept;

    final start = _scalePointToDrawingArea(Offset(startX, startY), drawArea);
    final end = _scalePointToDrawingArea(Offset(endX, endY), drawArea);

    canvas.drawLine(start, end, trendPaint);

    // Draw trend line label
    final labelStyle = TextStyle(
      color: Colors.purple,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    _drawText(
      canvas,
      'Trend: y=${slope.toStringAsFixed(1)}x+${intercept.toStringAsFixed(0)}',
      Offset(drawArea.right - 120, drawArea.top + 10),
      labelStyle
    );
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

    // X-axis labels (systolic)
    for (int i = 0; i <= 7; i++) {
      final value = 60 + (i * 20);
      final x = drawArea.left + (i * drawArea.width / 7);
      final y = drawArea.bottom + 20;

      _drawText(canvas, value.toString(), Offset(x, y), textStyle, align: TextAlign.center);
    }

    // Y-axis labels (diastolic)
    for (int i = 0; i <= 9; i++) {
      final value = 40 + (i * 10);
      final x = drawArea.left - 10;
      final y = drawArea.bottom - (i * drawArea.height / 9);

      _drawText(canvas, value.toString(), Offset(x, y), textStyle, align: TextAlign.right);
    }

    // Axis titles
    final titleStyle = textStyle.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.bold,
    );

    _drawText(canvas, 'Systolic (mmHg)',
      Offset(drawArea.center.dx, drawArea.bottom + 45), titleStyle, align: TextAlign.center);

    _drawText(canvas, 'Diastolic (mmHg)',
      Offset(drawArea.left - 55, drawArea.center.dy), titleStyle, align: TextAlign.center,
      isVertical: true);
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
      final point = _scalePointToDrawingArea(
        Offset(reading.systolic.toDouble(), reading.diastolic.toDouble()),
        drawArea
      );

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

      // Draw shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(point + const Offset(1, 1), 4, shadowPaint);

      // Main point
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 4, pointPaint);

      // White border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(point, 4, borderPaint);
    }
  }

  void _drawSelectionHighlight(Canvas canvas, Rect drawArea, BloodPressureReading reading) {
    final point = _scalePointToDrawingArea(
      Offset(reading.systolic.toDouble(), reading.diastolic.toDouble()),
      drawArea
    );

    final color = ClinicalZones.getCategoryColor(reading.category);

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(point, 12, glowPaint);

    // Selection ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(point, 8, ringPaint);

    // Inner colored ring
    final colorRingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(point, 6, colorRingPaint);

    // Center point
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, 3, centerPaint);
  }

  Offset _scalePointToDrawingArea(Offset dataPoint, Rect drawArea) {
    // Scale data point (systolic: 60-200, diastolic: 40-130) to drawing area
    final x = drawArea.left + ((dataPoint.dx - 60) / (200 - 60)) * drawArea.width;
    final y = drawArea.bottom - ((dataPoint.dy - 40) / (130 - 40)) * drawArea.height;
    return Offset(x, y);
  }

  bool _isPointInViewport(Offset point, Rect drawArea) {
    const margin = 10.0;
    return point.dx >= drawArea.left - margin &&
           point.dx <= drawArea.right + margin &&
           point.dy >= drawArea.top - margin &&
           point.dy <= drawArea.bottom + margin;
  }

  Rect _scaleRectToDrawingArea(Rect dataRect, Rect drawArea) {
    // Scale data rectangle (systolic: 60-200, diastolic: 40-130) to drawing area
    final left = drawArea.left + ((dataRect.left - 60) / (200 - 60)) * drawArea.width;
    final top = drawArea.bottom - ((dataRect.top - 40) / (130 - 40)) * drawArea.height;
    final right = drawArea.left + ((dataRect.right - 60) / (200 - 60)) * drawArea.width;
    final bottom = drawArea.bottom - ((dataRect.bottom - 40) / (130 - 40)) * drawArea.height;
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
    if (zoomLevel != oldDelegate.zoomLevel || panOffset != oldDelegate.panOffset) return true;
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
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;
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

  void _showDetailedTooltip(BloodPressureReading reading, Offset globalPosition) {
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

  Widget _buildTooltipCard(BloodPressureReading reading, {required bool isDetailed}) {
    final color = ClinicalZones.getCategoryColor(reading.category);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 8),
                  Text(
                    'Blood Pressure Reading',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Systolic:', '${reading.systolic} mmHg'),
              _buildDetailRow('Diastolic:', '${reading.diastolic} mmHg'),
              _buildDetailRow('Heart Rate:', '${reading.heartRate} bpm'),
              _buildDetailRow('Category:', ClinicalZones.getCategoryDescription(reading.category)),
              if (reading.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
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

  BloodPressureReading? _findReadingAtPosition(Offset position, Size size) {
    const padding = 50.0;
    const leftPadding = 70.0;
    final drawArea = Rect.fromLTWH(
      leftPadding,
      padding,
      size.width - leftPadding - padding,
      size.height - 2 * padding
    );

    // Reverse calculate data coordinates from tap position
    final systolicValue = 60 + ((position.dx - drawArea.left) / drawArea.width) * (200 - 60);
    final diastolicValue = 130 - ((position.dy - drawArea.top) / drawArea.height) * (130 - 40);

    final tolerance = 20.0;

    BloodPressureReading? closestReading;
    double minDistance = double.infinity;

    for (final reading in widget.readings) {
      final readingPoint = _scalePointToDrawingAreaForHitTesting(
        Offset(reading.systolic.toDouble(), reading.diastolic.toDouble()),
        drawArea
      );

      final distance = (position - readingPoint).distance;
      if (distance < tolerance && distance < minDistance) {
        minDistance = distance;
        closestReading = reading;
      }
    }

    return closestReading;
  }

  Offset _scalePointToDrawingAreaForHitTesting(Offset dataPoint, Rect drawArea) {
    final x = drawArea.left + ((dataPoint.dx - 60) / (200 - 60)) * drawArea.width;
    final y = drawArea.bottom - ((dataPoint.dy - 40) / (130 - 40)) * drawArea.height;
    return Offset(x, y);
  }

  void _showTooltip(BloodPressureReading reading, Offset globalPosition) {
    _tooltipEntry?.remove();

    final overlay = Overlay.of(context);
    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: globalPosition.dx,
        top: globalPosition.dy,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Blood Pressure Reading',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Systolic:', '${reading.systolic} mmHg'),
                _buildDetailRow('Diastolic:', '${reading.diastolic} mmHg'),
                _buildDetailRow('Heart Rate:', '${reading.heartRate} bpm'),
                _buildDetailRow('Category:', ClinicalZones.getCategoryDescription(reading.category)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.scatter_plot_outlined,
                  color: Colors.grey[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Blood Pressure Classification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
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
          const SizedBox(height: 16),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: ClinicalZones.zones.map((zone) => _buildLegendItem(zone)).toList(),
    );
  }

  Widget _buildLegendItem(ClinicalZone zone) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: zone.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          zone.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}