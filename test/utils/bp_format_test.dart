import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/utils/bp_format.dart';

void main() {
  group('Blood Pressure Formatting', () {
    test('formats systolic/diastolic with mmHg units', () {
      expect(formatBloodPressure(120, 80), '120/80 mmHg');
    });

    test('formats different BP values correctly', () {
      expect(formatBloodPressure(130, 85), '130/85 mmHg');
      expect(formatBloodPressure(118, 78), '118/78 mmHg');
      expect(formatBloodPressure(140, 90), '140/90 mmHg');
    });

    test('formats edge cases', () {
      expect(formatBloodPressure(0, 0), '0/0 mmHg');
      expect(formatBloodPressure(200, 100), '200/100 mmHg');
    });

    test('throws on negative values', () {
      expect(() => formatBloodPressure(-10, 80), throwsArgumentError);
      expect(() => formatBloodPressure(120, -5), throwsArgumentError);
      expect(() => formatBloodPressure(-10, -5), throwsArgumentError);
    });

    test('formats from string input', () {
      expect(formatBloodPressureFromString('120', '80'), '120/80 mmHg');
      expect(formatBloodPressureFromString('130', '85'), '130/85 mmHg');
    });

    test('handles null/empty string inputs', () {
      expect(() => formatBloodPressureFromString('', '80'), throwsArgumentError);
      expect(() => formatBloodPressureFromString('120', ''), throwsArgumentError);
      expect(() => formatBloodPressureFromString('', ''), throwsArgumentError);
    });
  });
}