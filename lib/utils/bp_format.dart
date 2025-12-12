import 'package:flutter/material.dart';

/// Formats blood pressure values with consistent mmHg units
///
/// [systolic] - Systolic blood pressure value
/// [diastolic] - Diastolic blood pressure value
///
/// Returns formatted string like "120/80 mmHg"
///
/// Throws [ArgumentError] if values are negative
String formatBloodPressure(int systolic, int diastolic) {
  if (systolic < 0 || diastolic < 0) {
    throw ArgumentError('Blood pressure values cannot be negative');
  }

  return '$systolic/$diastolic mmHg';
}

/// Formats blood pressure values from string inputs
///
/// [systolicStr] - Systolic blood pressure as string
/// [diastolicStr] - Diastolic blood pressure as string
///
/// Returns formatted string like "120/80 mmHg"
///
/// Throws [ArgumentError] if values are empty or invalid
String formatBloodPressureFromString(String systolicStr, String diastolicStr) {
  if (systolicStr.isEmpty || diastolicStr.isEmpty) {
    throw ArgumentError('Blood pressure values cannot be empty');
  }

  final systolic = int.tryParse(systolicStr);
  final diastolic = int.tryParse(diastolicStr);

  if (systolic == null || diastolic == null) {
    throw ArgumentError('Invalid blood pressure values');
  }

  return formatBloodPressure(systolic, diastolic);
}

/// Formats a blood pressure value as text with consistent styling
///
/// [systolic] - Systolic blood pressure value
/// [diastolic] - Diastolic blood pressure value
/// [style] - Text style to apply
/// [color] - Optional color override (defaults to primary color)
///
/// Returns formatted Text widget
Text formatBloodPressureText(int systolic, int diastolic, {
  TextStyle? style,
  Color? color,
}) {
  return Text(
    formatBloodPressure(systolic, diastolic),
    style: style?.copyWith(
      color: color ?? style.color ?? Colors.black,
    ) ?? TextStyle(
      color: color ?? Colors.black,
    ),
  );
}

/// Formats a blood pressure value as text with consistent styling from string inputs
///
/// [systolicStr] - Systolic blood pressure as string
/// [diastolicStr] - Diastolic blood pressure as string
/// [style] - Text style to apply
/// [color] - Optional color override (defaults to primary color)
///
/// Returns formatted Text widget
Text formatBloodPressureTextFromString(String systolicStr, String diastolicStr, {
  TextStyle? style,
  Color? color,
}) {
  return Text(
    formatBloodPressureFromString(systolicStr, diastolicStr),
    style: style?.copyWith(
      color: color ?? style.color ?? Colors.black,
    ) ?? TextStyle(
      color: color ?? Colors.black,
    ),
  );
}