import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/domain/value_objects/blood_pressure_category.dart';

void main() {
  group('BloodPressureCategory', () {
    test('should return CRISIS for systolic >= 180', () {
      final category = BloodPressureCategory.fromValues(180, 80);
      expect(category, BloodPressureCategory.crisis);
    });

    test('should return CRISIS for diastolic >= 120', () {
      final category = BloodPressureCategory.fromValues(120, 120);
      expect(category, BloodPressureCategory.crisis);
    });

    test('should return NORMAL for valid normal range', () {
      final category = BloodPressureCategory.fromValues(115, 75);
      expect(category, BloodPressureCategory.normal);
    });

    test('should return LOW for low values', () {
      final category = BloodPressureCategory.fromValues(85, 55);
      expect(category, BloodPressureCategory.low);
    });

    test('should return ELEVATED for elevated systolic (121-129)', () {
      final category = BloodPressureCategory.fromValues(125, 80);
      expect(category, BloodPressureCategory.elevated);
    });

    test('should return STAGE1 for Stage 1 hypertension', () {
      final category = BloodPressureCategory.fromValues(130, 85);
      expect(category, BloodPressureCategory.stage1);
    });

    test('should return STAGE2 for Stage 2 hypertension', () {
      final category = BloodPressureCategory.fromValues(140, 90);
      expect(category, BloodPressureCategory.stage2);
    });

    test('should have correct display names', () {
      expect(BloodPressureCategory.low.displayName, 'Low');
      expect(BloodPressureCategory.normal.displayName, 'Normal');
      expect(BloodPressureCategory.elevated.displayName, 'Elevated');
      expect(BloodPressureCategory.stage1.displayName, 'Stage 1');
      expect(BloodPressureCategory.stage2.displayName, 'Stage 2');
      expect(BloodPressureCategory.crisis.displayName, 'Crisis');
    });
  });
}
