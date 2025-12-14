import 'dart:convert';
import 'package:csv/csv.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../core/validators/reading_validator.dart';
import '../../domain/value_objects/blood_pressure_category.dart';

/// Error type for CSV import operations
enum CsvImportError {
  invalidFormat,
  invalidHeaders,
  invalidDate,
  invalidSystolic,
  invalidDiastolic,
  invalidHeartRate,
  invalidNotes,
  systolicLessThanDiastolic,
  duplicateTimestamp,
  futureDate,
  tooManyReadings,
  tooFewReadings,
  emptyFile,
}

/// Represents a validation error for a specific line
class LineValidationError {
  final int lineNumber;
  final CsvImportError error;
  final String details;

  LineValidationError(this.lineNumber, this.error, this.details);

  @override
  String toString() => 'Line $lineNumber: $details';
}

/// Result of CSV import validation
class CsvImportResult {
  final bool isValid;
  final List<BloodPressureReading> readings;
  final List<LineValidationError> errors;

  CsvImportResult({
    required this.isValid,
    required this.readings,
    required this.errors,
  });
}

/// Service for importing and validating CSV data
class CsvImportService {
  final ReadingValidator _validator;
  static const int maxReadings = 10000;
  static const int minReadings = 1;

  CsvImportService(this._validator);

  /// Parse and validate CSV content
  Future<CsvImportResult> importFromCsv(String csvContent) async {
    try {
      // Parse CSV
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent);

      if (rows.isEmpty) {
        return CsvImportResult(
          isValid: false,
          readings: [],
          errors: [LineValidationError(1, CsvImportError.emptyFile, 'CSV file is empty')],
        );
      }

      // Validate headers
      final headers = rows[0].map((h) => h.toString().trim()).toList();
      final headerValidation = _validateHeaders(headers);
      if (!headerValidation.isValid) {
        return CsvImportResult(
          isValid: false,
          readings: [],
          errors: headerValidation.errors,
        );
      }

      // Parse data rows
      final readings = <BloodPressureReading>[];
      final errors = <LineValidationError>[];
      final timestampSet = <DateTime>{};

      for (int i = 1; i < rows.length; i++) {
        final lineNum = i + 1;
        final row = rows[i];

        // Skip empty rows
        if (row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
          continue;
        }

        // Validate row has correct number of columns
        if (row.length < 7) {
          errors.add(LineValidationError(
            lineNum,
            CsvImportError.invalidFormat,
            'Row has ${row.length} columns, expected at least 7. Missing values will be treated as empty.',
          ));
          // Pad the row if it's too short
          while (row.length < 7) {
            row.add('');
          }
        } else if (row.length > 7) {
          errors.add(LineValidationError(
            lineNum,
            CsvImportError.invalidFormat,
            'Row has ${row.length} columns, expected exactly 7. Extra data may indicate malformed CSV.',
          ));
        }

        try {
          final reading = _parseRow(lineNum, row, timestampSet);
          readings.add(reading);
          timestampSet.add(reading.timestamp);
        } catch (e) {
          if (e is LineValidationError) {
            errors.add(e);
          } else {
            errors.add(LineValidationError(lineNum, CsvImportError.invalidFormat, 'Unexpected error: $e'));
          }
        }
      }

      // Check reading count constraints
      if (readings.length < minReadings) {
        errors.add(LineValidationError(0, CsvImportError.tooFewReadings, 'At least one reading is required'));
      }

      if (readings.length > maxReadings) {
        errors.add(LineValidationError(0, CsvImportError.tooManyReadings,
          'Maximum $maxReadings readings allowed (found ${readings.length})'));
      }

      // Sort readings by timestamp
      readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return CsvImportResult(
        isValid: errors.isEmpty,
        readings: readings,
        errors: errors,
      );

    } catch (e) {
      return CsvImportResult(
        isValid: false,
        readings: [],
        errors: [LineValidationError(0, CsvImportError.invalidFormat, 'Failed to parse CSV: $e')],
      );
    }
  }

  /// Validate CSV headers match expected format
  _HeaderValidationResult _validateHeaders(List<String> headers) {
    const expectedHeaders = [
      'Date',
      'Time',
      'Systolic (mmHg)',
      'Diastolic (mmHg)',
      'Heart Rate (bpm)',
      'Category',
      'Notes'
    ];

    // Check if we have all required headers
    final missingHeaders = <String>[];
    for (int i = 0; i < 5; i++) { // First 5 headers are required
      if (headers.length <= i || headers[i] != expectedHeaders[i]) {
        missingHeaders.add(expectedHeaders[i]);
      }
    }

    if (missingHeaders.isNotEmpty) {
      return _HeaderValidationResult(
        isValid: false,
        errors: [LineValidationError(1, CsvImportError.invalidHeaders,
          'Missing or incorrect headers. Expected: ${expectedHeaders.take(5).join(', ')}')],
      );
    }

    return _HeaderValidationResult(isValid: true, errors: []);
  }

  /// Parse a single CSV row into a BloodPressureReading
  BloodPressureReading _parseRow(int lineNum, List<dynamic> row, Set<DateTime> existingTimestamps) {
    // Extract values with defaults
    final dateStr = _getString(row, 0);
    final timeStr = _getString(row, 1) ?? '00:00';
    final systolicStr = _getString(row, 2);
    final diastolicStr = _getString(row, 3);
    final heartRateStr = _getString(row, 4);
    // Category column (5) is ignored - will be calculated
    final notes = _getString(row, 6);

    // Parse date and time
    final timestamp = _parseDateTime(lineNum, dateStr, timeStr);

    // Check for duplicate timestamps
    if (existingTimestamps.contains(timestamp)) {
      throw LineValidationError(lineNum, CsvImportError.duplicateTimestamp,
        'Duplicate timestamp: ${_formatDateTime(timestamp)}');
    }

    // Parse numeric values
    final systolic = _parseInt(lineNum, systolicStr, CsvImportError.invalidSystolic, 'Systolic');
    final diastolic = _parseInt(lineNum, diastolicStr, CsvImportError.invalidDiastolic, 'Diastolic');
    final heartRate = _parseInt(lineNum, heartRateStr, CsvImportError.invalidHeartRate, 'Heart Rate');

    // Validate ranges and relationships
    _validator.validateSystolic(systolic);
    _validator.validateDiastolic(diastolic);
    _validator.validateHeartRate(heartRate);
    _validator.validateSystolicDiastolic(systolic, diastolic);
    _validator.validateTimestamp(timestamp);
    if (notes != null) {
      _validator.validateNotes(notes);
    }

    // Create reading
    return BloodPressureReading(
      id: DateTime.now().millisecondsSinceEpoch.toString() + lineNum.toString(),
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      timestamp: timestamp,
      notes: notes,
      lastModified: DateTime.now(),
      isDeleted: false,
    );
  }

  /// Helper to get string value from row
  String? _getString(List<dynamic> row, int index) {
    if (index >= row.length) return null;
    final value = row[index];
    if (value == null) return null;
    return value.toString().trim();
  }

  /// Parse date and time from strings
  DateTime _parseDateTime(int lineNum, String? dateStr, String timeStr) {
    if (dateStr == null || dateStr.isEmpty) {
      throw LineValidationError(lineNum, CsvImportError.invalidDate, 'Date is required');
    }

    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) {
        throw FormatException();
      }

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      int hour = 0;
      int minute = 0;

      if (timeStr.isNotEmpty && timeStr != '00:00') {
        final timeParts = timeStr.split(':');
        if (timeParts.length >= 2) {
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);
        }
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      throw LineValidationError(lineNum, CsvImportError.invalidDate,
        'Invalid date format. Expected YYYY-MM-DD, got: $dateStr');
    }
  }

  /// Parse integer value with validation
  int _parseInt(int lineNum, String? valueStr, CsvImportError errorType, String fieldName) {
    if (valueStr == null || valueStr.isEmpty) {
      throw LineValidationError(lineNum, errorType, '$fieldName is required');
    }

    final value = int.tryParse(valueStr);
    if (value == null) {
      throw LineValidationError(lineNum, errorType,
        'Invalid $fieldName value: $valueStr (must be a number)');
    }

    return value;
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Helper class for header validation
class _HeaderValidationResult {
  final bool isValid;
  final List<LineValidationError> errors;

  _HeaderValidationResult({required this.isValid, required this.errors});
}