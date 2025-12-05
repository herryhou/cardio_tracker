# Blood Pressure Dual-Chart Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement comprehensive dual-chart UI/UX system with Clinical Scatter Plot and Time-Series Line Chart per specification

**Architecture:** Replace existing simple charts with sophisticated dual-chart system featuring medical-grade visualizations, interactive linking, and responsive design

**Tech Stack:** Flutter, Custom Painters for scatter plot, syncfl_chart for time-series, Provider state management

---

## Current State Analysis

### ✅ Existing Infrastructure
- **Data Model:** Complete `BloodPressureReading` with clinical categorization
- **Categories:** Enum with 6 levels (low, normal, elevated, stage1, stage2, crisis)
- **Provider:** `BloodPressureProvider` with data management
- **Screens:** Basic History, Distribution, and Dashboard with simple charts
- **Theme:** Comprehensive Material Design 3 theme system

### 🎯 Target Implementation
- **Clinical Scatter Plot:** X=Systolic (80-200), Y=Diastolic (40-120) with AHA zones
- **Time-Series Chart:** Dual-line (Systolic/Diastolic) with time aggregation
- **Interactive Linking:** Cross-chart data point highlighting
- **Responsive Design:** Mobile-first with tablet support

---

## Phase 1: Clinical Scatter Plot Implementation

### Task 1.1: Create Clinical Scatter Plot Widget

**Files:**
- Create: `lib/widgets/clinical_scatter_plot.dart`
- Modify: `lib/screens/history_screen.dart`

**Step 1: Define AHA Clinical Zones**
```dart
class ClinicalZone {
  final String name;
  final Rect bounds;
  final Color color;
  final String description;
}

static const List<ClinicalZone> ahaZones = [
  ClinicalZone('Normal', Rect.fromLTWH(90, 60, 30, 20), Colors.green, 'Normal: <120/<80'),
  ClinicalZone('Elevated', Rect.fromLTWH(120, 80, 10, 5), Colors.orange, 'Elevated: 120-129/<80'),
  ClinicalZone('Stage 1', Rect.fromLTWH(130, 85, 10, 5), Colors.deepOrange, 'Stage 1: 130-139/85-89'),
  ClinicalZone('Stage 2', Rect.fromLTWH(140, 90, 60, 30), Colors.red, 'Stage 2: ≥140/≥90'),
  ClinicalZone('Crisis', Rect.fromLTWH(180, 120, 20, 0), Colors.purple, 'Crisis: ≥180/≥120'),
];
```

**Step 2: Custom Painter Implementation**
```dart
class ClinicalScatterPainter extends CustomPainter {
  final List<BloodPressureReading> readings;
  final BloodPressureReading? selectedReading;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background zones with transparency
    // Draw grid lines and axis labels
    // Plot data points with category-based colors
    // Highlight selected reading
  }
}
```

**Step 3: Interactive Features**
- Tap detection for data point selection
- Zoom/pan with gesture detection
- Tooltip display on tap/long press

**Step 4: Integration into History Screen**
- Replace existing chart with scatter plot
- Add zone legend
- Implement responsive sizing

### Task 1.2: Add Scatter Plot Interactions

**Files:**
- Modify: `lib/widgets/clinical_scatter_plot.dart`

**Step 1: Gesture Detection**
```dart
GestureDetector(
  onTapDown: (details) {
    final position = details.localPosition;
    final reading = findReadingAtPosition(position);
    if (reading != null) {
      onReadingSelected?.call(reading);
      showTooltip(context, reading, position);
    }
  },
  onScaleStart: (details) => handleZoomStart(details),
  onScaleUpdate: (details) => handleZoomUpdate(details),
)
```

**Step 2: Tooltip Implementation**
- Custom tooltip widget with reading details
- Position calculation to avoid screen edges
- Fade-in/out animations

---

## Phase 2: Time-Series Line Chart Implementation

### Task 2.1: Create Time-Series Chart Widget

**Files:**
- Create: `lib/widgets/time_series_chart.dart`
- Add to pubspec.yaml: `syncfusion_flutter_charts: ^24.1.47`

**Step 1: Time Series Data Model**
```dart
class TimeSeriesData {
  final DateTime timestamp;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final String? notes;
  final BloodPressureCategory category;

  // Aggregation methods for different time ranges
  static List<TimeSeriesData> aggregateByDay(List<BloodPressureReading> readings);
  static List<TimeSeriesData> aggregateByWeek(List<BloodPressureReading> readings);
  static List<TimeSeriesData> aggregateByMonth(List<BloodPressureReading> readings);
}
```

**Step 2: Chart Configuration**
```dart
SfCartesianChart(
  primaryXAxis: DateTimeCategoryAxis(
    title: AxisTitle(text: 'Date'),
    labelFormat: 'MMM dd',
  ),
  primaryYAxis: NumericAxis(
    title: AxisTitle(text: 'Blood Pressure (mmHg)'),
    minimum: 60,
    maximum: 200,
  ),
  series: <ChartSeries>[
    // Systolic line
    LineSeries<TimeSeriesData, DateTime>(
      dataSource: timeSeriesData,
      xValueMapper: (data, _) => data.timestamp,
      yValueMapper: (data, _) => data.systolic,
      color: Colors.blue[700]!,
      width: 3,
    ),
    // Diastolic line
    LineSeries<TimeSeriesData, DateTime>(
      dataSource: timeSeriesData,
      xValueMapper: (data, _) => data.timestamp,
      yValueMapper: (data, _) => data.diastolic,
      color: Colors.blue[300]!,
      width: 2,
      dashArray: <double>[5, 5],
    ),
  ],
)
```

### Task 2.2: Time Range Selector & Aggregation

**Files:**
- Modify: `lib/widgets/time_series_chart.dart`

**Step 1: Time Range Controls**
```dart
enum TimeRange { day, week, month, year }

Widget _buildTimeRangeSelector() {
  return SegmentedButton<TimeRange>(
    segments: [
      ButtonSegment(value: TimeRange.day, label: Text('Day')),
      ButtonSegment(value: TimeRange.week, label: Text('Week')),
      ButtonSegment(value: TimeRange.month, label: Text('Month')),
      ButtonSegment(value: TimeRange.year, label: Text('Year')),
    ],
    selected: {selectedRange},
    onSelectionChanged: (Set<TimeRange> selection) {
      onRangeChanged?.call(selection.first);
    },
  );
}
```

**Step 2: Data Aggregation Logic**
- Daily: Show individual readings
- Weekly: Average daily readings
- Monthly: Average weekly readings
- Year: Average monthly readings

### Task 2.3: Interactive Time Series Features

**Files:**
- Modify: `lib/widgets/time_series_chart.dart`

**Step 1: Data Point Selection**
```dart
onChartTouchInteraction: (ChartTouchInteractionArgs args) {
  if (args.position != null) {
    final dataPoint = findDataPointAtPosition(args.position!);
    if (dataPoint != null) {
      onReadingSelected?.call(dataPoint.reading);
      showTimeSeriesTooltip(dataPoint);
    }
  }
}
```

**Step 2: Custom Tooltip Design**
- Reading details with clinical category
- Heart rate and notes display
- Highlight corresponding scatter plot point

---

## Phase 3: Cross-Chart Integration & Linking

### Task 3.1: Create Chart Container with Linking

**Files:**
- Create: `lib/widgets/dual_chart_container.dart`
- Modify: `lib/screens/history_screen.dart`

**Step 1: State Management for Selection**
```dart
class DualChartProvider extends ChangeNotifier {
  BloodPressureReading? _selectedReading;

  BloodPressureReading? get selectedReading => _selectedReading;

  void selectReading(BloodPressureReading? reading) {
    _selectedReading = reading;
    notifyListeners();
  }
}
```

**Step 2: Chart Container Layout**
```dart
class DualChartContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DualChartProvider>(
      builder: (context, chartProvider, child) {
        return Column(
          children: [
            // Time Range Selector
            _buildTimeRangeSelector(context),

            // Clinical Scatter Plot (40% height)
            Expanded(
              flex: 4,
              child: ClinicalScatterPlot(
                readings: filteredReadings,
                selectedReading: chartProvider.selectedReading,
                onReadingSelected: chartProvider.selectReading,
              ),
            ),

            const SizedBox(height: 16),

            // Time Series Chart (60% height)
            Expanded(
              flex: 6,
              child: TimeSeriesChart(
                readings: filteredReadings,
                selectedReading: chartProvider.selectedReading,
                onReadingSelected: chartProvider.selectReading,
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### Task 3.2: Synchronized Highlighting

**Files:**
- Modify: `lib/widgets/clinical_scatter_plot.dart`
- Modify: `lib/widgets/time_series_chart.dart`

**Step 1: Visual Highlight Effects**
```dart
// In scatter plot
if (reading == selectedReading) {
  // Draw larger, pulsing circle
  final paint = Paint()
    ..color = categoryColor.withOpacity(0.8)
    ..style = PaintingStyle.fill
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

  canvas.drawCircle(point, 12, paint);
}

// In time series chart
if (dataPoint.reading == selectedReading) {
  // Highlight data point with animation
  return ChartMarkerSettings(
    color: Colors.red,
    borderWidth: 3,
    borderColor: Colors.white,
    width: 16,
    height: 16,
  );
}
```

### Task 3.3: Responsive Design & Mobile Optimization

**Files:**
- Modify: `lib/widgets/dual_chart_container.dart`

**Step 1: Layout Adaptation**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isTablet = constraints.maxWidth > 600;
    final scatterHeight = isTablet ? 300.0 : 200.0;
    final seriesHeight = isTablet ? 450.0 : 300.0;

    return Column(
      children: [
        SizedBox(height: scatterHeight, child: ClinicalScatterPlot(...)),
        SizedBox(height: seriesHeight, child: TimeSeriesChart(...)),
      ],
    );
  },
)
```

**Step 2: Touch Optimization**
- Larger touch targets on mobile
- Swipe gestures for time navigation
- Pinch-to-zoom on both charts

---

## Phase 4: Integration & Testing

### Task 4.1: History Screen Integration

**Files:**
- Modify: `lib/screens/history_screen.dart`

**Step 1: Replace Existing Layout**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ChangeNotifierProvider(
      create: (_) => DualChartProvider(),
      child: Consumer<BloodPressureProvider>(
        builder: (context, bpProvider, child) {
          return DualChartContainer(
            readings: bpProvider.readings,
          );
        },
      ),
    ),
  );
}
```

**Step 2: Navigation Integration**
- Update bottom navigation
- Add chart-specific settings
- Implement data refresh

### Task 4.2: Performance Optimization

**Files:**
- Modify: `lib/widgets/clinical_scatter_plot.dart`
- Modify: `lib/widgets/time_series_chart.dart`

**Step 1: Data Management**
```dart
// Lazy loading for large datasets
class LazyChartData {
  final int batchSize = 100;
  List<BloodPressureReading> _loadedReadings = [];

  Future<void> loadMoreData() async {
    // Load data in batches
  }
}
```

**Step 2: Canvas Optimization**
- Use `RepaintBoundary` for charts
- Implement viewport culling for scatter plot
- Cache zone backgrounds

---

## Phase 5: Accessibility & Polish

### Task 5.1: Accessibility Features

**Files:**
- Modify: All chart widgets

**Step 1: Screen Reader Support**
```dart
Semantics(
  label: 'Clinical scatter plot showing ${readings.length} blood pressure readings',
  hint: 'Tap to select readings for details',
  child: CustomPaint(painter: scatterPainter),
)
```

**Step 2: High Contrast Support**
- Alternative color schemes
- Pattern fills for zones
- Larger text options

### Task 5.2: Final Polish & Testing

**Files:**
- All chart and screen files

**Step 1: Visual Refinements**
- Smooth animations
- Professional typography
- Consistent spacing and colors

**Step 2: Testing Checklist**
- [ ] All clinical zones display correctly
- [ ] Data point linking works bidirectionally
- [ ] Time aggregation accurate
- [ ] Responsive layout on all screen sizes
- [ ] Touch interactions work smoothly
- [ ] Accessibility features functional
- [ ] Performance acceptable with 1000+ readings

---

## Implementation Dependencies

### Required Packages (add to pubspec.yaml):
```yaml
dependencies:
  syncfusion_flutter_charts: ^24.1.47  # Time series charts
  intl: ^0.19.0                       # Date formatting
```

### New Files to Create:
- `lib/widgets/clinical_scatter_plot.dart`
- `lib/widgets/time_series_chart.dart`
- `lib/widgets/dual_chart_container.dart`
- `lib/providers/dual_chart_provider.dart`

### Files to Modify:
- `lib/screens/history_screen.dart`
- `lib/main.dart` (add DualChartProvider)
- `pubspec.yaml` (add dependencies)

---

## Testing Strategy

### Unit Tests:
- Clinical zone boundary calculations
- Data aggregation logic
- State management behavior

### Integration Tests:
- Cross-chart linking functionality
- Time range selector behavior
- Data loading and refresh

### UI Tests:
- Touch interactions on both charts
- Responsive layout behavior
- Accessibility features

---

## Success Metrics

### Functional Requirements:
✅ All AHA clinical zones accurately displayed
✅ Cross-chart reading selection and highlighting
✅ Time-based data aggregation (day/week/month/year)
✅ Smooth zoom/pan interactions
✅ Responsive design for mobile and tablet

### Performance Requirements:
✅ <100ms initial render with 500 readings
✅ <16ms frame rate during interactions
✅ Efficient memory usage with 1000+ readings

### UX Requirements:
✅ Intuitive touch interactions
✅ Clear visual hierarchy
✅ Professional medical-grade appearance
✅ WCAG 2.1 AA accessibility compliance

---

This comprehensive plan addresses all requirements from the Blood Pressure Chart specification while leveraging existing infrastructure and ensuring production-ready quality.

**Plan complete and ready for subagent-driven implementation using superpowers:executing-plans.**