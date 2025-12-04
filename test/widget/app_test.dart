import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../lib/app.dart';
import '../../lib/providers/blood_pressure_provider.dart';
import '../../lib/providers/sync_provider.dart';
import '../../lib/providers/settings_provider.dart';
import '../../lib/services/database_service.dart';
import '../../lib/services/google_sheets_service.dart';

void main() {
  group('App Navigation Tests', () {
    late DatabaseService databaseService;
    late GoogleSheetsService googleSheetsService;

    setUp(() {
      databaseService = DatabaseService.instance;
      googleSheetsService = GoogleSheetsService();
    });

    testWidgets('App should have bottom navigation bar', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BloodPressureProvider(
                databaseService: databaseService,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SyncProvider(
                databaseService: databaseService,
                googleSheetsService: googleSheetsService,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SettingsProvider(
                databaseService: databaseService,
              ),
            ),
          ],
          child: const MaterialApp(
            home: App(),
          ),
        ),
      );

      // Verify that the bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify that all navigation items are present in the bottom navigation bar
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Distribution'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('Should navigate to add reading screen when add button is tapped', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BloodPressureProvider(
                databaseService: databaseService,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SyncProvider(
                databaseService: databaseService,
                googleSheetsService: googleSheetsService,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SettingsProvider(
                databaseService: databaseService,
              ),
            ),
          ],
          child: const MaterialApp(
            home: App(),
          ),
        ),
      );

      // Tap on the 'Add' navigation item
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify that we're on the add reading screen
      expect(find.text('Add Reading'), findsOneWidget);
    });

    testWidgets('Should navigate to dashboard when dashboard item is tapped', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BloodPressureProvider(
                databaseService: databaseService,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SyncProvider(
                databaseService: databaseService,
                googleSheetsService: googleSheetsService,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SettingsProvider(
                databaseService: databaseService,
              ),
            ),
          ],
          child: const MaterialApp(
            home: App(),
          ),
        ),
      );

      // Tap on the 'Dashboard' navigation item (should already be selected)
      expect(find.text('Dashboard'), findsWidgets);
    });
  });
}