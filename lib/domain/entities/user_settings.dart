import '../value_objects/blood_pressure_category.dart';

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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.id == id &&
        other.name == name &&
        other.age == age &&
        other.gender == gender &&
        other.targetMinCategory == targetMinCategory &&
        other.targetMaxCategory == targetMaxCategory &&
        _listEquals(other.medicationTimes, medicationTimes) &&
        _listEquals(other.reminderTimes, reminderTimes) &&
        other.notificationsEnabled == notificationsEnabled &&
        other.dataSharingEnabled == dataSharingEnabled &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      age,
      gender,
      targetMinCategory,
      targetMaxCategory,
      Object.hashAll(medicationTimes),
      Object.hashAll(reminderTimes),
      notificationsEnabled,
      dataSharingEnabled,
      createdAt,
      updatedAt,
    );
  }

  /// Helper method to compare two lists for equality
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
