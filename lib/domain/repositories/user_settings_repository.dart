import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_settings.dart';
import '../value_objects/blood_pressure_category.dart';

abstract class UserSettingsRepository {
  /// Gets user settings
  Future<Either<Failure, UserSettings>> getSettings();

  /// Saves user settings
  Future<Either<Failure, void>> saveSettings(UserSettings settings);

  /// Updates notification settings
  Future<Either<Failure, void>> updateNotificationSettings(bool enabled);

  /// Updates data sharing settings
  Future<Either<Failure, void>> updateDataSharingSettings(bool enabled);

  /// Updates medication times
  Future<Either<Failure, void>> updateMedicationTimes(List<String> times);

  /// Updates reminder times
  Future<Either<Failure, void>> updateReminderTimes(List<String> times);

  /// Updates target blood pressure categories
  Future<Either<Failure, void>> updateTargetCategories(
    BloodPressureCategory minCategory,
    BloodPressureCategory maxCategory,
  );

  /// Resets all settings to defaults
  Future<Either<Failure, void>> resetSettings();

  /// Checks if settings exist
  Future<Either<Failure, bool>> hasSettings();

  // Database management methods
  /// Clears all user settings from the database
  Future<Either<Failure, void>> clearAllSettings();
}
