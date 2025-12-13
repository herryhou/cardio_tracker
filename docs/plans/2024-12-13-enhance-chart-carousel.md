# Chart Carousel Enhancement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enhance the existing chart PageView with visual indicators, clear labels, swipe hints, and optional auto-scroll to improve user experience and discoverability.

**Architecture:** Extend the existing HorizontalChartsContainer widget with a PageView indicator, chart titles, swipe hints, and auto-scroll functionality while maintaining the current PageView structure.

**Tech Stack:** Flutter, Provider pattern, Custom animations, PageView controller

---

### Task 1: Add Page Indicator Dots

**Files:**
- Modify: `lib/widgets/horizontal_charts_container.dart`
- Test: `test/widgets/horizontal_charts_container_test.dart` (create if not exists)

**Step 1: Write the failing test**

```dart
testWidgets('should show page indicator dots for two charts', (WidgetTester tester) async {
  // Arrange
  final readings = [
    BloodPressureReading(
      id: '1',
      systolic: 120,
      diastolic: 80,
      pulse: 70,
      timestamp: DateTime.now(),
    ),
  ];

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => BloodPressureProvider(),
        child: ChangeNotifierProvider(
          create: (_) => DualChartProvider(),
          child: Scaffold(
            body: HorizontalChartsContainer(readings: readings),
          ),
        ),
      ),
    ),
  );

  // Assert
  expect(find.byType(SmoothPageIndicator), findsOneWidget);
  expect(find.text('Trends'), findsOneWidget);
  expect(find.text('Distribution'), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/horizontal_charts_container_test.dart`
Expected: FAIL with "SmoothPageIndicator not found"

**Step 3: Add smooth_page_indicator dependency**

Add to `pubspec.yaml`:
```yaml
dependencies:
  smooth_page_indicator: ^1.1.0
```

**Step 4: Run flutter pub get**

Run: `flutter pub get`

**Step 5: Write minimal implementation**

Add to `_HorizontalChartsContainerState`:
```dart
int _currentPage = 0;

@override
Widget build(BuildContext context) {
  // ... existing code ...

  return Column(
    children: [
      // ... time range selector ...

      // Charts
      SizedBox(
        height: 320,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            // First chart with title
            Column(
              children: [
                Text(
                  'Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    // ... existing bar chart ...
                  ),
                ),
              ],
            ),
            // Second chart with title
            Column(
              children: [
                Text(
                  'Distribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    // ... existing scatter plot ...
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Page indicator
      const SizedBox(height: 16),
      SmoothPageIndicator(
        controller: _pageController,
        count: 2,
        effect: const ExpandingDotsEffect(
          activeDotColor: Colors.blue,
          dotColor: Colors.grey,
          dotHeight: 8,
          dotWidth: 8,
          expansionFactor: 3,
        ),
      ),
    ],
  );
}
```

**Step 6: Run test to verify it passes**

Run: `flutter test test/widgets/horizontal_charts_container_test.dart`
Expected: PASS

**Step 7: Commit**

```bash
git add pubspec.yaml lib/widgets/horizontal_charts_container.dart test/widgets/horizontal_charts_container_test.dart
git commit -m "feat: add page indicators and titles to chart carousel"
```

---

### Task 2: Add Swipe Hint Animation

**Files:**
- Create: `lib/widgets/swipe_hint.dart`
- Modify: `lib/widgets/horizontal_charts_container.dart`

**Step 1: Create SwipeHint widget**

```dart
class SwipeHint extends StatefulWidget {
  const SwipeHint({super.key});

  @override
  State<SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<SwipeHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startHintAnimation();
  }

  void _startHintAnimation() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Swipe to see more charts',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Add SwipeHint to HorizontalChartsContainer**

Add above the PageView:
```dart
// Swipe hint (only show on first visit)
if (_showSwipeHint)
  SwipeHint(),
const SizedBox(height: 8),
```

Add state variable:
```dart
bool _showSwipeHint = true;
```

**Step 3: Hide hint after first interaction**

In `onPageChanged`:
```dart
onPageChanged: (index) {
  setState(() {
    _currentPage = index;
    _showSwipeHint = false;
  });
},
```

**Step 4: Add SharedPreferences dependency for persistent hint state**

```yaml
shared_preferences: ^2.2.2
```

**Step 5: Run flutter pub get**

Run: `flutter pub get`

**Step 6: Store hint state**

```dart
void _loadHintState() async {
  final prefs = await SharedPreferences.getInstance();
  final hasSeenHint = prefs.getBool('has_seen_swipe_hint') ?? false;
  if (mounted) {
    setState(() {
      _showSwipeHint = !hasSeenHint;
    });
  }
}

void _saveHintState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('has_seen_swipe_hint', true);
}
```

**Step 7: Commit**

```bash
git add pubspec.yaml lib/widgets/swipe_hint.dart lib/widgets/horizontal_charts_container.dart
git commit -m "feat: add swipe hint animation for chart carousel"
```

---

### Task 3: Add Auto-scroll Toggle

**Files:**
- Modify: `lib/widgets/horizontal_charts_container.dart`
- Create: `lib/widgets/auto_scroll_toggle.dart`

**Step 1: Create AutoScrollToggle widget**

```dart
class AutoScrollToggle extends StatefulWidget {
  const AutoScrollToggle({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  State<AutoScrollToggle> createState() => _AutoScrollToggleState();
}

class _AutoScrollToggleState extends State<AutoScrollToggle> {
  Timer? _autoScrollTimer;

  @override
  void didUpdateWidget(AutoScrollToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !oldWidget.isEnabled) {
      _startAutoScroll();
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _scrollToNextPage(),
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _scrollToNextPage() {
    // This will be implemented in the parent widget
  }

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.autoplay,
            size: 20,
            color: widget.isEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Auto-scroll',
            style: TextStyle(
              color: widget.isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Switch(
            value: widget.isEnabled,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Integrate AutoScrollToggle into HorizontalChartsContainer**

Add state variables:
```dart
bool _autoScrollEnabled = false;
Timer? _autoScrollTimer;
```

Add to build method:
```dart
// Auto-scroll toggle
AutoScrollToggle(
  isEnabled: _autoScrollEnabled,
  onChanged: (value) {
    setState(() {
      _autoScrollEnabled = value;
    });
  },
),
const SizedBox(height: 8),
```

**Step 3: Implement auto-scroll logic**

```dart
void _startAutoScroll() {
  _autoScrollTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % 2;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    },
  );
}

void _stopAutoScroll() {
  _autoScrollTimer?.cancel();
  _autoScrollTimer = null;
}
```

**Step 4: Control timer based on state**

In `didUpdateWidget`:
```dart
if (_autoScrollEnabled && !_oldWidget._autoScrollEnabled) {
  _startAutoScroll();
} else if (!_autoScrollEnabled && _oldWidget._autoScrollEnabled) {
  _stopAutoScroll();
}
```

**Step 5: Commit**

```bash
git add lib/widgets/auto_scroll_toggle.dart lib/widgets/horizontal_charts_container.dart
git commit -m "feat: add auto-scroll toggle for chart carousel"
```

---

### Task 4: Improve Chart Visual Hierarchy

**Files:**
- Modify: `lib/widgets/horizontal_charts_container.dart`

**Step 1: Add chart descriptions**

```dart
const List<Map<String, String>> _chartInfo = [
  {
    'title': 'Trends',
    'description': 'Track your blood pressure over time',
  },
  {
    'title': 'Distribution',
    'description': 'See readings in clinical zones',
  },
];
```

**Step 2: Update chart cards with proper layout**

```dart
Card(
  elevation: 4,
  margin: EdgeInsets.zero,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _chartInfo[index]['title']!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          _chartInfo[index]['description']!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: index == 0
              ? BPRangeBarChart(...)
              : InteractiveScatterPlot(...),
        ),
      ],
    ),
  ),
),
```

**Step 3: Commit**

```bash
git add lib/widgets/horizontal_charts_container.dart
git commit -m "feat: improve chart visual hierarchy with titles and descriptions"
```

---

### Task 5: Add Accessibility Improvements

**Files:**
- Modify: `lib/widgets/horizontal_charts_container.dart`

**Step 1: Add semantic labels**

```dart
Semantics(
  label: 'Chart ${index + 1} of 2: ${_chartInfo[index]['title']}',
  hint: 'Swipe left or right to see other charts',
  child: Card(...),
),
```

**Step 2: Add announcements for page changes**

```dart
onPageChanged: (index) {
  setState(() {
    _currentPage = index;
    _showSwipeHint = false;
  });

  // Announce for screen readers
  SemanticsService.announce(
    'Now showing ${_chartInfo[index]['title']} chart',
    TextDirection.ltr,
  );
},
```

**Step 3: Commit**

```bash
git add lib/widgets/horizontal_charts_container.dart
git commit -m "feat: add accessibility improvements to chart carousel"
```

---

### Task 6: Add Tests for New Features

**Files:**
- Test: `test/widgets/horizontal_charts_container_test.dart`

**Step 1: Test swipe hint disappears**

```dart
testWidgets('should hide swipe hint after swiping', (WidgetTester tester) async {
  // Arrange
  final readings = [/* test data */];

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: HorizontalChartsContainer(readings: readings),
    ),
  );

  // Initially show hint
  expect(find.byType(SwipeHint), findsOneWidget);

  // Swipe to next page
  await tester.fling(
    find.byType(PageView),
    const Offset(-300, 0),
    1000,
  );
  await tester.pumpAndSettle();

  // Hint should be hidden
  expect(find.byType(SwipeHint), findsNothing);
});
```

**Step 2: Test auto-scroll toggle**

```dart
testWidgets('should toggle auto-scroll', (WidgetTester tester) async {
  // Arrange
  final readings = [/* test data */];

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: HorizontalChartsContainer(readings: readings),
    ),
  );

  // Find toggle
  final toggle = find.byType(Switch);
  expect(toggle, findsOneWidget);

  // Tap to enable
  await tester.tap(toggle);
  await tester.pump();

  // Verify auto-scroll started
  // This would need to be tested with timer mocking
});
```

**Step 3: Test page indicator**

```dart
testWidgets('should show correct page indicator', (WidgetTester tester) async {
  // Arrange
  final readings = [/* test data */];

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: HorizontalChartsContainer(readings: readings),
    ),
  );

  // Find page indicator
  expect(find.byType(SmoothPageIndicator), findsOneWidget);

  // Should show 2 dots
  final dots = tester.widgetList<Container>(
    find.descendant(
      of: find.byType(SmoothPageIndicator),
      matching: find.byType(Container),
    ),
  );
  expect(dots.length, 2);
});
```

**Step 4: Run all tests**

Run: `flutter test test/widgets/horizontal_charts_container_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add test/widgets/horizontal_charts_container_test.dart
git commit -m "test: add tests for chart carousel features"
```

---

### Task 7: Update Documentation

**Files:**
- Modify: `README.md` (if exists)
- Create: `docs/chart-carousel-guide.md`

**Step 1: Create usage guide**

```markdown
# Chart Carousel Feature Guide

## Features

1. **Page Indicators**: Dots show current chart position
2. **Chart Titles**: Each chart has a clear title and description
3. **Swipe Hints**: First-time users see an animation hint
4. **Auto-scroll**: Optional automatic rotation between charts
5. **Accessibility**: Full screen reader support

## Usage

- Swipe left/right to navigate between charts
- Tap the auto-scroll toggle to enable automatic rotation
- Charts available: Trends (bar chart) and Distribution (scatter plot)
```

**Step 2: Commit**

```bash
git add docs/chart-carousel-guide.md
git commit -m "docs: add chart carousel feature guide"
```

---

## Testing Strategy

1. **Unit Tests**: Test individual widgets and logic
2. **Widget Tests**: Test user interactions and state changes
3. **Integration Tests**: Test with real data and navigation
4. **Accessibility Tests**: Verify screen reader compatibility

## Deployment Notes

1. Ensure all new dependencies are approved
2. Test on various screen sizes
3. Verify performance with large datasets
4. Test auto-scroll doesn't interfere with user interaction