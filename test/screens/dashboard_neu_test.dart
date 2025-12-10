import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/widgets/reading_card_neu.dart';
import 'package:cardio_tracker/widgets/animated_heart_icon.dart';
import 'package:cardio_tracker/widgets/neumorphic_container.dart';
import 'package:cardio_tracker/widgets/app_icon.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';
import 'package:cardio_tracker/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:cardio_tracker/providers/blood_pressure_provider.dart';
import 'package:cardio_tracker/services/database_service.dart';

void main() {
  group('Neumorphic Dashboard Components Tests', () {
    testWidgets('ReadingCardNeu displays BP values correctly', (WidgetTester tester) async {
      final testReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingCardNeu(
              reading: testReading,
            ),
          ),
        ),
      );

      // Verify the reading values are displayed
      expect(find.text('120'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('ReadingCardNeu has neumorphic styling', (WidgetTester tester) async {
      final testReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingCardNeu(
              reading: testReading,
            ),
          ),
        ),
      );

      // Verify the neumorphic container is present
      expect(find.byType(NeumorphicContainer), findsOneWidget);

      // Verify pill-shaped container
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(ReadingCardNeu),
        matching: find.byType(Container),
      ).first);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, const BorderRadius.all(Radius.circular(30)));
    });

    testWidgets('AnimatedHeartIcon renders and animates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedHeartIcon(
              size: 48,
              color: Colors.red,
            ),
          ),
        ),
      );

      // Verify the heart icon is present
      expect(find.byType(AnimatedHeartIcon), findsOneWidget);
      expect(find.byType(HeartIcon), findsOneWidget);

      // Verify animation controller is initialized
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });

    testWidgets('AnimatedHeartIcon pulse animation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedHeartIcon(
              size: 48,
              color: Colors.red,
              animate: true,
            ),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // After animation should have scale transform
      await tester.pump(const Duration(milliseconds: 500));

      final transform = tester.widget<Transform>(find.descendant(
        of: find.byType(AnimatedHeartIcon),
        matching: find.byType(Transform),
      ).first);

      expect(transform.transform.getRow(0).x, lessThanOrEqualTo(1.0));
    });

    testWidgets('DashboardScreen renders minimalist layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => BloodPressureProvider(databaseService: MockDatabaseService()),
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Wait for provider to load
      await tester.pumpAndSettle();

      // Verify key components are present
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('DashboardScreen shows centered reading card when data exists', (WidgetTester tester) async {
      final provider = BloodPressureProvider(databaseService: MockDatabaseService());

      // Add test reading
      final testReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      provider.addReading(testReading);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the centered reading card is displayed
      expect(find.byType(ReadingCardNeu), findsOneWidget);
      expect(find.text('120'), findsAtLeastNWidgets(1));
      expect(find.text('80'), findsAtLeastNWidgets(1));
    });

    testWidgets('DashboardScreen shows empty state when no readings', (WidgetTester tester) async {
      final provider = BloodPressureProvider(databaseService: MockDatabaseService());

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No readings yet'), findsOneWidget);
    });

    testWidgets('Minimalist layout has proper spacing', (WidgetTester tester) async {
      final provider = BloodPressureProvider(databaseService: MockDatabaseService());

      // Add test reading
      final testReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      provider.addReading(testReading);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify there's ample white space (check for SizedBox widgets)
      expect(find.byType(SizedBox), findsWidgets);

      // Check for padding around the reading card
      final padding = tester.widget<Padding>(find.descendant(
        of: find.byType(ReadingCardNeu),
        matching: find.byType(Padding),
      ).first);

      expect(padding.padding, const EdgeInsets.all(32.0));
    });
  });

  group('Neumorphic Component Interaction Tests', () {
    testWidgets('ReadingCardNeu handles tap gestures', (WidgetTester tester) async {
      bool wasTapped = false;

      final testReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingCardNeu(
              reading: testReading,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ReadingCardNeu));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('AnimatedHeartIcon can be controlled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimatedHeartIcon(
                      key: Key('heart1'),
                      size: 48,
                      color: Colors.red,
                      animate: true,
                    ),
                    AnimatedHeartIcon(
                      key: Key('heart2'),
                      size: 48,
                      color: Colors.red,
                      animate: false,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Only the first heart should be animating
      await tester.pump(const Duration(milliseconds: 500));

      final animatedHeart = tester.widget<Transform>(find.descendant(
        of: find.byKey(Key('heart1')),
        matching: find.byType(Transform),
      ).first);

      final staticHeart = tester.widget<Transform>(find.descendant(
        of: find.byKey(Key('heart2')),
        matching: find.byType(Transform),
      ).first);

      // Animated heart should have different scale
      expect(animatedHeart.transform.getRow(0).x, isNot(equals(staticHeart.transform.getRow(0).x)));
    });
  });

  group('Accessibility Tests', () {
    testWidgets('ReadingCardNeu has semantic labels', (WidgetTester tester) async {
      final testReading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingCardNeu(
              reading: testReading,
            ),
          ),
        ),
      );

      // Check for semantic labels
      expect(find.bySemanticsLabel('Blood pressure reading'), findsOneWidget);
    });

    testWidgets('Heart icon has accessibility properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedHeartIcon(
              size: 48,
              color: Colors.red,
            ),
          ),
        ),
      );

      // Verify semantic properties
      expect(find.bySemanticsLabel('Heart rate indicator'), findsOneWidget);
    });
  });
}

// Mock database service for testing
class MockDatabaseService implements DatabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value(null);
}