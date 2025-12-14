import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/repositories/blood_pressure_repository.dart';

/// Use case for rebuilding the entire database
/// Warning: This will delete all data and recreate the database schema
class RebuildDatabase implements UseCase<void, NoParams> {
  final BloodPressureRepository repository;

  RebuildDatabase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.rebuildDatabase();
  }
}