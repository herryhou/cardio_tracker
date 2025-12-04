import 'blood_pressure_reading.dart';

class UserSettings {
  final String id;
  final String name;
  final int age;
  final String gender;
  final BloodPressureCategory targetMinCategory;
  final BloodPressureCategory targetMaxCategory;
  final List<String> medicationTimes;
  final List<String> reminderTimes;
  final bool notificationsEnabled;
  final bool dataSharingEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.targetMinCategory,
    required this.targetMaxCategory,
    required this.medicationTimes,
    required this.reminderTimes,
    this.notificationsEnabled = true,
    this.dataSharingEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      targetMinCategory: BloodPressureCategory.values.firstWhere(
        (e) => e.toString() == 'BloodPressureCategory.${json['targetMinCategory']}',
      ),
      targetMaxCategory: BloodPressureCategory.values.firstWhere(
        (e) => e.toString() == 'BloodPressureCategory.${json['targetMaxCategory']}',
      ),
      medicationTimes: List<String>.from(json['medicationTimes'] as List),
      reminderTimes: List<String>.from(json['reminderTimes'] as List),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dataSharingEnabled: json['dataSharingEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'targetMinCategory': targetMinCategory.toString().split('.').last,
      'targetMaxCategory': targetMaxCategory.toString().split('.').last,
      'medicationTimes': medicationTimes,
      'reminderTimes': reminderTimes,
      'notificationsEnabled': notificationsEnabled,
      'dataSharingEnabled': dataSharingEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    BloodPressureCategory? targetMinCategory,
    BloodPressureCategory? targetMaxCategory,
    List<String>? medicationTimes,
    List<String>? reminderTimes,
    bool? notificationsEnabled,
    bool? dataSharingEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      targetMinCategory: targetMinCategory ?? this.targetMinCategory,
      targetMaxCategory: targetMaxCategory ?? this.targetMaxCategory,
      medicationTimes: medicationTimes ?? this.medicationTimes,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSettings(id: $id, name: $name, age: $age, gender: $gender, targetMinCategory: $targetMinCategory, targetMaxCategory: $targetMaxCategory, medicationTimes: $medicationTimes, reminderTimes: $reminderTimes, notificationsEnabled: $notificationsEnabled, dataSharingEnabled: $dataSharingEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.id == id &&
        other.name == name &&
        other.age == age &&
        other.gender == gender &&
        other.targetMinCategory == targetMinCategory &&
        other.targetMaxCategory == targetMaxCategory &&
        other.medicationTimes == medicationTimes &&
        other.reminderTimes == reminderTimes &&
        other.notificationsEnabled == notificationsEnabled &&
        other.dataSharingEnabled == dataSharingEnabled &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        age.hashCode ^
        gender.hashCode ^
        targetMinCategory.hashCode ^
        targetMaxCategory.hashCode ^
        medicationTimes.hashCode ^
        reminderTimes.hashCode ^
        notificationsEnabled.hashCode ^
        dataSharingEnabled.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}