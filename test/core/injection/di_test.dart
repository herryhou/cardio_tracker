import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/core/injection/injection.dart';
import 'package:cardio_tracker/application/use_cases/get_all_readings.dart';
import 'package:cardio_tracker/application/use_cases/add_reading.dart';
import 'package:cardio_tracker/application/use_cases/get_reading_statistics.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/infrastructure/data_sources/local_database_source.dart';

void main() {
  group('Dependency Injection Setup', () {
    setUpAll(() async {
      // Initialize DI before tests
      await configureDependencies();
    });

    test('should resolve all dependencies correctly', () {
      // Test that use cases are registered
      expect(getIt.isRegistered<GetAllReadings>(), isTrue);
      expect(getIt.isRegistered<AddReading>(), isTrue);
      expect(getIt.isRegistered<GetReadingStatistics>(), isTrue);

      // Test that repository is registered
      expect(getIt.isRegistered<BloodPressureRepository>(), isTrue);

      // Test that data source is registered
      expect(getIt.isRegistered<LocalDatabaseSource>(), isTrue);
    });

    test('should get instances of dependencies', () {
      // Get instances
      final getAllReadings = getIt<GetAllReadings>();
      final addReading = getIt<AddReading>();
      final getStatistics = getIt<GetReadingStatistics>();
      final repository = getIt<BloodPressureRepository>();
      final dataSource = getIt<LocalDatabaseSource>();

      // Verify instances are not null
      expect(getAllReadings, isNotNull);
      expect(addReading, isNotNull);
      expect(getStatistics, isNotNull);
      expect(repository, isNotNull);
      expect(dataSource, isNotNull);
    });

    test('should return same instance for singletons', () {
      // Get instances multiple times
      final getAllReadings1 = getIt<GetAllReadings>();
      final getAllReadings2 = getIt<GetAllReadings>();

      final dataSource1 = getIt<LocalDatabaseSource>();
      final dataSource2 = getIt<LocalDatabaseSource>();

      // Verify they are the same instance (lazy singleton)
      expect(identical(getAllReadings1, getAllReadings2), isTrue);
      expect(identical(dataSource1, dataSource2), isTrue);
    });
  });
}
