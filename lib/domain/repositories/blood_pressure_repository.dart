import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/blood_pressure_reading.dart';

abstract class BloodPressureRepository {
  /// Gets all blood pressure readings
  Future<Either<Failure, List<BloodPressureReading>>> getAllReadings();

  /// Adds a new blood pressure reading
  Future<Either<Failure, void>> addReading(BloodPressureReading reading);

  /// Updates an existing blood pressure reading
  Future<Either<Failure, void>> updateReading(BloodPressureReading reading);

  /// Deletes a blood pressure reading by ID (soft delete)
  Future<Either<Failure, void>> deleteReading(String id);

  /// Gets blood pressure readings within a date range
  Future<Either<Failure, List<BloodPressureReading>>> getReadingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets the latest blood pressure reading
  Future<Either<Failure, BloodPressureReading?>> getLatestReading();

  /// Gets recent blood pressure readings
  Future<Either<Failure, List<BloodPressureReading>>> getRecentReadings({
    int days = 30,
  });
}