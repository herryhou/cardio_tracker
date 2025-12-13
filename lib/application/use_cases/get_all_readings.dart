import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

class GetAllReadings implements UseCase<List<BloodPressureReading>, NoParams> {
  final BloodPressureRepository repository;

  GetAllReadings(this.repository);

  @override
  Future<Either<Failure, List<BloodPressureReading>>> call(NoParams params) async {
    return repository.getAllReadings();
  }
}