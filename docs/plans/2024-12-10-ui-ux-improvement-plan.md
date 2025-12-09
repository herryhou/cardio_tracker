# Cardio Tracker App UI/UX Improvement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement comprehensive UI/UX improvements to the cardio tracker app based on the improvement checklist, focusing on medical accuracy, usability, accessibility, and modern design standards.

**Architecture:** Incrementally update existing Flutter components following Material Design 3 guidelines, improving accessibility, visual hierarchy, and user experience while maintaining existing functionality.

**Tech Stack:** Flutter, fl_chart package, Material Design 3, Provider state management, SQLite, Cloudflare KV sync

---

## PHASE 1: CRITICAL FIXES (Week 1)

### Task 1: Fix Blood Pressure Distribution Chart Axes (Medical Standard Compliance)

**Files:**
- Modify: `lib/screens/distribution_screen.dart`
- Modify: `lib/widgets/clinical_scatter_plot.dart`
- Test: `test/widgets/clinical_scatter_plot_test.dart`

**Step 1: Create test for correct axes configuration**

```dart
testWidgets('Clinical scatter plot has correct axes orientation', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ClinicalScatterPlot(readings: testReadings)
    )
  ));

  // Verify systolic is on Y-axis (vertical)
  expect(find.text('Systolic (mmHg)'), findsOneWidget);

  // Verify diastolic is on X-axis (horizontal)
  expect(find.text('Diastolic (mmHg)'), findsOneWidget);

  // Check grid lines exist
  expect(find.byType(FlGridData), findsOneWidget);
});
```

**Step 2: Run test to verify current state**

Run: `flutter test test/widgets/clinical_scatter_plot_test.dart`
Expected: Current implementation fails (axes swapped)

**Step 3: Update ClinicalScatterPlot to swap axes**

```dart
// In clinical_scatter_plot.dart
FlChartsData(
  lineBarsData: [
    LineChartBarData(
      spots: readings.map((r) => FlSpot(r.diastolic, r.systolic)).toList(), // Swapped: diastolic on X, systolic on Y
      // ... rest of configuration
    )
  ],
  gridData: FlGridData(
    show: true,
    drawVerticalLine: true,
    drawHorizontalLine: true,
    getDrawingVerticalLine: (value) {
      return FlLine(
        color: const Color(0xFFE0E0E0),
        strokeWidth: 1,
      );
    },
    getDrawingHorizontalLine: (value) {
      return FlLine(
        color: const Color(0xFFE0E0E0),
        strokeWidth: 1,
      );
    },
  ),
  // ...
)

// Update axis configuration
leftTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    interval: 10,
    getTitlesWidget: (value, meta) => Text('$value', style: TextStyle(fontSize: 12)),
  ),
  axisNameWidget: Text('Systolic (mmHg)', style: TextStyle(fontSize: 14)),
),
bottomTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    interval: 10,
    getTitlesWidget: (value, meta) => Text('$value', style: TextStyle(fontSize: 12)),
  ),
  axisNameWidget: Text('Diastolic (mmHg)', style: TextStyle(fontSize: 14)),
),
```

**Step 4: Update touch targets for data points**

```dart
// In scatter plot configuration
dotData: FlDotData(
  show: true,
  getDotPainter: (spot, percent, barData, index) {
    return FlDotCirclePainter(
      radius: 22, // 44dp diameter
      color: getBloodPressureColor(readings[index]),
      strokeWidth: 2,
      strokeColor: Colors.white,
    );
  },
),
```

**Step 5: Add tap interaction for tooltips**

```dart
// Add touch tooltip configuration
lineTouchData: LineTouchData(
  touchTooltipData: LineTouchTooltipData(
    tooltipBgColor: Colors.black87,
    tooltipRoundedRadius: 8,
    getTooltipItems: (touchedSpots) {
      return touchedSpots.map((spot) {
        final reading = readings[spot.spotIndex];
        return LineTooltipItem(
          '${reading.systolic}/${reading.diastolic} mmHg\n${DateFormat('MMM dd, HH:mm').format(reading.timestamp)}',
          TextStyle(color: Colors.white, fontSize: 12),
        );
      }).toList();
    },
  ),
),
```

**Step 6: Run test to verify it passes**

Run: `flutter test test/widgets/clinical_scatter_plot_test.dart`
Expected: PASS

**Step 7: Commit**

```bash
git add lib/widgets/clinical_scatter_plot.dart lib/screens/distribution_screen.dart test/widgets/clinical_scatter_plot_test.dart
git commit -m "fix: swap BP chart axes to medical standard (systolic Y, diastolic X)"
```

### Task 2: Ruthless Dashboard Simplification

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`
- Test: `test/screens/dashboard_screen_test.dart`

**Step 1: Write test for simplified dashboard**

```dart
testWidgets('Dashboard shows only essential elements', (tester) async {
  await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

  // Should NOT find these elements
  expect(find.textContaining('Good'), findsNothing);
  expect(find.text('Blood Pressure Analysis'), findsNothing);

  // SHOULD find these elements
  expect(find.byType(LatestReadingCard), findsOneWidget);
  expect(find.byType(SparklineChart), findsOneWidget);
  expect(find.byType(HistoricalChart), findsOneWidget);
  expect(find.byType(FloatingActionButton), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/screens/dashboard_screen_test.dart`
Expected: FAIL (currently shows extra elements)

**Step 3: Remove greeting and redundant elements**

```dart
// In dashboard_screen.dart, remove:
// - "Good afternoon" greeting widget
// - "Blood Pressure Analysis" header
// - Duplicate small overview cards

// Simplify to just:
Column(
  children: [
    // 2x height latest reading card
    Container(
      height: 200, // Increased from ~100
      child: LatestReadingCard(),
    ),
    SizedBox(height: 16),
    // Mini 7-day sparkline
    Container(
      height: 80,
      child: SparklineChart(),
    ),
    SizedBox(height: 16),
    // Full-width historical chart
    Expanded(
      child: HistoricalChart(),
    ),
  ],
)
```

**Step 4: Update LatestReadingCard to be larger**

```dart
// In reading_summary_card.dart or create new large_latest_reading_card.dart
Container(
  padding: EdgeInsets.all(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Latest Reading', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
      SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${latestReading.systolic}',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: getColorForReading(latestReading)),
          ),
          Text('/', style: TextStyle(fontSize: 40, color: Colors.grey[600])),
          Text(
            '${latestReading.diastolic}',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: getColorForReading(latestReading)),
          ),
          SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('mmHg', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
          ),
        ],
      ),
      Text(
        'Pulse: ${latestReading.pulse} bpm',
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    ],
  ),
)
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/screens/dashboard_screen_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/screens/dashboard_screen.dart lib/widgets/reading_summary_card.dart
git commit -m "feat: simplify dashboard layout - remove clutter, increase reading card size"
```

### Task 3: Fix All Color Contrast Issues (WCAG AA Compliance)

**Files:**
- Modify: `lib/theme/app_theme.dart`
- Modify: `lib/screens/dashboard_screen.dart`
- Modify: `lib/widgets/reading_summary_card.dart`
- Test: `test/theme/contrast_test.dart`

**Step 1: Create contrast validation test**

```dart
test('Color palette meets WCAG AA contrast ratios', () {
  final theme = AppTheme();

  // Check light gray text contrast against white background
  expect(
    Theme.of(context).brightness == Brightness.light
      ? isContrastRatioValid(Theme.of(context).textTheme.bodyLarge!.color!, Colors.white)
      : true,
    isTrue,
    reason: 'Text must have 4.5:1 contrast ratio',
  );

  // Check Stage 1 badge colors
  expect(isContrastRatioValid(Colors.white, Color(0xFF9C27B0)), isTrue);
});
```

**Step 2: Update app theme colors**

```dart
// In app_theme.dart
static const Color primaryTextColor = Color(0xFF212121); // Changed from #666666
static const Color secondaryTextColor = Color(0xFF757575);

static ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 48, color: primaryTextColor),
    headlineMedium: TextStyle(fontSize: 20, color: primaryTextColor),
    bodyLarge: TextStyle(fontSize: 14, color: primaryTextColor),
  ),
  // Update Stage 1 colors
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryPurple,
    brightness: Brightness.light,
    secondary: Color(0xFFFF9800), // Orange for Stage 1
    surface: Colors.white,
    onSurface: primaryTextColor,
  ),
);
```

**Step 3: Update blood pressure category colors**

```dart
// In blood_pressure_reading.dart or create constants file
class BloodPressureCategory {
  static const Color normal = Color(0xFF4CAF50);     // Green
  static const Color elevated = Color(0xFFFFEB3B);    // Yellow
  static const Color stage1 = Color(0xFFFF9800);     // Orange (changed)
  static const Color stage2 = Color(0xFFF44336);     // Red
  static const Color crisis = Color(0xFF9C27B0);     // Purple
  static const Color low = Color(0xFF2196F3);        // Blue
}

// Update badge colors with white text for better contrast
Color getCategoryBadgeColor(BloodPressureCategory category) {
  switch(category) {
    case BloodPressureCategory.stage1:
      return BloodPressureCategory.stage1;
    // ... other cases
  }
}

Color getCategoryTextColor(BloodPressureCategory category) {
  // Always use white text for colored badges
  return Colors.white;
}
```

**Step 4: Update all text colors throughout the app**

```dart
// Replace all #666666 with #212121
// Replace all instances of Colors.grey[600] with Color(0xFF212121)
// Ensure all labels use primaryTextColor
```

**Step 5: Run contrast tests**

Run: `flutter test test/theme/contrast_test.dart`
Expected: All tests PASS

**Step 6: Commit**

```bash
git add lib/theme/app_theme.dart lib/models/blood_pressure_reading.dart lib/widgets/reading_summary_card.dart
git commit -m "fix: improve color contrast to WCAG AA standards"
```

### Task 4: Establish Typography System

**Files:**
- Modify: `lib/theme/app_theme.dart`
- Modify: `lib/widgets/` (all widget files)
- Test: `test/theme/typography_test.dart`

**Step 1: Create typography constants**

```dart
// In app_theme.dart
class AppTypography {
  static const double latestReadingSize = 48.0;
  static const double headerSize = 20.0;
  static const double bodySize = 14.0;
  static const double letterSpacing = 0.25; // 4/16 = 0.25

  static const TextStyle latestReading = TextStyle(
    fontSize: latestReadingSize,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryTextColor,
  );

  static const TextStyle header = TextStyle(
    fontSize: headerSize,
    fontWeight: FontWeight.w500,
    color: AppTheme.primaryTextColor,
    letterSpacing: letterSpacing,
  );

  static const TextStyle body = TextStyle(
    fontSize: bodySize,
    color: AppTheme.primaryTextColor,
  );
}
```

**Step 2: Update TextTheme**

```dart
static ThemeData lightTheme = ThemeData(
  textTheme: TextTheme(
    displayLarge: AppTypography.latestReading,
    headlineMedium: AppTypography.header,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.body,
    labelMedium: AppTypography.body,
  ),
);
```

**Step 3: Apply typography consistently**

```dart
// In dashboard_screen.dart
Text('Latest Reading', style: AppTypography.header),
// Remove all-caps usage
Text('systolic/diastolic', style: AppTypography.body),

// In reading_summary_card.dart
Text('${reading.systolic}', style: AppTypography.latestReading.copyWith(
  color: getCategoryColor(reading.category),
)),

// In chart labels
Text('Systolic (mmHg)', style: AppTypography.body),
Text('Diastolic (mmHg)', style: AppTypography.body),
```

**Step 4: Create typography test**

```dart
testWidgets('Typography is consistent across the app', (tester) async {
  await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

  // Check latest reading size
  final latestReadingText = tester.widget<Text>(find.text('122').first);
  expect(latestReadingText.style?.fontSize, equals(48.0));

  // Check header size
  final headerText = tester.widget<Text>(find.text('Latest Reading'));
  expect(headerText.style?.fontSize, equals(20.0));
});
```

**Step 5: Run tests**

Run: `flutter test test/theme/typography_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/theme/app_theme.dart
git commit -m "feat: establish consistent typography system (48/20/14sp)"
```

### Task 5: Fix Historical Chart

**Files:**
- Modify: `lib/widgets/fl_time_series_chart.dart`
- Modify: `lib/screens/dashboard_screen.dart`
- Test: `test/widgets/fl_time_series_chart_test.dart`

**Step 1: Write test for correct chart orientation**

```dart
testWidgets('Historical chart has time on X-axis and values on Y-axis', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: HistoricalChart(readings: testReadings))
  ));

  // Time should be on bottom axis
  expect(find.text('Date'), findsOneWidget);

  // Values should be on left axis
  expect(find.textContaining('mmHg'), findsOneWidget);

  // Should have Y-axis values
  expect(find.byWidgetPredicate((widget) =>
    widget is Text && RegExp(r'\d+').hasMatch(widget.data!)
  ), findsWidgets);
});
```

**Step 2: Update chart configuration**

```dart
// In fl_time_series_chart.dart
LineChart(
  LineChartData(
    // Swap orientation if needed
    lineBarsData: [
      // Systolic line - RED
      LineChartBarData(
        spots: readings.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.systolic.toDouble());
        }).toList(),
        isCurved: true,
        color: Colors.red,
        barWidth: 3,
      ),
      // Diastolic line - BLUE
      LineChartBarData(
        spots: readings.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.diastolic.toDouble());
        }).toList(),
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
      ),
    ],
    // Add average lines
    extraLinesData: ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: averageSystolic,
          color: Colors.red.withOpacity(0.3),
          strokeWidth: 2,
          dashArray: [5, 5],
        ),
        HorizontalLine(
          y: averageDiastolic,
          color: Colors.blue.withOpacity(0.3),
          strokeWidth: 2,
          dashArray: [5, 5],
        ),
      ],
    ),
    // Configure axes
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 3, // Show every 3rd date
        reservedSize: 30,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index >= 0 && index < readings.length) {
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 8,
              child: Text(
                DateFormat('MMM dd').format(readings[index].timestamp),
                style: TextStyle(fontSize: 12),
              ),
            );
          }
          return Text('');
        },
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => Text(
          '${value.toInt()}',
          style: TextStyle(fontSize: 12),
        ),
        reservedSize: 40,
      ),
      axisNameWidget: Text('mmHg', style: TextStyle(fontSize: 14)),
    ),
  ),
)
```

**Step 3: Run test**

Run: `flutter test test/widgets/fl_time_series_chart_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/widgets/fl_time_series_chart.dart
git commit -m "fix: historical chart orientation and styling"
```

---

## PHASE 2: HIGH PRIORITY (Week 2)

### Task 6: Standardize Spacing System

**Files:**
- Modify: `lib/theme/app_theme.dart`
- Modify: All UI files
- Test: `test/theme/spacing_test.dart`

**Step 1: Create spacing constants**

```dart
// In app_theme.dart
class AppSpacing {
  static const double grid = 8.0;
  static const double xs = grid;        // 8dp
  static const double sm = grid * 2;    // 16dp
  static const double md = grid * 3;    // 24dp
  static const double lg = grid * 4;    // 32dp
  static const double xl = grid * 6;    // 48dp

  // Specific spacing
  static const double cardPadding = 20.0;
  static const double sectionSpacing = 24.0;
  static const double cardSpacing = 12.0;
  static const double screenMargin = 16.0;
}
```

**Step 2: Apply spacing throughout the app**

```dart
// Replace all hardcoded spacing with constants
SizedBox(height: AppSpacing.sectionSpacing),
EdgeInsets.all(AppSpacing.cardPadding),
EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
```

**Step 3: Create spacing test**

```dart
test('Spacing follows 8dp grid system', () {
  // Verify all spacing values are multiples of 8
  expect(AppSpacing.cardPadding % 8, equals(0));
  expect(AppSpacing.sectionSpacing % 8, equals(0));
  expect(AppSpacing.screenMargin % 8, equals(0));
});
```

**Step 4: Run and commit**

```bash
git add lib/theme/app_theme.dart lib/screens/ lib/widgets/
git commit -m "feat: implement 8dp spacing grid system"
```

### Task 7: Redesign Recent Readings List

**Files:**
- Modify: `lib/screens/dashboard_screen.dart` (recent readings section)
- Create: `lib/widgets/recent_reading_item.dart`
- Test: `test/widgets/recent_reading_item_test.dart`

**Step 1: Create new reading item widget**

```dart
// In lib/widgets/recent_reading_item.dart
class RecentReadingItem extends StatelessWidget {
  final BloodPressureReading reading;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const RecentReadingItem({
    Key? key,
    required this.reading,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reading.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        height: 72, // Minimum 72dp
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Date/Time (left)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM dd').format(reading.timestamp),
                    style: AppTypography.body,
                  ),
                  Text(
                    DateFormat('HH:mm').format(reading.timestamp),
                    style: AppTypography.body.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Reading (center)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getCategoryColor(reading.category),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${reading.systolic}/${reading.diastolic}',
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Pulse (right)
            Expanded(
              child: Text(
                '${reading.pulse} bpm',
                style: AppTypography.body,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Update dashboard to use new widget**

```dart
// In dashboard_screen.dart
ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: recentReadings.length,
  itemBuilder: (context, index) {
    return RecentReadingItem(
      reading: recentReadings[index],
      onTap: () => _selectReading(recentReadings[index]),
      onDelete: () => _deleteReading(recentReadings[index]),
    );
  },
)
```

**Step 3: Run and commit**

```bash
git add lib/widgets/recent_reading_item.dart lib/screens/dashboard_screen.dart
git commit -m "feat: redesign recent readings list with swipe-to-delete"
```

### Task 8: Fix All Touch Targets

**Files:**
- Modify: `lib/widgets/` (all interactive widgets)
- Modify: `lib/screens/` (all screens)
- Test: `test/widgets/touch_targets_test.dart`

**Step 1: Update FloatingActionButton**

```dart
// In dashboard_screen.dart
FloatingActionButton(
  onPressed: _addNewReading,
  child: Icon(Icons.add),
  mini: false, // Ensure 56dp size
  elevation: 6,
)
```

**Step 2: Update menu buttons**

```dart
// Update all IconButton to use 44dp minimum size
IconButton(
  iconSize: 24,
  padding: EdgeInsets.all(10), // Makes 44x44 total
  icon: Icon(Icons.more_vert),
  onPressed: _showMenu,
)
```

**Step 3: Update segmented control**

```dart
Container(
  height: 44,
  child: Row(
    children: options.map((option) {
      return Expanded(
        child: GestureDetector(
          onTap: () => selectOption(option),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple : Colors.grey[200],
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(option),
          ),
        ),
      );
    }).toList(),
  ),
)
```

**Step 4: Commit**

```bash
git add lib/screens/ lib/widgets/
git commit -m "fix: ensure all touch targets meet 44dp minimum"
```

### Task 9: Improve Icons & Bottom Navigation

**Files:**
- Modify: `lib/app.dart` (bottom navigation)
- Create: `lib/widgets/app_icon.dart` (proper heart icon)
- Test: `test/widgets/bottom_nav_test.dart`

**Step 1: Create proper heart icon**

```dart
// In app_icon.dart
class HeartIcon extends StatelessWidget {
  final double size;
  final Color color;

  const HeartIcon({Key? key, this.size = 24, this.color = Colors.red}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HeartPainter(color: color),
    );
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;

  _HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw heart shape using bezier curves
    final width = size.width;
    final height = size.height;

    path.moveTo(width * 0.5, height * 0.25);
    path.cubicTo(
      width * 0.15, height * -0.05,
      width * -0.05, height * 0.3,
      width * 0.5, height * 0.8,
    );
    path.moveTo(width * 0.5, height * 0.25);
    path.cubicTo(
      width * 0.85, height * -0.05,
      width * 1.05, height * 0.3,
      width * 0.5, height * 0.8,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

**Step 2: Update bottom navigation**

```dart
// In app.dart
BottomNavigationBar(
  currentIndex: currentIndex,
  onTap: onTap,
  type: BottomNavigationBarType.fixed,
  selectedFontSize: 12,
  unselectedFontSize: 12,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home, size: 24),
      activeIcon: Container(
        padding: EdgeInsets.only(top: 3),
        child: Icon(Icons.home, size: 24, color: Colors.purple),
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: HeartIcon(size: 24, color: Colors.grey),
      activeIcon: Container(
        padding: EdgeInsets.only(top: 3),
        child: HeartIcon(size: 24, color: Colors.purple),
      ),
      label: 'Trends',
    ),
  ],
  selectedItemColor: Colors.purple,
  unselectedItemColor: Colors.grey,
)
```

**Step 3: Commit**

```bash
git add lib/app.dart lib/widgets/app_icon.dart
git commit -m "feat: improve bottom navigation with proper icons and labels"
```

### Task 10: Standardize Blood Pressure Notation

**Files:**
- Modify: All files displaying BP values
- Test: `test/utils/bp_format_test.dart`

**Step 1: Create BP format utility**

```dart
// In lib/utils/bp_format.dart
class BloodPressureFormat {
  static String format(int systolic, int diastolic) {
    return '$systolic/$diastolic mmHg';
  }

  static String formatReading(BloodPressureReading reading) {
    return format(reading.systolic, reading.diastolic);
  }
}
```

**Step 2: Apply consistent format**

```dart
// Replace all instances of BP formatting
Text(BloodPressureFormat.format(120, 80))  // "120/80 mmHg"
Text(BloodPressureFormat.formatReading(reading))  // "122/88 mmHg"
```

**Step 3: Commit**

```bash
git add lib/utils/bp_format.dart
find lib/ -name "*.dart" -exec sed -i '' 's/\\([0-9]*\\)\\/\\([0-9]*\\)/BloodPressureFormat.format(\1, \2)/g' {} \;
git commit -m "feat: standardize blood pressure notation with mmHg units"
```

---

## PHASE 3: MEDIUM PRIORITY (Week 3)

### Task 11: Add Card Elevation

**Files:**
- Modify: `lib/widgets/modern_cards.dart`
- Modify: All card implementations
- Test: `test/widgets/card_elevation_test.dart`

**Step 1: Create elevated card widget**

```dart
class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const ElevatedCard({
    Key? key,
    required this.child,
    this.padding,
    this.elevation = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: elevation ?? 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );
  }
}
```

**Step 2: Apply to all cards**

```bash
# Search and replace card implementations
```

### Task 12: Create Empty States

**Files:**
- Create: `lib/widgets/empty_states.dart`
- Modify: `lib/screens/dashboard_screen.dart`
- Test: `test/widgets/empty_states_test.dart`

### Task 13: Add Onboarding Flow

**Files:**
- Create: `lib/screens/onboarding_screen.dart`
- Modify: `lib/main.dart`
- Create: `lib/services/onboarding_service.dart`
- Test: `test/screens/onboarding_test.dart`

### Task 14: Micro-interactions & Feedback

**Files:**
- Create: `lib/widgets/animated_widgets.dart`
- Modify: All interactive elements
- Test: `test/widgets/animations_test.dart`

### Task 15: Consistency Pass

**Files:**
- All theme files
- All widget files
- Create: `lib/theme/color_constants.dart`
- Test: `test/theme/consistency_test.dart`

---

## EXECUTION SUMMARY

**Total Tasks:** 15 main tasks
**Estimated Time:** 3 weeks
**Critical Path:** Tasks 1-5 (Week 1) must be completed first

**Key Metrics:**
- Accessibility: WCAG AA compliance (4.5:1 contrast)
- Medical Accuracy: Correct chart axes orientation
- Usability: 44dp minimum touch targets
- Consistency: Unified spacing, typography, and color system

**Testing Requirements:**
- Unit tests for all utilities and formatting
- Widget tests for UI components
- Integration tests for user flows
- Accessibility tests with semantic labels

**Code Quality:**
- Follow TDD pattern (test first, implement minimal code)
- Commit after each task
- Use descriptive commit messages
- Keep PRs small and focused