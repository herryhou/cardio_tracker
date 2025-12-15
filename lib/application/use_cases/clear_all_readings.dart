import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/repositories/blood_pressure_repository.dart';

/// Use case for clearing all blood pressure readings
class ClearAllReadings implements UseCase<void, NoParams> {
  final BloodPressureRepository repository;

  ClearAllReadings(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearAllReadings();
  }
}
