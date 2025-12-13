import 'package:dartz/dartz.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

class DeleteReadingParams {
  final String id;

  const DeleteReadingParams({required this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteReadingParams && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeleteReadingParams(id: $id)';
}

class DeleteReading implements UseCase<void, DeleteReadingParams> {
  final BloodPressureRepository repository;

  DeleteReading(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReadingParams params) async {
    if (params.id.isEmpty) {
      return const Left(ValidationFailure('Reading ID cannot be empty'));
    }

    return repository.deleteReading(params.id);
  }
}