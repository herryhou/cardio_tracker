# UI Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the blood pressure tracker UI into a modern, professional medical application following AHA standards and Material Design 3

**Architecture:** Modern Material Design 3 with reusable widget system, medical color palette, responsive layouts, and smooth animations

**Tech Stack:** Flutter 3.x, Material 3, fl_chart animations, Provider state management, custom medical widget library

---

### Task 1: Theme System Foundation

**Files:**
- Create: `lib/theme/app_theme.dart`
- Create: `lib/theme/colors.dart`
- Create: `lib/theme/text_styles.dart`
- Create: `lib/theme/spacings.dart`
- Test: `test/unit/theme_test.dart`

**Step 1: Write the failing test**

```dart
// test/unit/theme_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('should create light theme with medical colors', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, equals(Colors.blue[700]));
      expect(theme.colorScheme.secondary, equals(Colors.teal[500]));
    });

    test('should create dark theme with proper colors', () {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, equals(Colors.blue[200]));
      expect(theme.colorScheme.secondary, equals(Colors.teal[200]));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/unit/theme_test.dart -v`
Expected: FAIL with "AppTheme not defined"

**Step 3: Implement minimal code**

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryTeal,
      surface: AppColors.surfaceWhite,
      background: AppColors.backgroundLight,
      error: AppColors.errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
    ),
    textTheme: TextThemes.lightTextTheme,
    cardTheme: _buildCardTheme(Colors.white, Colors.grey[200]),
    elevatedButtonTheme: _buildButtonTheme(),
    floatingActionButtonTheme: _buildFABTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlueLight,
      secondary: AppColors.secondaryTealLight,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.errorRedLight,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    textTheme: TextThemes.darkTextTheme,
    cardTheme: _buildCardTheme(Colors.grey[800], Colors.grey[600]),
    elevatedButtonTheme: _buildButtonTheme(),
    floatingActionButtonTheme: _buildFABTheme(),
  );

  static CardTheme _buildCardTheme(Color color, Color shadowColor) {
    return CardTheme(
      color: color,
      elevation: 2,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  static ElevatedButtonTheme _buildButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryTeal,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/unit/theme_test.dart -v`
Expected: PASS

**Step 5: Create supporting theme files**

```dart
// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  static const Color secondaryTeal = Color(0xFF00796B);
  static const Color secondaryTealLight = Color(0xFF26A69A);

  // Medical status colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFF9800);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color errorRed = Color(0xFFF44336);
  static const Color errorRedLight = Color(0xFFEF5350);

  // Background colors
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Medical status palette
  static const Color normalBP = Color(0xFF4CAF50);
  static const Color elevatedBP = Color(0xFFFF9800);
  static const Color stage1BP = Color(0xFFFF9800);
  static const Color stage2BP = Color(0xFFF44336);
  static const Color crisisBP = Color(0xFF9C27B0);
}

// lib/theme/text_styles.dart
import 'package:flutter/material.dart';

class TextThemes {
  static const TextStyle largeTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Color(0xFF212121),
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFF212121),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF757575),
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF757575),
  );

  static final TextStyle lightTextTheme = TextTheme(
    displayLarge: largeTitle,
    headlineMedium: headline,
    titleLarge: title,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: label,
  );

  static final TextStyle darkTextTheme = TextTheme(
    displayLarge: largeTitle.copyWith(color: Colors.white),
    headlineMedium: headline.copyWith(color: Colors.white),
    titleLarge: title.copyWith(color: Colors.white),
    bodyLarge: body.copyWith(color: Colors.white),
    bodyMedium: body.copyWith(color: Colors.white),
    bodySmall: caption.copyWith(color: Colors.white),
    labelLarge: label.copyWith(color: Colors.white),
  );
}

// lib/theme/spacings.dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Card specific spacing
  static const double cardPadding = md;
  static const double cardMargin = 4;
  static const double cardSpacing = 12;
  static const double sectionSpacing = lg;
}
```

**Step 6: Commit**

```bash
git add lib/theme/ test/unit/theme_test.dart
git commit -m "feat: create modern theme system with medical colors and Material 3"

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Task 2: Medical Metric Card Widget

**Files:**
- Create: `lib/widgets/medical_metric_card.dart`
- Create: `lib/widgets/reading_summary_card.dart`
- Create: `lib/widgets/trend_indicator.dart`
- Create: `lib/widgets/health_status_badge.dart`
- Test: `test/unit/widgets_test.dart`

**Step 1: Write the failing test**

```dart
// test/unit/widgets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/medical_metric_card.dart';

void main() {
  group('MedicalMetricCard', () {
    testWidgets('should display metric with proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicalMetricCard(
              title: 'Average BP',
              value: '120/80',
              unit: 'mmHg',
              icon: Icons.favorite,
              status: MetricStatus.normal,
            ),
          ),
        ),
      );

      expect(find.text('Average BP'), findsOneWidget);
      expect(find.text('120/80 mmHg'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/unit/widgets_test.dart -v`
Expected: FAIL with "MedicalMetricCard not defined"

**Step 3: Implement MedicalMetricCard widget**

```dart
// lib/widgets/medical_metric_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

enum MetricStatus {
  normal,
  warning,
  critical,
  low,
}

class MedicalMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData? icon;
  final MetricStatus status;
  final VoidCallback? onTap;

  const MedicalMetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    this.icon,
    this.status = MetricStatus.normal,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final backgroundColor = _getBackgroundColor(status);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      unit,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != MetricStatus.normal) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

  Color _getStatusColor(MetricStatus status) {
    switch (status) {
      case MetricStatus.normal:
        return AppColors.successGreen;
      case MetricStatus.warning:
        return AppColors.warningOrange;
      case MetricStatus.critical:
        return AppColors.errorRed;
      case MetricStatus.low:
        return AppColors.primaryBlue;
    }
  }

  Color _getBackgroundColor(MetricStatus status) {
    final color = _getStatusColor(status);
    return color.withOpacity(0.1);
  }

  String _getStatusText(MetricStatus status) {
    switch (status) {
      case MetricStatus.normal:
        return 'Normal';
      case MetricStatus.warning:
        return 'Elevated';
      case MetricStatus.critical:
        return 'High';
      case MetricStatus.low:
        return 'Low';
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/unit/widgets_test.dart -v`
Expected: PASS

**Step 5: Implement other widget components**

```dart
// lib/widgets/reading_summary_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../models/blood_pressure_reading.dart';

class ReadingSummaryCard extends StatelessWidget {
  final BloodPressureReading reading;
  final VoidCallback? onTap;

  const ReadingSummaryCard({
    Key? key,
    required this.reading,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(reading.category);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: categoryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.favorite,
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _formatDateTime(reading.timestamp),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryText(reading.category),
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric('Systolic', '${reading.systolic}', 'mmHg'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildMetric('Diastolic', '${reading.diastolic}', 'mmHg'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildMetric('Heart Rate', '${reading.heartRate}', 'bpm'),
              if (reading.notes != null && reading.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  reading.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ... implementation of helper methods
}

// lib/widgets/trend_indicator.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendIndicator extends StatelessWidget {
  final List<double> data;
  final TrendDirection trend;
  final double? value;

  const TrendIndicator({
    Key? key,
    required this.data,
    this.trend = TrendDirection.stable,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trendColor = _getTrendColor(trend);
    final trendIcon = _getTrendIcon(trend);

    return Row(
      children: [
        Icon(
          trendIcon,
          color: trendColor,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Container(
            height: 40,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: trendColor.withOpacity(0.8),
                    barWidth: 2,
                    belowBarData: BarAreaData(
                      show: true,
                      color: trendColor.withOpacity(0.2),
                    ),
                  ),
                ],
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: data.isEmpty ? 0 : data.reduce((a, b) => a < b ? a : b).toDouble(),
                maxY: data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b).toDouble(),
              ),
            ),
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${value!.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return AppColors.errorRed;
      case TrendDirection.down:
        return AppColors.successGreen;
      case TrendDirection.stable:
        return AppColors.textSecondary;
    }
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }
}

enum TrendDirection { up, down, stable }
```

**Step 6: Commit**

```bash
git add lib/widgets/ test/unit/widgets_test.dart
git commit -m "feat: implement modern medical widget components with Material 3"

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Task 3: Modern Dashboard Screen Redesign

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`
- Test: `test/widget/dashboard_screen_test.dart`

**Step 1: Write the failing test**

```dart
// test/widget/dashboard_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cardio_tracker/screens/dashboard_screen.dart';
import 'package:cardio_tracker/providers/blood_pressure_provider.dart';

void main() {
  group('DashboardScreen Modern UI', () {
    testWidgets('should display modern dashboard layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => BloodPressureProvider(),
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.text('Blood Pressure Tracker'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widget/dashboard_screen_test.dart -v`
Expected: FAIL - existing implementation doesn't match modern design

**Step 3: Implement modern dashboard design**

```dart
// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';
import '../widgets/medical_metric_card.dart';
import '../widgets/reading_summary_card.dart';
import '../widgets/trend_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodPressureProvider>().loadReadings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Blood Pressure Tracker',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Consumer<BloodPressureProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(context, provider.error!);
          }

          if (provider.readings.isEmpty) {
            return _buildEmptyState(context);
          }

          final latestReading = provider.latestReading;
          final recentReadings = provider.recentReadings.take(3).toList();

          return RefreshIndicator(
            onRefresh: () => provider.loadReadings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section - Today's Reading
                  _buildHeroSection(context, latestReading),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick Stats Row
                  _buildQuickStatsRow(context, provider),
                  const SizedBox(height: AppSpacing.lg),

                  // Recent Readings Section
                  _buildRecentReadingsSection(context, recentReadings),
                  const SizedBox(height: AppSpacing.lg),

                  // Weekly Trend Section
                  _buildTrendSection(context, provider),
                  const SizedBox(height: AppSpacing.lg),

                  // Action Section
                  _buildActionSection(context),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add reading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Reading functionality coming soon!')),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, BloodPressureReading? latestReading) {
    if (latestReading == null) {
      return Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No readings yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Add your first blood pressure reading',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categoryColor = _getCategoryColor(latestReading.category);
    final categoryText = _getCategoryText(latestReading.category);

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: categoryColor,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Reading',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDateTime(latestReading.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: categoryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    categoryText,
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLargeMetric('Systolic', latestReading.systolic, 'mmHg'),
                _buildLargeMetric('Diastolic', latestReading.diastolic, 'mmHg'),
                _buildLargeMetric('Heart Rate', latestReading.heartRate, 'bpm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeMetric(String label, int value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(BuildContext context, BloodPressureProvider provider) {
    return Row(
      children: [
        Expanded(
          child: MedicalMetricCard(
            title: 'Avg Systolic',
            value: provider.averageSystolic.round().toString(),
            unit: 'mmHg',
            icon: Icons.trending_up,
            status: _getMetricStatus(provider.averageSystolic),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: MedicalMetricCard(
            title: 'Avg Diastolic',
            value: provider.averageDiastolic.round().toString(),
            unit: 'mmHg',
            icon: Icons.trending_down,
            status: _getMetricStatus(provider.averageDiastolic),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: MedicalMetricCard(
            title: 'Heart Rate',
            value: provider.averageHeartRate.round().toString(),
            unit: 'bpm',
            icon: Icons.monitor_heart,
            status: MetricStatus.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReadingsSection(BuildContext context, List<BloodPressureReading> readings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Readings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to history screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History screen coming soon!')),
                );
              },
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: readings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.cardMargin),
                child: ReadingSummaryCard(reading: readings[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSection(BuildContext context, BloodPressureProvider provider) {
    final weekTrend = provider.getReadingsForDateRange(
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
    );

    if (weekTrend.isEmpty) {
      return const SizedBox.shrink(); // Skip if no data
    }

    final avgTrend = weekTrend.map((r) => r.systolic).reduce((a, b) => a + b) / weekTrend.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TrendIndicator(
              data: weekTrend.map((r) => r.systolic.toDouble()).toList(),
              trend: _calculateTrend(avgTrend),
              value: _calculateTrendPercentage(avgTrend),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to add reading
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 32,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Add Reading',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to export/import
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Export Data',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No readings yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start tracking your blood pressure to see your health data',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to add reading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Reading functionality coming soon!')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add First Reading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BloodPressureProvider>().loadReadings();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.normal:
        return AppColors.normalBP;
      case BloodPressureCategory.elevated:
        return AppColors.elevatedBP;
      case BloodPressureCategory.stage1:
        return AppColors.stage1BP;
      case BloodPressureCategory.stage2:
        return AppColors.stage2BP;
      case BloodPressureCategory.crisis:
        return AppColors.crisisBP;
      case BloodPressureCategory.low:
        return AppColors.primaryBlue;
    }
  }

  String _getCategoryText(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
      case BloodPressureCategory.low:
        return 'Low';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  MetricStatus _getMetricStatus(double value) {
    if (value > 140) return MetricStatus.critical;
    if (value > 130) return MetricStatus.warning;
    if (value < 90) return MetricStatus.low;
    return MetricStatus.normal;
  }

  TrendDirection _calculateTrend(double avgValue) {
    if (avgValue > 130) return TrendDirection.up;
    if (avgValue < 110) return TrendDirection.down;
    return TrendDirection.stable;
  }

  double? _calculateTrendPercentage(double avgValue) {
    final normalValue = 120.0;
    return ((avgValue - normalValue) / normalValue * 100);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widget/dashboard_screen_test.dart -v`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/screens/dashboard_screen.dart test/widget/dashboard_screen_test.dart
git commit -m "feat: redesign dashboard with modern Material 3 UI"

🤖 Generated with [Content Preview](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Execution Handoff

**Plan complete and saved to `docs/plans/2025-12-05-ui-modernization-plan.md`.**

**Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**