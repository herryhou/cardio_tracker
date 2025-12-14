import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/errors/failures.dart';
import '../data_sources/local_database_source.dart';

class BloodPressureRepositoryImpl implements BloodPressureRepository {
  final LocalDatabaseSource dataSource;

  BloodPressureRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<BloodPressureReading>>> getAllReadings() async {
    try {
      final readingsMap = await dataSource.getAllReadings();
      final readings = readingsMap.map(_mapToReading).toList();
      return Right(readings);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get readings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addReading(BloodPressureReading reading) async {
    try {
      final readingMap = _mapFromReading(reading);
      await dataSource.insertReading(readingMap);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReading(BloodPressureReading reading) async {
    try {
      final readingMap = _mapFromReading(reading);
      await dataSource.updateReading(readingMap);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReading(String id) async {
    try {
      await dataSource.deleteReading(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BloodPressureReading>>> getReadingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final readingsMap = await dataSource.getReadingsByDateRange(startDate, endDate);
      final readings = readingsMap.map(_mapToReading).toList();
      return Right(readings);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get readings by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BloodPressureReading?>> getLatestReading() async {
    try {
      final readingMap = await dataSource.getLatestReading();
      if (readingMap == null) return const Right(null);
      return Right(_mapToReading(readingMap));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get latest reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BloodPressureReading>>> getRecentReadings({
    int days = 30,
  }) async {
    return getReadingsByDateRange(
      DateTime.now().subtract(Duration(days: days)),
      DateTime.now(),
    );
  }

  /// Maps a Map<String, dynamic> from the database to a BloodPressureReading domain entity
  BloodPressureReading _mapToReading(Map<String, dynamic> map) {
    return BloodPressureReading(
      id: map['id'] as String,
      systolic: _toInt(map['systolic']),
      diastolic: _toInt(map['diastolic']),
      heartRate: _toInt(map['heartRate']),
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
      lastModified: DateTime.parse(map['lastModified'] as String),
      isDeleted: _toBool(map['isDeleted']) ?? false,
    );
  }

  /// Safely convert dynamic value to int
  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Safely convert dynamic value to bool
  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
      return int.tryParse(value) == 1;
    }
    return null;
  }

  /// Maps a BloodPressureReading domain entity to a Map<String, dynamic> for the database
  Map<String, dynamic> _mapFromReading(BloodPressureReading reading) {
    return {
      'id': reading.id,
      'systolic': reading.systolic,
      'diastolic': reading.diastolic,
      'heartRate': reading.heartRate,
      'timestamp': reading.timestamp.toIso8601String(),
      'notes': reading.notes,
      'lastModified': reading.lastModified.toIso8601String(),
      'isDeleted': reading.isDeleted ? 1 : 0,
    };
  }

  @override
  Future<Either<Failure, void>> clearAllReadings() async {
    try {
      await dataSource.clearAllReadings();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear all readings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> rebuildDatabase() async {
    try {
      await dataSource.rebuildDatabase();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to rebuild database: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> batchInsertReadings(List<BloodPressureReading> readings) async {
    try {
      final readingsMap = readings.map(_mapFromReading).toList();
      await dataSource.batchInsertReadings(readingsMap);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to batch insert readings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> replaceAllReadings(List<BloodPressureReading> readings) async {
    try {
      final readingsMap = readings.map(_mapFromReading).toList();
      await dataSource.replaceAllReadings(readingsMap);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to replace all readings: ${e.toString()}'));
    }
  }
}