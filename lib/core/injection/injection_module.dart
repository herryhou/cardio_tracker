import 'package:injectable/injectable.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../../infrastructure/data_sources/local_database_source.dart';
import '../../infrastructure/repositories/blood_pressure_repository_impl.dart';
import '../../infrastructure/repositories/user_settings_repository_impl.dart';
import '../../application/use_cases/get_all_readings.dart';
import '../../application/use_cases/add_reading.dart';
import '../../application/use_cases/update_reading.dart';
import '../../application/use_cases/delete_reading.dart';
import '../../application/use_cases/get_reading_statistics.dart';
import '../../application/use_cases/clear_all_readings.dart';
import '../../application/use_cases/rebuild_database.dart';
import '../../core/validators/reading_validator.dart';

@module
abstract class InjectionModule {
  // Data Sources
  @lazySingleton
  LocalDatabaseSource getLocalDatabaseSource() => LocalDatabaseSource();

  // Repositories
  @lazySingleton
  BloodPressureRepository getBloodPressureRepository(
      LocalDatabaseSource dataSource) {
    return BloodPressureRepositoryImpl(dataSource: dataSource);
  }

  @lazySingleton
  UserSettingsRepository getUserSettingsRepository(
      LocalDatabaseSource dataSource) {
    return UserSettingsRepositoryImpl(dataSource: dataSource);
  }

  // Use Cases
  @lazySingleton
  GetAllReadings getAllReadings(BloodPressureRepository repository) {
    return GetAllReadings(repository);
  }

  @lazySingleton
  AddReading addReading(BloodPressureRepository repository) {
    return AddReading(repository);
  }

  @lazySingleton
  UpdateReading updateReading(BloodPressureRepository repository) {
    return UpdateReading(repository);
  }

  @lazySingleton
  DeleteReading deleteReading(BloodPressureRepository repository) {
    return DeleteReading(repository);
  }

  @lazySingleton
  GetReadingStatistics getReadingStatistics(
      BloodPressureRepository repository) {
    return GetReadingStatistics(repository);
  }

  @lazySingleton
  ClearAllReadings clearAllReadings(BloodPressureRepository repository) {
    return ClearAllReadings(repository);
  }

  @lazySingleton
  RebuildDatabase rebuildDatabase(BloodPressureRepository repository) {
    return RebuildDatabase(repository);
  }

  // Validators
  @lazySingleton
  ReadingValidator getReadingValidator() => ReadingValidator();
}
