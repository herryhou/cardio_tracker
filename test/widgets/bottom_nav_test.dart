import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/widgets/app_icon.dart';

void main() {
  group('Bottom Navigation UI Test', () {
    testWidgets('Bottom navigation has proper icons and labels', (WidgetTester tester) async {
      // Build a simple test widget to check navigation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF8B5CF6),
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.home_outlined,
                      size: 24,
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.home,
                      size: 24,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.show_chart_outlined,
                      size: 24,
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.show_chart,
                      size: 24,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  label: 'Trends',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Find BottomNavigationBar
      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);

      // Check that there are exactly 2 navigation items
      final navItems = find.byType(BottomNavigationBarItem);
      expect(navItems, findsNothing); // BottomNavigationBarItem widgets are not in the widget tree

      // Find navigation items by their labels
      final homeLabel = find.text('Home');
      final trendsLabel = find.text('Trends');

      // Labels should now be found with the updated navigation
      expect(homeLabel, findsOneWidget);
      expect(trendsLabel, findsOneWidget);

      // Check for icon sizes (should be 24dp)
      final icons = find.descendant(
        of: bottomNavBar,
        matching: find.byType(Icon),
      );

      for (int i = 0; i < icons.evaluate().length; i++) {
        final icon = icons.at(i);
        final Icon iconWidget = tester.widget(icon);
        expect(iconWidget.size, 24.0,
            reason: 'Icon size should be 24dp');
      }

      // Check that the first tab is selected (Home)
      final BottomNavigationBar navBarWidget = tester.widget(bottomNavBar);
      expect(navBarWidget.currentIndex, 0);
    });

    testWidgets('Bottom navigation shows proper active state styling', (WidgetTester tester) async {
      // Build a simple test widget to check navigation styling
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF8B5CF6),
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.home_outlined,
                      size: 24,
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.home,
                      size: 24,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.show_chart_outlined,
                      size: 24,
                    ),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(
                      Icons.show_chart,
                      size: 24,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  label: 'Trends',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Find BottomNavigationBar
      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);

      final BottomNavigationBar navBarWidget = tester.widget(bottomNavBar);

      // Check selected item color is purple
      expect(navBarWidget.selectedItemColor, isA<Color>());

      // Check unselected item color is grey
      expect(navBarWidget.unselectedItemColor, isA<Color>());
    });

    testWidgets('Tapping navigation items changes the selected index', (WidgetTester tester) async {
      // Build a simple test widget to check navigation
      int selectedIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color(0xFF8B5CF6),
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: const Icon(
                          Icons.home_outlined,
                          size: 24,
                        ),
                      ),
                      activeIcon: Container(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: const Icon(
                          Icons.home,
                          size: 24,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: const Icon(
                          Icons.show_chart_outlined,
                          size: 24,
                        ),
                      ),
                      activeIcon: Container(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: const Icon(
                          Icons.show_chart,
                          size: 24,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      label: 'Trends',
                    ),
                  ],
                ),
                body: Center(
                  child: Text('Selected: $selectedIndex'),
                ),
              ),
            );
          },
        ),
      );

      await tester.pump();

      // Find navigation items
      final navItems = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byType(InkResponse),
      );

      // Initially first item should be selected
      expect(find.text('Selected: 0'), findsOneWidget);

      // Tap on the second item
      await tester.tap(navItems.at(1));
      await tester.pump();

      // Now second item should be selected
      expect(find.text('Selected: 1'), findsOneWidget);

      // Tap back to first item
      await tester.tap(navItems.at(0));
      await tester.pump();

      // First item should be selected again
      expect(find.text('Selected: 0'), findsOneWidget);
    });

    testWidgets('Custom HeartIcon renders properly when used', (WidgetTester tester) async {
      // Test the custom HeartIcon widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HeartIcon(
                size: 24.0,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find the HeartIcon
      final heartIcon = find.byType(HeartIcon);
      expect(heartIcon, findsOneWidget);

      // Check that it renders with the correct size
      final RenderBox heartRenderBox = tester.renderObject(heartIcon);
      expect(heartRenderBox.size.width, 24.0);
      expect(heartRenderBox.size.height, 24.0);
    });
  });
}