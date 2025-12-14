// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../application/use_cases/add_reading.dart' as _i784;
import '../../application/use_cases/clear_all_readings.dart' as _i317;
import '../../application/use_cases/delete_reading.dart' as _i548;
import '../../application/use_cases/get_all_readings.dart' as _i931;
import '../../application/use_cases/get_reading_statistics.dart' as _i191;
import '../../application/use_cases/rebuild_database.dart' as _i850;
import '../../application/use_cases/update_reading.dart' as _i686;
import '../../domain/repositories/blood_pressure_repository.dart' as _i347;
import '../../domain/repositories/user_settings_repository.dart' as _i931;
import '../../infrastructure/data_sources/local_database_source.dart' as _i378;
import 'injection_module.dart' as _i212;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final injectionModule = _$InjectionModule();
    gh.lazySingleton<_i378.LocalDatabaseSource>(
        () => injectionModule.getLocalDatabaseSource());
    gh.lazySingleton<_i347.BloodPressureRepository>(() => injectionModule
        .getBloodPressureRepository(gh<_i378.LocalDatabaseSource>()));
    gh.lazySingleton<_i931.UserSettingsRepository>(() => injectionModule
        .getUserSettingsRepository(gh<_i378.LocalDatabaseSource>()));
    gh.lazySingleton<_i931.GetAllReadings>(() =>
        injectionModule.getAllReadings(gh<_i347.BloodPressureRepository>()));
    gh.lazySingleton<_i784.AddReading>(
        () => injectionModule.addReading(gh<_i347.BloodPressureRepository>()));
    gh.lazySingleton<_i686.UpdateReading>(() =>
        injectionModule.updateReading(gh<_i347.BloodPressureRepository>()));
    gh.lazySingleton<_i548.DeleteReading>(() =>
        injectionModule.deleteReading(gh<_i347.BloodPressureRepository>()));
    gh.lazySingleton<_i191.GetReadingStatistics>(() => injectionModule
        .getReadingStatistics(gh<_i347.BloodPressureRepository>()));
    gh.lazySingleton<_i317.ClearAllReadings>(() =>
        injectionModule.clearAllReadings(gh<_i347.BloodPressureRepository>()));
    gh.lazySingleton<_i850.RebuildDatabase>(() =>
        injectionModule.rebuildDatabase(gh<_i347.BloodPressureRepository>()));
    return this;
  }
}

class _$InjectionModule extends _i212.InjectionModule {}
