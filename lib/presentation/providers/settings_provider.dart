import 'package:flutter/foundation.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/value_objects/blood_pressure_category.dart';
import '../../domain/repositories/user_settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final UserSettingsRepository _repository;

  UserSettings? _settings;
  bool _isLoading = false;
  String? _error;

  SettingsProvider({required UserSettingsRepository repository})
      : _repository = repository {
    _loadSettings();
  }

  // Getters
  UserSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSettings => _settings != null;

  // Computed properties
  String get userName => _settings?.name ?? 'User';
  int get userAge => _settings?.age ?? 0;
  String get userGender => _settings?.gender ?? 'other';
  BloodPressureCategory get targetMinCategory => _settings?.targetMinCategory ?? BloodPressureCategory.normal;
  BloodPressureCategory get targetMaxCategory => _settings?.targetMaxCategory ?? BloodPressureCategory.normal;
  List<String> get medicationTimes => _settings?.medicationTimes ?? [];
  List<String> get reminderTimes => _settings?.reminderTimes ?? [];
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get dataSharingEnabled => _settings?.dataSharingEnabled ?? false;

  // Settings management
  Future<void> loadSettings() async {
    await _loadSettings();
  }

  Future<void> updateSettings({
    String? name,
    int? age,
    String? gender,
    BloodPressureCategory? targetMinCategory,
    BloodPressureCategory? targetMaxCategory,
    List<String>? medicationTimes,
    List<String>? reminderTimes,
    bool? notificationsEnabled,
    bool? dataSharingEnabled,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_settings == null) {
        // Create new settings if none exist
        _settings = UserSettings(
          id: 'settings-1',
          name: name ?? userName,
          age: age ?? 30,
          gender: gender ?? 'other',
          targetMinCategory: targetMinCategory ?? BloodPressureCategory.normal,
          targetMaxCategory: targetMaxCategory ?? BloodPressureCategory.normal,
          medicationTimes: medicationTimes ?? [],
          reminderTimes: reminderTimes ?? [],
          notificationsEnabled: notificationsEnabled ?? true,
          dataSharingEnabled: dataSharingEnabled ?? false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        // Update existing settings
        _settings = _settings!.copyWith(
          name: name,
          age: age,
          gender: gender,
          targetMinCategory: targetMinCategory,
          targetMaxCategory: targetMaxCategory,
          medicationTimes: medicationTimes,
          reminderTimes: reminderTimes,
          notificationsEnabled: notificationsEnabled,
          dataSharingEnabled: dataSharingEnabled,
          updatedAt: DateTime.now(),
        );
      }

      final result = await _repository.saveSettings(_settings!);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => notifyListeners(),
      );
    } catch (e) {
      _setError('Failed to update settings: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserName(String name) async {
    await updateSettings(name: name);
  }

  Future<void> updateUserAge(int age) async {
    await updateSettings(age: age);
  }

  Future<void> updateUserGender(String gender) async {
    await updateSettings(gender: gender);
  }

  Future<void> updateTargetRanges({
    BloodPressureCategory? minCategory,
    BloodPressureCategory? maxCategory,
  }) async {
    await updateSettings(
      targetMinCategory: minCategory,
      targetMaxCategory: maxCategory,
    );
  }

  Future<void> updateMedicationTimes(List<String> times) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.updateMedicationTimes(times);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          if (_settings != null) {
            _settings = _settings!.copyWith(
              medicationTimes: times,
              updatedAt: DateTime.now(),
            );
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _setError('Failed to update medication times: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReminderTimes(List<String> times) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.updateReminderTimes(times);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          if (_settings != null) {
            _settings = _settings!.copyWith(
              reminderTimes: times,
              updatedAt: DateTime.now(),
            );
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _setError('Failed to update reminder times: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.updateNotificationSettings(enabled);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          if (_settings != null) {
            _settings = _settings!.copyWith(
              notificationsEnabled: enabled,
              updatedAt: DateTime.now(),
            );
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _setError('Failed to update notification settings: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleDataSharing(bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.updateDataSharingSettings(enabled);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          if (_settings != null) {
            _settings = _settings!.copyWith(
              dataSharingEnabled: enabled,
              updatedAt: DateTime.now(),
            );
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _setError('Failed to update data sharing settings: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Medication time management
  Future<void> addMedicationTime(String time) async {
    final updatedTimes = List<String>.from(medicationTimes)..add(time);
    await updateMedicationTimes(updatedTimes);
  }

  Future<void> removeMedicationTime(String time) async {
    final updatedTimes = List<String>.from(medicationTimes)..remove(time);
    await updateMedicationTimes(updatedTimes);
  }

  Future<void> updateMedicationTime(int index, String newTime) async {
    final updatedTimes = List<String>.from(medicationTimes);
    if (index >= 0 && index < updatedTimes.length) {
      updatedTimes[index] = newTime;
      await updateMedicationTimes(updatedTimes);
    }
  }

  // Reminder time management
  Future<void> addReminderTime(String time) async {
    final updatedTimes = List<String>.from(reminderTimes)..add(time);
    await updateReminderTimes(updatedTimes);
  }

  Future<void> removeReminderTime(String time) async {
    final updatedTimes = List<String>.from(reminderTimes)..remove(time);
    await updateReminderTimes(updatedTimes);
  }

  Future<void> updateReminderTime(int index, String newTime) async {
    final updatedTimes = List<String>.from(reminderTimes);
    if (index >= 0 && index < updatedTimes.length) {
      updatedTimes[index] = newTime;
      await updateReminderTimes(updatedTimes);
    }
  }

  // Validation methods
  bool isValidTimeFormat(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return false;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  bool isValidAge(int age) {
    return age >= 0 && age <= 150;
  }

  bool isValidGender(String gender) {
    const validGenders = ['male', 'female', 'other'];
    return validGenders.contains(gender.toLowerCase());
  }

  // Utility methods
  void refresh() {
    _loadSettings();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.resetSettings();

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          _settings = UserSettings(
            id: 'settings-1',
            name: 'User',
            age: 30,
            gender: 'other',
            targetMinCategory: BloodPressureCategory.normal,
            targetMaxCategory: BloodPressureCategory.normal,
            medicationTimes: [],
            reminderTimes: [],
            notificationsEnabled: true,
            dataSharingEnabled: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Failed to reset settings: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  Future<void> _loadSettings() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.getSettings();

      result.fold(
        (failure) {
          // If no settings exist, create default ones
          _createDefaultSettings();
        },
        (settings) {
          _settings = settings;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Failed to load settings: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createDefaultSettings() async {
    _settings = UserSettings(
      id: 'settings-1',
      name: 'User',
      age: 30,
      gender: 'other',
      targetMinCategory: BloodPressureCategory.normal,
      targetMaxCategory: BloodPressureCategory.normal,
      medicationTimes: [],
      reminderTimes: [],
      notificationsEnabled: true,
      dataSharingEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.saveSettings(_settings!);

    result.fold(
      (failure) => _setError('Failed to create default settings: ${failure.message}'),
      (_) => notifyListeners(),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}