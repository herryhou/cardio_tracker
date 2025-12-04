import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cardio_tracker/main.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('App startup and navigation test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CardioTrackerApp());

      // Verify that the app starts correctly
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify the main content is displayed
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Cardio Tracker'), findsWidgets);
      expect(find.text('Track your cardiovascular health metrics'), findsOneWidget);

      // Verify the setup complete message is shown
      expect(find.text('App setup complete. Ready for feature implementation.'), findsOneWidget);
    });

    testWidgets('App theme test', (WidgetTester tester) async {
      await tester.pumpWidget(const CardioTrackerApp());

      // Get the MaterialApp theme
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme!.useMaterial3, isTrue);
      expect(app.theme!.colorScheme.brightness, Brightness.light);
    });

    testWidgets('Widget hierarchy test', (WidgetTester tester) async {
      await tester.pumpWidget(const CardioTrackerApp());

      // Verify the widget hierarchy
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Padding), findsWidgets); // Multiple Padding widgets exist
      expect(find.byType(Center), findsWidgets); // Multiple Center widgets exist
    });
  });
}