import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../domain/entities/blood_pressure_reading.dart';

/// Utility class for generating deterministic IDs for blood pressure readings
/// based on their content to prevent duplicates during sync
class ReadingIdGenerator {
  /// Generates a deterministic ID from a reading's content
  ///
  /// The ID is generated from the combination of:
  /// - Systolic value
  /// - Diastolic value
  /// - Heart rate value
  /// - Timestamp (to minute precision for consistency)
  /// - Notes (if present)
  ///
  /// This ensures that the same reading created on different devices
  /// will have the same ID, preventing duplicates during sync.
  static String generateId({
    required int systolic,
    required int diastolic,
    required int heartRate,
    required DateTime timestamp,
    String? notes,
  }) {
    // Normalize timestamp to minute precision to avoid second-level differences
    final normalizedTimestamp = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      timestamp.hour,
      timestamp.minute,
    );

    // Create a canonical string representation
    final content = '$systolic|$diastolic|$heartRate|${normalizedTimestamp.toIso8601String()}|${notes ?? ''}';

    // Generate SHA-256 hash and use as ID
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates ID from an existing BloodPressureReading
  static String generateFromReading(BloodPressureReading reading) {
    return generateId(
      systolic: reading.systolic,
      diastolic: reading.diastolic,
      heartRate: reading.heartRate,
      timestamp: reading.timestamp,
      notes: reading.notes,
    );
  }

  /// Checks if two readings have the same content (ignoring ID and timestamps at second precision)
  static bool areContentEqual(BloodPressureReading a, BloodPressureReading b) {
    // Compare values
    if (a.systolic != b.systolic ||
        a.diastolic != b.diastolic ||
        a.heartRate != b.heartRate) {
      return false;
    }

    // Compare timestamps at minute precision
    final aNormalized = DateTime(
      a.timestamp.year,
      a.timestamp.month,
      a.timestamp.day,
      a.timestamp.hour,
      a.timestamp.minute,
    );

    final bNormalized = DateTime(
      b.timestamp.year,
      b.timestamp.month,
      b.timestamp.day,
      b.timestamp.hour,
      b.timestamp.minute,
    );

    if (aNormalized != bNormalized) {
      return false;
    }

    // Compare notes (treating null/empty as equal)
    final aNotes = a.notes?.trim() ?? '';
    final bNotes = b.notes?.trim() ?? '';

    return aNotes == bNotes;
  }
}