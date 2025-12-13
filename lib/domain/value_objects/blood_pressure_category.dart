enum BloodPressureCategory {
  low,
  normal,
  elevated,
  stage1,
  stage2,
  crisis;

  static BloodPressureCategory fromValues(int systolic, int diastolic) {
    // Check for hypertensive crisis first (highest priority)
    if (systolic >= 180 || diastolic >= 120) {
      return BloodPressureCategory.crisis;
    }

    // Check for Stage 2 hypertension
    if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureCategory.stage2;
    }

    // Check for Stage 1 hypertension
    if (systolic >= 130 || diastolic >= 85) {
      return BloodPressureCategory.stage1;
    }

    // Check for elevated
    if ((systolic >= 121 && systolic <= 129) ||
        (diastolic >= 81 && diastolic <= 84)) {
      return BloodPressureCategory.elevated;
    }

    // Check for normal
    if (systolic > 90 && systolic <= 120 && diastolic > 60 && diastolic <= 80) {
      return BloodPressureCategory.normal;
    }

    // Otherwise, it's low
    return BloodPressureCategory.low;
  }

  String get displayName {
    switch (this) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }
}