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
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      heartRate: json['heartRate'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      lastModified: DateTime.parse(json['lastModified'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  static BloodPressureReading fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return fromJson(json);
  }
}