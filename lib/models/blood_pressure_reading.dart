enum BloodPressureCategory {
  low,
  normal,
  elevated,
  stage1,
  stage2,
  crisis,
}

class BloodPressureReading {
  final String id;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final DateTime timestamp;
  final String? notes;
  final DateTime lastModified; // NEW
  final bool isDeleted; // NEW

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
    // Check for hypertensive crisis first (highest priority)
    if (systolic >= 180 || diastolic >= 120) {
      return BloodPressureCategory.crisis;
    }

    // Check for Stage 2 hypertension (either reading meets criteria)
    if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureCategory.stage2;
    }

    // Check for Stage 1 hypertension (either reading meets criteria)
    if (systolic >= 130 || diastolic >= 85) {
      return BloodPressureCategory.stage1;
    }

    // Check for elevated (systolic 121-129 OR diastolic 81-84)
    if ((systolic >= 121 && systolic <= 129) ||
        (diastolic >= 81 && diastolic <= 84)) {
      return BloodPressureCategory.elevated;
    }

    // Check for normal (systolic >90 AND <=120 AND diastolic >60 AND <=80)
    if (systolic > 90 && systolic <= 120 && diastolic > 60 && diastolic <= 80) {
      return BloodPressureCategory.normal;
    }

    // Otherwise, it's low
    return BloodPressureCategory.low;
  }

  /// Returns true if heart rate is available and valid (> 0)
  bool get hasHeartRate => heartRate > 0;

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) {
    return BloodPressureReading(
      id: json['id'] as String,
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      heartRate: json['heartRate'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : DateTime.now(),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

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
  String toString() {
    return 'BloodPressureReading(id: $id, systolic: $systolic, diastolic: $diastolic, heartRate: $heartRate, timestamp: $timestamp, notes: $notes, lastModified: $lastModified, isDeleted: $isDeleted)';
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
