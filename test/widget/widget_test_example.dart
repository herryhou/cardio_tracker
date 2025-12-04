import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cardio_tracker/main.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('CardioTrackerApp builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const CardioTrackerApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('HomeScreen displays correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const CardioTrackerApp());
      expect(find.text('Cardio Tracker'), findsWidgets);
    });

    testWidgets('HomeScreen displays heart icon', (WidgetTester tester) async {
      await tester.pumpWidget(const CardioTrackerApp());
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('HomeScreen displays subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(const CardioTrackerApp());
      expect(find.text('Track your cardiovascular health metrics'), findsOneWidget);
    });

    testWidgets('HomeScreen displays setup complete message', (WidgetTester tester) async {
      await tester.pumpWidget(const CardioTrackerApp());
      expect(find.text('App setup complete. Ready for feature implementation.'), findsOneWidget);
    });
  });
}