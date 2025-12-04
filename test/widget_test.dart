// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cardio_tracker/main.dart';

void main() {
  testWidgets('Cardio Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CardioTrackerApp());

    // Verify that the app title appears.
    expect(find.text('Cardio Tracker'), findsWidgets);

    // Verify that the subtitle appears.
    expect(find.text('Track your cardiovascular health metrics'), findsOneWidget);

    // Verify that the heart icon appears.
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Verify that the setup complete message appears.
    expect(find.text('App setup complete. Ready for feature implementation.'), findsOneWidget);
  });
}
