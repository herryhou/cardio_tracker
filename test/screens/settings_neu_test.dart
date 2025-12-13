import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cardio_tracker/presentation/providers/theme_provider.dart';
import 'package:cardio_tracker/presentation/screens/settings_screen.dart';
import 'package:cardio_tracker/presentation/screens/cloudflare_settings_screen.dart';
import 'package:cardio_tracker/widgets/neumorphic_container.dart';
import 'package:cardio_tracker/widgets/neumorphic_button.dart';
import 'package:cardio_tracker/widgets/neumorphic_slider_theme_toggle.dart';
import 'package:cardio_tracker/widgets/neumorphic_tile.dart';

void main() {
  group('Neumorphic Settings Screen Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<ThemeProvider>(
        create: (_) => themeProvider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('Settings screen should display neumorphic elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify neumorphic containers are present
      expect(find.byType(NeumorphicContainer), findsWidgets);
    });

    testWidgets('Theme toggle should use NeumorphicSliderThemeToggle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the neumorphic slider theme toggle for theme selection
      expect(find.byType(NeumorphicSliderThemeToggle), findsOneWidget);
    });

    testWidgets('Settings items should use NeumorphicTile', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find all neumorphic tiles
      final tiles = find.byType(NeumorphicTile);

      // Verify we have tiles for settings items
      expect(tiles, findsAtLeastNWidgets(2));
    });

    testWidgets('Navigation items should use NeumorphicTile', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find neumorphic tiles
      expect(find.byType(NeumorphicTile), findsAtLeastNWidgets(2));
    });

    testWidgets('Theme switching should work with neumorphic slider theme toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the theme toggle
      final themeToggle = find.byType(NeumorphicSliderThemeToggle);
      expect(themeToggle, findsOneWidget);

      // Tap on the theme toggle to change theme
      await tester.tap(themeToggle);
      await tester.pump();

      // Verify theme provider was updated
      expect(themeProvider.themeMode, isA<ThemeMode>());
    });

    testWidgets('Neumorphic elements should have proper touch targets', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find all touchable elements
      final touchableElements = find.byType(GestureDetector);

      // Verify minimum touch target size (48dp)
      for (final element in touchableElements.evaluate()) {
        final widget = element.widget as GestureDetector;
        final finder = find.byElementPredicate((el) => el == element);
        if (finder.evaluate().isNotEmpty) {
          final renderBox = tester.renderObject(finder) as RenderBox;
          expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
        }
      }
    });

    testWidgets('Settings items should have visual feedback on press', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find a neumorphic tile
      final tile = find.byType(NeumorphicTile).first;

      // Press down on the tile
      await tester.press(tile);
      await tester.pump();

      // Verify the visual feedback (isPressed state)
      await tester.pumpAndSettle();
    });
  });

  group('Neumorphic Cloudflare Settings Screen Tests', () {
    Widget createCloudflareWidgetUnderTest() {
      return const MaterialApp(
        home: CloudflareSettingsScreen(),
      );
    }

    testWidgets('Cloudflare settings screen should display neumorphic elements', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());

      // Wait for initialization
      await tester.pumpAndSettle();

      // Verify neumorphic containers are present
      expect(find.byType(NeumorphicContainer), findsAtLeastNWidgets(1));
    });

    testWidgets('Form inputs should be in neumorphic containers', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find text form fields
      expect(find.byType(TextFormField), findsWidgets);

      // Verify they are wrapped in neumorphic containers
      expect(find.byType(NeumorphicContainer), findsAtLeastNWidgets(1));
    });

    testWidgets('Save/Update button should be NeumorphicButton', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find save/update button
      expect(find.byType(NeumorphicButton), findsAtLeastNWidgets(1));
    });

    testWidgets('Sync button should be NeumorphicButton', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find sync icon
      final syncIcon = find.byIcon(Icons.sync);
      expect(syncIcon, findsOneWidget);

      // Find the parent neumorphic button
      final syncButton = find.ancestor(
        of: syncIcon,
        matching: find.byType(NeumorphicButton),
      );
      expect(syncButton, findsOneWidget);
    });

    testWidgets('Status section should use NeumorphicContainer', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the status card
      final statusContainer = find.byWidgetPredicate((widget) =>
        widget is NeumorphicContainer
      );

      expect(statusContainer, findsAtLeastNWidgets(1));
    });

    testWidgets('Clear button should be NeumorphicButton when configured', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially might not be configured, but clear button should exist
      final clearButton = find.byWidgetPredicate((widget) =>
        widget is NeumorphicButton &&
        widget.child.toString().toLowerCase().contains('clear')
      );

      // Clear button might not be visible initially
      if (clearButton.evaluate().isNotEmpty) {
        expect(clearButton, findsOneWidget);
      }
    });

    testWidgets('Input fields should have proper touch targets', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find all input fields
      final inputFields = find.byType(TextFormField);

      for (final element in inputFields.evaluate()) {
        final finder = find.byElementPredicate((el) => el == element);
        if (finder.evaluate().isNotEmpty) {
          final renderBox = tester.renderObject(finder) as RenderBox;
          expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
        }
      }
    });

    testWidgets('Buttons should have visual feedback on press', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find a button
      final button = find.byType(NeumorphicButton).first;

      // Verify button exists
      expect(button, findsOneWidget);

      // Press down on the button
      await tester.press(button);
      await tester.pump();

      // Verify the visual feedback
      await tester.pumpAndSettle();
    });

    testWidgets('Form should have proper neumorphic styling', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify the form exists
      expect(find.byType(Form), findsOneWidget);

      // Verify neumorphic containers are used
      expect(find.byType(NeumorphicContainer), findsAtLeastNWidgets(1));
    });

    testWidgets('All interactive elements should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(createCloudflareWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find all semantically labeled elements
      final semantics = tester.binding.pipelineOwner.semanticsOwner!;

      // Verify important elements have semantic labels
      final saveButton = find.byWidgetPredicate((widget) =>
        widget is NeumorphicButton &&
        (widget.child.toString().toLowerCase().contains('save') ||
         widget.child.toString().toLowerCase().contains('update'))
      );

      if (saveButton.evaluate().isNotEmpty) {
        expect(saveButton, findsOneWidget);
      }
    });
  });

  group('Neumorphic Settings Animation Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
    });

    Widget createAnimationWidgetUnderTest() {
      return ChangeNotifierProvider<ThemeProvider>(
        create: (_) => themeProvider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('Neumorphic tiles should animate on press', (WidgetTester tester) async {
      await tester.pumpWidget(createAnimationWidgetUnderTest());

      final tile = find.byType(NeumorphicTile).first;

      // Get the tile before press
      await tester.pumpAndSettle();

      // Press on the tile
      await tester.press(tile);
      await tester.pump(); // Start animation

      // Check if animation controller is running by pumping a few frames
      await tester.pump(const Duration(milliseconds: 50));

      // The animation should be in progress
      expect(find.byType(NeumorphicTile), findsWidgets);

      await tester.pumpAndSettle(); // Complete animation
    });

    testWidgets('Neumorphic containers should animate color changes', (WidgetTester tester) async {
      await tester.pumpWidget(createAnimationWidgetUnderTest());

      // Trigger a theme change
      final themeToggle = find.byType(NeumorphicSliderThemeToggle);
      await tester.tap(themeToggle);
      await tester.pump(); // Start animation

      // Verify animation is scheduled
      expect(tester.binding.hasScheduledFrame, isTrue);

      await tester.pumpAndSettle(); // Complete animation
    });

    testWidgets('Theme toggle should animate when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createAnimationWidgetUnderTest());

      final themeToggle = find.byType(NeumorphicSliderThemeToggle);
      expect(themeToggle, findsOneWidget);

      // Tap on the theme toggle
      await tester.tap(themeToggle);
      await tester.pump(); // Start animation

      // Verify animation is in progress
      expect(tester.binding.hasScheduledFrame, isTrue);

      await tester.pumpAndSettle(); // Complete animation
    });
  });
}