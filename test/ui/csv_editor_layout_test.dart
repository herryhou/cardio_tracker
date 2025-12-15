import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/presentation/screens/csv_editor_screen.dart';

void main() {
  group('CSV Editor Layout Tests', () {
    testWidgets('should render without infinite size errors',
        (WidgetTester tester) async {
      // Build the CSV editor screen
      await tester.pumpWidget(
        const MaterialApp(
          home: CsvEditorScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify the screen renders without layout errors
      expect(find.byType(CsvEditorScreen), findsOneWidget);
      expect(find.byType(FormTextField), findsOneWidget);

      // Verify the editor has proper constraints
      final textField =
          tester.widget<FormTextField>(find.byType(FormTextField));
      expect(textField.expands, isTrue);
      expect(textField.maxLines, isNull);
    });

    testWidgets('should handle keyboard without overflow',
        (WidgetTester tester) async {
      // Build the CSV editor screen
      await tester.pumpWidget(
        const MaterialApp(
          home: CsvEditorScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Tap on the text field to show keyboard
      await tester.tap(find.byType(FormTextField));
      await tester.pump();

      // Verify the layout adjusts properly
      expect(find.byType(FormTextField), findsOneWidget);
    });
  });
}

// Helper widget to test FormTextField
class FormTextField extends StatelessWidget {
  const FormTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: null,
      expands: true,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }
}
