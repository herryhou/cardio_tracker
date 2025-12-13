import 'dart:convert';
import '../../domain/entities/blood_pressure_reading.dart';

/// Extension methods for BloodPressureReading serialization
/// Note: In pure Clean Architecture, this would be in the infrastructure layer
/// and the domain entity would remain pure. This is a pragmatic approach.
extension BloodPressureReadingMapper on BloodPressureReading {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'lastModified': lastModified.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  static BloodPressureReading fromJson(Map<String, dynamic> json) {
    return BloodPressureReading(
      id: json['id'] as String,
      systolic: _toInt(json['systolic']),
      diastolic: _toInt(json['diastolic']),
      heartRate: _toInt(json['heartRate']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      lastModified: DateTime.parse(json['lastModified'] as String),
      isDeleted: _toBool(json['isDeleted']) ?? false,
    );
  }

  /// Safely convert dynamic value to int
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Safely convert dynamic value to bool
  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
      return int.tryParse(value) == 1;
    }
    return null;
  }

  static BloodPressureReading fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return fromJson(json);
  }
}