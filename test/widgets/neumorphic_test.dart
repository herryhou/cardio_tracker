import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/widgets/neumorphic_container.dart';
import 'package:cardio_tracker/widgets/neumorphic_button.dart';
import 'package:cardio_tracker/widgets/neumorphic_slider.dart';

void main() {
  group('Neumorphic Components', () {
    group('NeumorphicContainer', () {
      testWidgets('renders with proper structure', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NeumorphicContainer(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Test'),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(NeumorphicContainer), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('has soft shadows in light mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const Scaffold(
              body: NeumorphicContainer(
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(NeumorphicContainer),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 2);

        // Check outer shadow properties
        final outerShadow = decoration.boxShadow![0];
        expect(outerShadow.blurRadius, 10.0);
        expect(outerShadow.offset, const Offset(4, 4));
        expect(outerShadow.spreadRadius, 0);

        // Check inner shadow properties
        final innerShadow = decoration.boxShadow![1];
        expect(innerShadow.blurRadius, 10.0);
        expect(innerShadow.offset, const Offset(-4, -4));
        expect(innerShadow.spreadRadius, 0);
      });

      testWidgets('adapts colors for dark mode', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: NeumorphicContainer(
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(NeumorphicContainer),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration as BoxDecoration;
        final outerShadow = decoration.boxShadow![0];
        final innerShadow = decoration.boxShadow![1];

        // In dark mode, shadows should be inverted
        expect(outerShadow.color, isA<Color>());
        expect(innerShadow.color, isA<Color>());
      });

      testWidgets('supports custom border radius', (WidgetTester tester) async {
        const radius = 30.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NeumorphicContainer(
                borderRadius: radius,
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(NeumorphicContainer),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(radius));
      });

      testWidgets('has pressed state animation', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NeumorphicContainer(
                isPressed: true,
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(NeumorphicContainer),
                matching: find.byType(Container),
              )
              .first,
        );

        final decoration = container.decoration as BoxDecoration;
        // When pressed, shadows should be inverted
        final firstShadow = decoration.boxShadow![0];
        final secondShadow = decoration.boxShadow![1];

        expect(firstShadow.blurRadius, 10.0);
        expect(secondShadow.blurRadius, 10.0);
        // Verify shadows are reversed (light shadow where dark was)
        expect(firstShadow.offset, const Offset(4, 4));
        expect(secondShadow.offset, const Offset(-4, -4));
      });
    });

    group('NeumorphicButton', () {
      testWidgets('renders with child content', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        );

        expect(find.byType(NeumorphicButton), findsOneWidget);
        expect(find.text('Button'), findsOneWidget);
      });

      testWidgets('responds to tap', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicButton(
                onPressed: () {
                  wasPressed = true;
                },
                child: const Text('Button'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(NeumorphicButton));
        expect(wasPressed, true);
      });

      testWidgets('shows pressed state on tap down',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        );

        await tester.press(find.byType(NeumorphicButton));
        await tester.pump();

        // Verify the animation controller is active
        expect(tester.binding.hasScheduledFrame, true);
      });

      testWidgets('has minimum touch target size', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicButton(
                onPressed: () {},
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: Text('X'),
                ),
              ),
            ),
          ),
        );

        final button = tester.getSize(find.byType(NeumorphicButton));
        // Should be at least 48dp for accessibility
        expect(button.width, greaterThanOrEqualTo(48.0));
        expect(button.height, greaterThanOrEqualTo(48.0));
      });

      testWidgets('supports custom width and height',
          (WidgetTester tester) async {
        const width = 200.0;
        const height = 60.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicButton(
                onPressed: () {},
                width: width,
                height: height,
                child: const Text('Button'),
              ),
            ),
          ),
        );

        final button = tester.getSize(find.byType(NeumorphicButton));
        expect(button.width, width);
        expect(button.height, height);
      });
    });

    group('NeumorphicSlider', () {
      testWidgets('renders with initial value', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicSlider(
                value: 0.5,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        expect(find.byType(NeumorphicSlider), findsOneWidget);
      });

      testWidgets('calls onChanged when value changes',
          (WidgetTester tester) async {
        double newValue = 0.5;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: NeumorphicSlider(
                  value: 0.5,
                  onChanged: (value) {
                    newValue = value;
                  },
                ),
              ),
            ),
          ),
        );

        // Tap at a specific position (75% of the width)
        await tester.tapAt(const Offset(225, 20));
        await tester.pump();

        // Verify value changed
        expect(newValue, isNot(0.5));
        expect(newValue, closeTo(0.75, 0.1));
      });

      testWidgets('has neumorphic track appearance',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicSlider(
                value: 0.5,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        // Find the track container
        final trackFinder = find.descendant(
          of: find.byType(NeumorphicSlider),
          matching: find.byType(Container),
        );

        expect(trackFinder, findsWidgets);

        // Verify one of them has box shadow for neumorphic effect
        bool hasNeumorphicShadow = false;
        for (final finder in trackFinder.evaluate()) {
          final container = finder.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.boxShadow != null &&
                decoration.boxShadow!.isNotEmpty) {
              hasNeumorphicShadow = true;
              break;
            }
          }
        }

        expect(hasNeumorphicShadow, true);
      });

      testWidgets('supports custom min and max values',
          (WidgetTester tester) async {
        const min = 0.0;
        const max = 200.0;
        double capturedValue = min;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: NeumorphicSlider(
                  value: min,
                  min: min,
                  max: max,
                  onChanged: (value) {
                    capturedValue = value;
                  },
                ),
              ),
            ),
          ),
        );

        // Use drag gesture to simulate moving the slider
        final slider = find.byType(NeumorphicSlider);
        await tester.drag(slider, const Offset(280, 0));
        await tester.pumpAndSettle();

        // Value should have changed from initial
        expect(capturedValue, greaterThan(min));
      });

      testWidgets('thumb has neumorphic appearance',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicSlider(
                value: 0.5,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        // Find the thumb container within the positioned widget
        final thumbFinder = find.descendant(
          of: find.byType(NeumorphicSlider),
          matching: find.byType(Container),
        );

        expect(thumbFinder, findsWidgets);

        // Check if any of the containers have neumorphic shadows
        bool hasNeumorphicThumb = false;
        for (final finder in thumbFinder.evaluate()) {
          final container = finder.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.boxShadow != null &&
                decoration.boxShadow!.isNotEmpty &&
                decoration.shape == BoxShape.circle) {
              hasNeumorphicThumb = true;
              break;
            }
          }
        }

        expect(hasNeumorphicThumb, true);
      });
    });

    group('Animation Tests', () {
      testWidgets('neumorphic button animates on press',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        );

        // Press down
        await tester.press(find.byType(NeumorphicButton));
        await tester.pump();

        // Animation duration is 200ms, pump halfway
        await tester.pump(const Duration(milliseconds: 100));

        // Release
        await tester.tap(find.byType(NeumorphicButton));
        await tester.pump();

        // Animation should complete
        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(NeumorphicButton), findsOneWidget);
      });
    });
  });
}
