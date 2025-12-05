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
/// X-axis: Systolic (80-200 mmHg), Y-axis: Diastolic (40-120 mmHg)
class ClinicalZones {
  static const List<ClinicalZone> zones = [
    // Note: The plan had some zone definitions that need correction
    // Using medically accurate AHA/ACC guidelines

    // Low: <90 systolic OR <60 diastolic
    ClinicalZone(
      name: 'Low',
      bounds: Rect.fromLTWH(80, 40, 10, 20), // 80-90 systolic, 40-60 diastolic
      color: Color(0xFF2196F3), // Blue
      description: 'Low: <90/<60',
      category: BloodPressureCategory.low,
    ),

    // Normal: 90-120 systolic AND 60-80 diastolic
    ClinicalZone(
      name: 'Normal',
      bounds: Rect.fromLTWH(90, 60, 30, 20), // 90-120 systolic, 60-80 diastolic
      color: Color(0xFF4CAF50), // Green
      description: 'Normal: 90-120/60-80',
      category: BloodPressureCategory.normal,
    ),

    // Elevated: 121-129 systolic AND 60-80 diastolic
    ClinicalZone(
      name: 'Elevated',
      bounds: Rect.fromLTWH(121, 60, 9, 20), // 121-129 systolic, 60-80 diastolic
      color: Color(0xFFFF9800), // Orange
      description: 'Elevated: 121-129/60-80',
      category: BloodPressureCategory.elevated,
    ),

    // Stage 1: 130-139 systolic OR 81-89 diastolic
    ClinicalZone(
      name: 'Stage 1',
      bounds: Rect.fromLTWH(130, 81, 10, 9), // 130-139 systolic, 81-89 diastolic
      color: Color(0xFFFF5722), // Deep Orange
      description: 'Stage 1: 130-139/81-89',
      category: BloodPressureCategory.stage1,
    ),

    // Stage 2: >=140 systolic OR >=90 diastolic (extends to 200/120)
    ClinicalZone(
      name: 'Stage 2',
      bounds: Rect.fromLTWH(140, 90, 60, 30), // 140-200 systolic, 90-120 diastolic
      color: Color(0xFFF44336), // Red
      description: 'Stage 2: ≥140/≥90',
      category: BloodPressureCategory.stage2,
    ),
  ];

  static Color getCategoryColor(BloodPressureCategory category) {
    final zone = zones.firstWhere((z) => z.category == category);
    return zone.color;
  }

  static String getCategoryDescription(BloodPressureCategory category) {
    final zone = zones.firstWhere((z) => z.category == category);
    return zone.description;
  }
}

/// Custom painter for Clinical Scatter Plot
class ClinicalScatterPainter extends CustomPainter {
  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;
  final double? zoomLevel;
  final Offset? panOffset;

  // Performance optimization: Lazy loading with viewport culling
  static const int _maxVisiblePoints = 1000; // Limit visible points for performance
  static final _cachedPoints = <String, List<Offset>>{};

  const ClinicalScatterPainter({
    required this.readings,
    this.selectedReading,
    this.zoomLevel,
    this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set up drawing area with padding
    const padding = 40.0;
    final drawArea = Rect.fromLTWH(
      padding,
      padding,
      size.width - 2 * padding,
      size.height - 2 * padding
    );

    // Apply transformations
    if (zoomLevel != null && zoomLevel! > 1.0) {
      canvas.scale(zoomLevel!, zoomLevel!);
    }

    if (panOffset != null) {
      canvas.translate(panOffset!.dx, panOffset!.dy);
    }

    // Draw background zones
    _drawClinicalZones(canvas, drawArea);

    // Draw grid lines
    _drawGridLines(canvas, drawArea);

    // Draw axes
    _drawAxes(canvas, drawArea);

    // Draw data points
    _drawDataPoints(canvas, drawArea);

    // Draw selection highlight
    if (selectedReading != null) {
      _drawSelectionHighlight(canvas, drawArea, selectedReading!);
    }
  }

  void _drawClinicalZones(Canvas canvas, Rect drawArea) {
    for (final zone in ClinicalZones.zones) {
      // Scale zone bounds to drawing area
      final scaledBounds = _scaleRectToDrawingArea(zone.bounds, drawArea);

      final zonePaint = Paint()
        ..color = zone.color.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;

      canvas.drawRect(scaledBounds, zonePaint);

      // Draw zone border
      final borderPaint = Paint()
        ..color = zone.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRect(scaledBounds, borderPaint);
    }
  }

  void _drawGridLines(Canvas canvas, Rect drawArea) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Vertical grid lines (systolic)
    for (int i = 0; i <= 12; i++) {
      final x = drawArea.left + (i * drawArea.width / 12);
      canvas.drawLine(
        Offset(x, drawArea.top),
        Offset(x, drawArea.bottom),
        gridPaint,
      );
    }

    // Horizontal grid lines (diastolic)
    for (int i = 0; i <= 8; i++) {
      final y = drawArea.top + (i * drawArea.height / 8);
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
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    // X-axis labels (systolic)
    for (int i = 0; i <= 6; i++) {
      final value = 80 + (i * 20);
      final x = drawArea.left + (i * drawArea.width / 6);
      final y = drawArea.bottom + 15;

      _drawText(canvas, value.toString(), Offset(x, y), textStyle, align: TextAlign.center);
    }

    // Y-axis labels (diastolic)
    for (int i = 0; i <= 4; i++) {
      final value = 40 + (i * 20);
      final x = drawArea.left - 10;
      final y = drawArea.bottom - (i * drawArea.height / 4);

      _drawText(canvas, value.toString(), Offset(x, y), textStyle, align: TextAlign.right);
    }

    // Axis titles
    final titleStyle = textStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    _drawText(canvas, 'Systolic (mmHg)',
      Offset(drawArea.center.dx, drawArea.bottom + 35), titleStyle, align: TextAlign.center);

    _drawText(canvas, 'Diastolic (mmHg)',
      Offset(drawArea.left - 35, drawArea.center.dy), titleStyle, align: TextAlign.center,
      isVertical: true);
  }

  void _drawDataPoints(Canvas canvas, Rect drawArea) {
    // Performance optimization: Viewport culling and sampling for large datasets
    List<BloodPressureReading> visibleReadings = readings;

    if (readings.length > _maxVisiblePoints) {
      // Sample data points for very large datasets
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

      // Skip points outside viewport (culling)
      if (!_isPointInViewport(point, drawArea)) continue;

      // Use cached color lookup
      final color = colorCache.putIfAbsent(
        reading.category,
        () => ClinicalZones.getCategoryColor(reading.category),
      );

      final isSelected = reading == selectedReading;

      // Don't draw regular point if it's selected (will be drawn with highlight)
      if (isSelected) continue;

      // Subtle shadow for depth
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(point + const Offset(1, 1), 4.5, shadowPaint);

      // Main point with enhanced appearance
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 4.5, pointPaint);

      // White border with improved thickness
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(point, 4.5, borderPaint);

      // Inner highlight for glass effect
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point - const Offset(1.5, 1.5), 1.5, highlightPaint);
    }
  }

  void _drawSelectionHighlight(Canvas canvas, Rect drawArea, BloodPressureReading reading) {
    final point = _scalePointToDrawingArea(
      Offset(reading.systolic.toDouble(), reading.diastolic.toDouble()),
      drawArea
    );

    final color = ClinicalZones.getCategoryColor(reading.category);

    // Enhanced highlight for selected point
    final pulseSize = 16.0;

    // Outer glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(point, pulseSize + 4, glowPaint);

    // Middle highlight ring
    final highlightPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(point, pulseSize, highlightPaint);

    // Inner bright center
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, 3, centerPaint);

    // Animated selection ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(point, pulseSize + 1, ringPaint);

    // Secondary ring with category color
    final categoryRingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(point, pulseSize + 3, categoryRingPaint);
  }

  Offset _scalePointToDrawingArea(Offset dataPoint, Rect drawArea) {
    // Scale data point (systolic: 80-200, diastolic: 40-120) to drawing area
    final x = drawArea.left + ((dataPoint.dx - 80) / (200 - 80)) * drawArea.width;
    final y = drawArea.bottom - ((dataPoint.dy - 40) / (120 - 40)) * drawArea.height;
    return Offset(x, y);
  }

  // Performance optimization: Check if point is within extended viewport
  bool _isPointInViewport(Offset point, Rect drawArea) {
    // Extend viewport slightly to include points that might be partially visible
    const margin = 10.0;
    return point.dx >= drawArea.left - margin &&
           point.dx <= drawArea.right + margin &&
           point.dy >= drawArea.top - margin &&
           point.dy <= drawArea.bottom + margin;
  }

  Rect _scaleRectToDrawingArea(Rect dataRect, Rect drawArea) {
    // Scale data rectangle (systolic: 80-200, diastolic: 40-120) to drawing area
    final left = drawArea.left + ((dataRect.left - 80) / (200 - 80)) * drawArea.width;
    final top = drawArea.bottom - ((dataRect.top - 40) / (120 - 40)) * drawArea.height;
    final right = drawArea.left + ((dataRect.right - 80) / (200 - 80)) * drawArea.width;
    final bottom = drawArea.bottom - ((dataRect.bottom - 40) / (120 - 40)) * drawArea.height;
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
      textPainter.paint(canvas, position);
    } else {
      // Rotate text for vertical axis
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(-math.pi / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ClinicalScatterPainter oldDelegate) {
    // Performance optimization: More granular repaint checking
    if (readings.length != oldDelegate.readings.length) return true;

    // Check if selected reading changed (most common interaction)
    if (selectedReading != oldDelegate.selectedReading) return true;

    // Check if viewport changed significantly
    if (zoomLevel != oldDelegate.zoomLevel || panOffset != oldDelegate.panOffset) return true;

    // Only check data content if counts are same and no other changes
    if (readings.length > 500) {
      // For large datasets, only check first and last elements
      if (readings.first != oldDelegate.readings.first ||
          readings.last != oldDelegate.readings.last) return true;
    } else {
      // For smaller datasets, check all elements
      for (int i = 0; i < readings.length; i++) {
        if (readings[i] != oldDelegate.readings[i]) return true;
      }
    }

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
  });

  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;
  final Function(BloodPressureReading?)? onReadingSelected;

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
      // Light haptic feedback for selection
      HapticFeedback.lightImpact();

      setState(() {
        _selectedReading = reading;
      });
      widget.onReadingSelected?.call(reading);
      _showTooltip(reading, details.globalPosition);
    } else {
      // Deselect if tapping on empty space
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
      // Medium haptic feedback for long press
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

    final tooltipWidth = 250.0;
    final tooltipHeight = 180.0;

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
              if (isDetailed) ...[
                const SizedBox(height: 8),
                Text(
                  'Long press for more options',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    const padding = 40.0;
    final drawArea = Rect.fromLTWH(
      padding,
      padding,
      size.width - 2 * padding,
      size.height - 2 * padding
    );

    // Reverse calculate data coordinates from tap position
    final systolicValue = 80 + ((position.dx - drawArea.left) / drawArea.width) * (200 - 80);
    final diastolicValue = 120 - ((position.dy - drawArea.top) / drawArea.height) * (120 - 40);

    // Adaptive touch tolerance for different screen sizes
    final tolerance = isSmallMobile ? 25.0 : isMobile ? 20.0 : 15.0;

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
    // Scale data point (systolic: 80-200, diastolic: 40-120) to drawing area
    final x = drawArea.left + ((dataPoint.dx - 80) / (200 - 80)) * drawArea.width;
    final y = drawArea.bottom - ((dataPoint.dy - 40) / (120 - 40)) * drawArea.height;
    return Offset(x, y);
  }

  void _showTooltip(BloodPressureReading reading, Offset globalPosition) {
    // Remove any existing tooltip
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
                if (reading.notes?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes: ${reading.notes ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_tooltipEntry!);

    // Auto-hide tooltip after 3 seconds
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
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Accessibility helper methods
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.readings.isEmpty) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _navigateReading(-1); // Previous reading
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _navigateReading(1); // Next reading
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _navigateReading(-1); // Previous reading
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _navigateReading(1); // Next reading
        return KeyEventResult.handled;
      case LogicalKeyboardKey.space:
        _selectCurrentReading();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        _clearSelection();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _navigateReading(int direction) {
    final currentIndex = widget.readings.indexOf(_selectedReading ?? widget.readings.first);
    var newIndex = currentIndex + direction;

    // Wrap around navigation
    if (newIndex < 0) newIndex = widget.readings.length - 1;
    if (newIndex >= widget.readings.length) newIndex = 0;

    final newReading = widget.readings[newIndex];
    _selectReading(newReading);

    // Announce selection to screen reader
    _announceReading(newReading);
  }

  void _selectCurrentReading() {
    if (_selectedReading != null) {
      widget.onReadingSelected?.call(_selectedReading);
      _announceSelection(_selectedReading!);
    }
  }

  void _clearSelection() {
    _selectReading(null);
    widget.onReadingSelected?.call(null);
    _announceDeselection();
  }

  void _selectReading(BloodPressureReading? reading) {
    setState(() {
      _selectedReading = reading;
    });
  }

  void _announceReading(BloodPressureReading reading) {
    final date = _formatAccessibilityDate(reading.timestamp);
    final category = reading.category.name.toUpperCase();
    final announcement = '$date: ${reading.systolic} over ${reading.diastolic} millimeters mercury, $category category. ${reading.heartRate} beats per minute.';

    SemanticsService.announce(announcement, TextDirection.ltr);
  }

  void _announceSelection(BloodPressureReading reading) {
    final announcement = 'Selected: ${reading.systolic}/${reading.diastolic} mmHg, ${reading.category.name}. Double tap to view details.';
    SemanticsService.announce(announcement, TextDirection.ltr);
  }

  void _announceDeselection() {
    SemanticsService.announce('Selection cleared', TextDirection.ltr);
  }

  String _formatAccessibilityDate(DateTime timestamp) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
  }

  Widget _buildAccessibleHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Blood Pressure Classification',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: 'Chart instructions',
          child: Text(
            'Tap to select • Long press for details • Use arrow keys to navigate',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibleChart(BuildContext context) {
    return Semantics(
      label: 'Scatter plot with ${widget.readings.length} blood pressure readings',
      hint: 'Shows systolic versus diastolic pressure with AHA clinical zones',
      child: CustomPaint(
        painter: ClinicalScatterPainter(
          readings: widget.readings,
          selectedReading: _selectedReading,
          zoomLevel: _zoomLevel,
          panOffset: _panOffset,
        ),
      ),
    );
  }

  Widget _buildAccessibleZoneLegend(BuildContext context) {
    return Semantics(
      label: 'Clinical zone legend',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ClinicalZones.zones.map((zone) =>
          Semantics(
            label: '${zone.name} zone: ${zone.description}',
            child: _buildZoneLegendItem(
              color: zone.color,
              name: zone.name,
              description: zone.description,
            ),
          )
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Blood Pressure Classification Chart',
      hint: 'Interactive scatter plot showing blood pressure readings. Use arrow keys to navigate, Space to select, Escape to deselect.',
      child: Focus(
        focusNode: FocusNode(),
        autofocus: false,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onTapUp: _handleTap,
          onLongPressEnd: _handleLongPress,
          onScaleStart: (details) {
            // Hide tooltip when starting to scale/zoom
            _hideTooltip();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccessibleHeader(context),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildAccessibleChart(context),
                ),
                const SizedBox(height: 16),
                _buildAccessibleZoneLegend(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoneLegend(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ClinicalZones.zones.map((zone) =>
        _buildZoneLegendItem(
          color: zone.color,
          name: zone.name,
          description: zone.description,
        )
      ).toList(),
    );
  }

  Widget _buildZoneLegendItem({required Color color, required String name, required String description}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}