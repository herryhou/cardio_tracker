# Cardio Tracker 2025 UI/UX Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign the Cardio Tracker app to align with 2025 UI/UX trends, implementing Material Design 3, neumorphism, enhanced accessibility, and modern interaction patterns.

**Architecture:** Incremental redesign of existing components with neumorphic styling, gesture-based navigation, and improved accessibility while maintaining existing functionality.

**Tech Stack:** Flutter with Material Design 3, neumorphic design patterns, gesture detection, accessibility features

---

## PHASE 1: FOUNDATION SETUP

### Task 1: Material Design 3 Migration

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/theme/app_theme.dart`
- Test: `test/theme/material3_test.dart`

**Step 1: Enable Material Design 3**

```dart
// In main.dart
MaterialApp(
  themeMode: ThemeMode.system,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  useMaterial3: true, // Enable MD3
  // ...
)

// In app_theme.dart
static ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppTheme.deepPurple,
    brightness: Brightness.light,
  ),
  typography: Typography.material2021(), // MD3 typography
  // ...
)
```

**Step 2: Update Color Scheme**
- Primary: #6A1B9A (deep purple)
- Secondary: #FF5252 (soft red)
- Tertiary: #4CAF50 (green for normal readings)
- Surface: #FFFFFF / #121212
- On-surface colors with 7:1 contrast

### Task 2: Create Neumorphic Components

**Files:**
- Create: `lib/widgets/neumorphic_container.dart`
- Create: `lib/widgets/neumorphic_button.dart`
- Create: `lib/widgets/neumorphic_slider.dart`
- Test: `test/widgets/neumorphic_test.dart`

**Step 1: Neumorphic Container**

```dart
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isPressed;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius = 12.0,
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius!),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black12,
                  offset: Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: isDark ? Colors.grey[800]! : Colors.white,
                  offset: Offset(-2, -2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: isDark ? Colors.black38 : Colors.black15,
                  offset: Offset(4, 4),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: isDark ? Colors.grey[700]! : Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                ),
              ],
      ),
      child: child,
    );
  }
}
```

**Step 2: Neumorphic Slider for Theme Toggle**

```dart
class NeumorphicSlider extends StatefulWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  _NeumorphicSliderState createState() => _NeumorphicSliderState();
}

class _NeumorphicSliderState extends State<NeumorphicSlider> {
  final List<ThemeMode> _modes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: EdgeInsets.all(4),
      child: Row(
        children: _modes.map((mode) {
          final isSelected = widget.value == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onChanged(mode),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getModeIcon(mode),
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

---

## PHASE 2: DASHBOARD REDESIGN

### Task 3: Minimalist Dashboard Layout

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`
- Create: `lib/widgets/reading_card_neu.dart`
- Test: `test/screens/dashboard_neu_test.dart`

**Step 1: Centered Reading Display**

```dart
class CenteredReadingCard extends StatelessWidget {
  final BloodPressureReading reading;

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Systolic/Diastolic as single pill
          NeumorphicContainer(
            isPressed: true,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reading.systolic.toString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.getCategoryColor(reading.category),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '/',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  reading.diastolic.toString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.getCategoryColor(reading.category),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'mmHg',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Pulse with animated heart
          NeumorphicContainer(
            borderRadius: 50,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedHeartIcon(),
                SizedBox(width: 8),
                Text(
                  '${reading.pulse} bpm',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Task 4: Gesture-Based Navigation

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`
- Create: `lib/widgets/swipe_detector.dart`
- Test: `test/widgets/gesture_test.dart`

**Step 1: Add Swipe Navigation**

```dart
GestureDetector(
  onHorizontalDragEnd: (details) {
    if (details.primaryVelocity! > 0) {
      // Swipe right - stay on dashboard
    } else {
      // Swipe left - navigate to trends
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DistributionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: Offset(1.0, 0.0), end: Offset.zero),
              ),
              child: child,
            );
          },
        ),
      );
    }
  },
  child: DashboardContent(),
)
```

---

## PHASE 3: TRENDS SCREEN ENHANCEMENT

### Task 5: Interactive Scatter Plot with Zoom

**Files:**
- Modify: `lib/widgets/clinical_scatter_plot.dart`
- Add: `lib/widgets/interactive_viewer_wrapper.dart`
- Test: `test/widgets/interactive_chart_test.dart`

**Step 1: Add Zoom and Pan**

```dart
InteractiveViewer(
  minScale: 1.0,
  maxScale: 3.0,
  boundaryMargin: EdgeInsets.all(20),
  child: ScatterPlotWidget(
    readings: readings,
    onReadingSelected: (reading) {
      // Show reading details with animation
      _showReadingDetails(reading);
    },
  ),
)
```

### Task 6: Timeline Carousel

**Files:**
- Create: `lib/widgets/timeline_carousel.dart`
- Modify: `lib/screens/distribution_screen.dart`
- Test: `test/widgets/timeline_test.dart`

```dart
class TimelineCarousel extends StatelessWidget {
  final List<TimeSeriesData> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return NeumorphicContainer(
            margin: EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.all(12),
            width: 100,
            child: Column(
              children: [
                Text(
                  DateFormat('MM/dd').format(item.timestamp),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                SizedBox(height: 4),
                Container(
                  height: 40,
                  width: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor(item.category),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## PHASE 4: SETTINGS AND INTERACTIONS

### Task 7: Neumorphic Settings Screen

**Files:**
- Modify: `lib/screens/settings_screen.dart`
- Update: Use NeumorphicSlider for theme toggle
- Test: `test/screens/settings_neu_test.dart`

**Step 1: Redesign Settings Items**

```dart
ListTile(
  leading: NeumorphicContainer(
    borderRadius: 20,
    child: Icon(Icons.cloud_sync),
  ),
  title: Text('Cloudflare Sync'),
  trailing: NeumorphicContainer(
    borderRadius: 20,
    child: Icon(Icons.chevron_right),
  ),
  onTap: () {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => CloudflareSettingsScreen(),
      ),
    );
  },
)
```

### Task 8: Enhanced Export Menu

**Files:**
- Create: `lib/widgets/export_bottom_sheet.dart`
- Modify: `lib/screens/dashboard_screen.dart`
- Test: `test/widgets/export_test.dart`

```dart
void _showExportOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => NeumorphicContainer(
      margin: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.download),
            title: Text('Export All Data'),
            onTap: () => _exportData('all'),
          ),
          ListTile(
            leading: Icon(Icons.summarize),
            title: Text('Export Summary'),
            onTap: () => _exportData('summary'),
          ),
          ListTile(
            leading: Icon(Icons.date_range),
            title: Text('Export This Month'),
            onTap: () => _exportData('month'),
          ),
        ],
      ),
    ),
  );
}
```

---

## PHASE 5: ACCESSIBILITY AND MICRO-INTERACTIONS

### Task 9: WCAG 2.2 Compliance

**Files:**
- Update all screens with Semantics widgets
- Add haptic feedback
- Ensure 7:1 contrast for key text
- Test: `test/accessibility/wcag_compliance_test.dart`

**Step 1: Add Screen Reader Support**

```dart
Semantics(
  label: 'Systolic ${reading.systolic}, Diastolic ${reading.diastolic} millimeters of mercury',
  child: ReadingDisplay(reading: reading),
)
```

### Task 10: Micro-Interactions

**Files:**
- Add loading animations
- Create transition animations
- Add ripple effects
- Test: `test/animations/micro_interactions_test.dart`

**Step 1: Animated Loading States**

```dart
class SyncButton extends StatefulWidget {
  @override
  _SyncButtonState createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: _syncData,
      child: isSyncing
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 2 * math.pi,
                  child: Icon(Icons.sync),
                );
              },
            )
          : Text('Sync Now'),
    );
  }
}
```

---

## TESTING STRATEGY

### 1. **Accessibility Testing**
- Use Android TalkBack and iOS VoiceOver
- Verify all interactive elements are focusable
- Check contrast ratios with accessibility scanner

### 2. **Gesture Testing**
- Test all swipe gestures on different screen sizes
- Verify haptic feedback works
- Ensure no gesture conflicts

### 3. **Visual Testing**
- Test light/dark modes
- Verify neumorphic shadows in different lighting
- Check animations at 60fps

### 4. **Performance Testing**
- Profile memory usage with animations
- Check scrolling performance
- Verify smooth transitions

---

## DEPLOYMENT CHECKLIST

1. All neumorphic components are properly themed
2. Gestures work on both Android and iOS
3. Accessibility tests pass
4. Dark mode works seamlessly
5. Performance is optimized
6. All tests pass (>90% coverage)

---

## SUCCESS METRICS

- User satisfaction score > 4.5/5
- Accessibility compliance 100%
- App load time < 2 seconds
- Gesture response time < 100ms
- Animation frame rate > 55fps