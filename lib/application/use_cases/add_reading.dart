import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

class AddReading implements UseCase<void, BloodPressureReading> {
  final BloodPressureRepository repository;

  AddReading(this.repository);

  @override
  Future<Either<Failure, void>> call(BloodPressureReading reading) async {
    // Validate reading
    final validationFailure = _validateReading(reading);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    return repository.addReading(reading);
  }

  ValidationFailure? _validateReading(BloodPressureReading reading) {
    if (reading.systolic < 50 || reading.systolic > 300) {
      return const ValidationFailure('Systolic must be between 50 and 300');
    }
    if (reading.diastolic < 30 || reading.diastolic > 200) {
      return const ValidationFailure('Diastolic must be between 30 and 200');
    }
    if (reading.heartRate < 0 || reading.heartRate > 300) {
      return const ValidationFailure('Heart rate must be between 0 and 300');
    }
    return null;
  }
}