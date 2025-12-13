import '../value_objects/blood_pressure_category.dart';

class BloodPressureReading {
  final String id;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final DateTime timestamp;
  final String? notes;
  final DateTime lastModified;
  final bool isDeleted;

  BloodPressureReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.timestamp,
    this.notes,
    required this.lastModified,
    this.isDeleted = false,
  });

  BloodPressureCategory get category {
    return BloodPressureCategory.fromValues(systolic, diastolic);
  }

  bool get hasHeartRate => heartRate > 0;

  BloodPressureReading copyWith({
    String? id,
    int? systolic,
    int? diastolic,
    int? heartRate,
    DateTime? timestamp,
    String? notes,
    DateTime? lastModified,
    bool? isDeleted,
  }) {
    return BloodPressureReading(
      id: id ?? this.id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      lastModified: lastModified ?? this.lastModified,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodPressureReading &&
        other.id == id &&
        other.systolic == systolic &&
        other.diastolic == diastolic &&
        other.heartRate == heartRate &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.lastModified == lastModified &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        systolic.hashCode ^
        diastolic.hashCode ^
        heartRate.hashCode ^
        timestamp.hashCode ^
        notes.hashCode ^
        lastModified.hashCode ^
        isDeleted.hashCode;
  }
}