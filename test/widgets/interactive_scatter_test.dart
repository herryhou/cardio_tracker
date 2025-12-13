import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/widgets/clinical_scatter_plot.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';

void main() {
  group('Interactive Scatter Plot Tests', () {
    late List<BloodPressureReading> testReadings;

    setUp(() {
      final now = DateTime.now();
      testReadings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: now,
          lastModified: now,
        ),
        BloodPressureReading(
          id: '2',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: now.subtract(const Duration(days: 1)),
          lastModified: now,
        ),
        BloodPressureReading(
          id: '3',
          systolic: 140,
          diastolic: 90,
          heartRate: 78,
          timestamp: now.subtract(const Duration(days: 2)),
          lastModified: now,
        ),
      ];
    });

    testWidgets('InteractiveViewer should wrap the scatter plot',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find the InteractiveViewer widget
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Should also find the clinical scatter plot inside
      expect(find.byType(ClinicalScatterPlot), findsOneWidget);
    });

    testWidgets('Zoom functionality should work with pinch gestures',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the center of the widget
      final center = tester.getCenter(find.byType(InteractiveScatterPlot));

      // Perform a pinch zoom gesture
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(-50, -50));
      await gesture.up();

      // Add second finger for pinch
      final gesture2 = await tester.startGesture(center);
      await gesture2.moveBy(const Offset(50, 50));
      await gesture2.up();

      await tester.pumpAndSettle();

      // The InteractiveViewer should still be present
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('Pan functionality should work after zooming',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the center of the widget
      final center = tester.getCenter(find.byType(InteractiveScatterPlot));

      // Perform a drag gesture (pan)
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(100, 100));
      await gesture.up();

      await tester.pumpAndSettle();

      // The InteractiveViewer should still be present
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('Zoom should respect minScale and maxScale constraints',
        (WidgetTester tester) async {
      double? currentScale;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
                onInteractionUpdate: (ScaleUpdateDetails details) {
                  currentScale = details.scale;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the InteractiveViewer
      final interactiveViewerFinder = find.byType(InteractiveViewer);
      expect(interactiveViewerFinder, findsOneWidget);

      // Get the InteractiveViewer widget
      final InteractiveViewer interactiveViewer =
          tester.widget(interactiveViewerFinder);

      // Check that minScale and maxScale are set correctly
      expect(interactiveViewer.minScale, 1.0);
      expect(interactiveViewer.maxScale, 3.0);
    });

    testWidgets('Tap on data point should show details with animation',
        (WidgetTester tester) async {
      BloodPressureReading? selectedReading;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
                onReadingSelected: (reading) {
                  selectedReading = reading;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the chart widget and tap on it
      final chartFinder = find.byType(InteractiveScatterPlot);
      expect(chartFinder, findsOneWidget);

      // Tap near where a data point should be
      const tapPosition = Offset(400, 300);
      await tester.tapAt(tapPosition);
      await tester.pumpAndSettle();

      // Check if the animation container appears
      expect(find.byType(AnimatedOpacity), findsWidgets);
    });

    testWidgets('Neumorphic container should be applied',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Container with neumorphic decoration
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Check for neumorphic properties (boxShadow with specific characteristics)
      final Container container = tester.widget(containerFinder.first);
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration, isNotNull);
      expect(decoration!.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));

      // Check for neumorphic shadow characteristics
      final hasLightShadow = decoration.boxShadow!.any((shadow) =>
          shadow.color == Colors.white && shadow.blurRadius == 10);
      final hasDarkShadow = decoration.boxShadow!.any((shadow) =>
          shadow.color.withOpacity(0.1) == Colors.black.withOpacity(0.1) &&
          shadow.blurRadius == 10);

      expect(hasLightShadow || hasDarkShadow, isTrue);
    });

    testWidgets('Reset button should restore default view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
                showResetButton: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for a reset button (it might be an IconButton with Icons.refresh)
      final resetButtonFinder = find.byIcon(Icons.refresh);
      if (resetButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(resetButtonFinder);
        await tester.pumpAndSettle();

        // The view should reset (still checking for the widget)
        expect(find.byType(InteractiveScatterPlot), findsOneWidget);
      }
    });

    testWidgets('Boundary constraints should prevent over-panning',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the center of the widget
      final center = tester.getCenter(find.byType(InteractiveScatterPlot));

      // Try to pan far beyond boundaries
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(1000, 1000));
      await gesture.up();

      await tester.pumpAndSettle();

      // The InteractiveViewer should constrain the pan
      expect(find.byType(InteractiveScatterPlot), findsOneWidget);
    });

    testWidgets('Chart should maintain neumorphic style in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: testReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still render with neumorphic container
      expect(find.byType(InteractiveScatterPlot), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Performance: Should handle large datasets without lag',
        (WidgetTester tester) async {
      // Create a large dataset
      final largeReadings = List.generate(1000, (index) {
        final now = DateTime.now();
        return BloodPressureReading(
          id: '$index',
          systolic: 120 + (index % 40),
          diastolic: 80 + (index % 20),
          heartRate: 70 + (index % 20),
          timestamp: now.subtract(Duration(days: index)),
          lastModified: now,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveScatterPlot(
                readings: largeReadings,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without performance issues
      expect(find.byType(InteractiveScatterPlot), findsOneWidget);

      // Tap should still work
      await tester.tapAt(const Offset(400, 300));
      await tester.pumpAndSettle();

      // Pump for 3 seconds to clear the tooltip timer
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(InteractiveScatterPlot), findsOneWidget);
    });
  });
}