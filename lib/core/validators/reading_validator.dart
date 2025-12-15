import 'package:cardio_tracker/infrastructure/services/csv_import_service.dart';

/// Validation exception for blood pressure readings
class ValidationException implements Exception {
  final CsvImportError error;
  final String message;

  ValidationException(this.error, this.message);

  @override
  String toString() => message;
}

/// Validates blood pressure reading values according to medical and system constraints
class ReadingValidator {
  // Medical constraints based on general guidelines
  static const int minSystolic = 40;
  static const int maxSystolic = 250;
  static const int minDiastolic = 30;
  static const int maxDiastolic = 180;
  static const int minHeartRate = 20;
  static const int maxHeartRate = 220;
  static const int maxNotesLength = 500;

  /// Validates systolic blood pressure value
  void validateSystolic(int systolic) {
    if (systolic < minSystolic || systolic > maxSystolic) {
      throw ValidationException(
        CsvImportError.invalidSystolic,
        'Systolic must be between $minSystolic and $maxSystolic mmHg, got $systolic',
      );
    }
  }

  /// Validates diastolic blood pressure value
  void validateDiastolic(int diastolic) {
    if (diastolic < minDiastolic || diastolic > maxDiastolic) {
      throw ValidationException(
        CsvImportError.invalidDiastolic,
        'Diastolic must be between $minDiastolic and $maxDiastolic mmHg, got $diastolic',
      );
    }
  }

  /// Validates heart rate value
  void validateHeartRate(int heartRate) {
    if (heartRate < minHeartRate || heartRate > maxHeartRate) {
      throw ValidationException(
        CsvImportError.invalidHeartRate,
        'Heart rate must be between $minHeartRate and $maxHeartRate bpm, got $heartRate',
      );
    }
  }

  /// Validates that systolic is greater than or equal to diastolic
  void validateSystolicDiastolic(int systolic, int diastolic) {
    if (systolic < diastolic) {
      throw ValidationException(
        CsvImportError.systolicLessThanDiastolic,
        'Systolic ($systolic) must be greater than or equal to diastolic ($diastolic)',
      );
    }
  }

  /// Validates timestamp is not in the future
  void validateTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.isAfter(now)) {
      throw ValidationException(
        CsvImportError.futureDate,
        'Timestamp cannot be in the future: ${timestamp.toIso8601String()}',
      );
    }

    // Check for unreasonable dates (too far in the past)
    final minDate = DateTime(now.year - 120); // No one is 120+ years old
    if (timestamp.isBefore(minDate)) {
      throw ValidationException(
        CsvImportError.invalidDate,
        'Timestamp is too far in the past: ${timestamp.toIso8601String()}',
      );
    }
  }

  /// Validates notes field length
  void validateNotes(String notes) {
    if (notes.length > maxNotesLength) {
      throw ValidationException(
        CsvImportError.invalidNotes,
        'Notes must be $maxNotesLength characters or less, got ${notes.length}',
      );
    }
  }

  /// Validates a complete blood pressure reading
  void validateCompleteReading({
    required int systolic,
    required int diastolic,
    required int heartRate,
    required DateTime timestamp,
    String? notes,
  }) {
    validateSystolic(systolic);
    validateDiastolic(diastolic);
    validateHeartRate(heartRate);
    validateSystolicDiastolic(systolic, diastolic);
    validateTimestamp(timestamp);
    if (notes != null && notes.isNotEmpty) {
      validateNotes(notes);
    }
  }

  /// Checks if heart rate is reasonable for blood pressure values
  /// This is a soft check that returns a warning rather than an error
  String? checkHeartRateReasonableness(
      int systolic, int diastolic, int heartRate) {
    // Very high BP with low HR could indicate error
    if (systolic >= 180 && heartRate < 50) {
      return 'Warning: High blood pressure ($systolic/$diastolic) with low heart rate ($heartRate)';
    }

    // Very low BP with high HR could indicate error
    if (systolic <= 90 && heartRate > 150) {
      return 'Warning: Low blood pressure ($systolic/$diastolic) with high heart rate ($heartRate)';
    }

    // Normal ranges
    if (heartRate >= 40 && heartRate <= 180) {
      return null;
    }

    return 'Warning: Heart rate $heartRate is unusual';
  }
}
