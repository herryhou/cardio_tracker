import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../domain/value_objects/reading_statistics.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

class GetReadingStatistics
    implements UseCase<ReadingStatistics, StatisticsParams> {
  final BloodPressureRepository repository;

  GetReadingStatistics(this.repository);

  @override
  Future<Either<Failure, ReadingStatistics>> call(
      StatisticsParams params) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: params.days));

    final result = await repository.getReadingsByDateRange(startDate, endDate);

    return result.fold(
      (failure) => Left(failure),
      (readings) => Right(_calculateStatistics(readings)),
    );
  }

  ReadingStatistics _calculateStatistics(List<BloodPressureReading> readings) {
    if (readings.isEmpty) {
      return const ReadingStatistics(
        averageSystolic: 0,
        averageDiastolic: 0,
        averageHeartRate: 0,
        totalReadings: 0,
        categoryDistribution: {},
      );
    }

    // Sort readings by timestamp to find latest and calculate days between readings
    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate averages
    final totalSystolic = readings.fold<int>(0, (sum, r) => sum + r.systolic);
    final totalDiastolic = readings.fold<int>(0, (sum, r) => sum + r.diastolic);
    final totalHeartRate = readings.fold<int>(0, (sum, r) => sum + r.heartRate);

    // Calculate category distribution
    final categoryDistribution = <String, int>{};
    for (final reading in readings) {
      final category = reading.category.displayName;
      categoryDistribution[category] =
          (categoryDistribution[category] ?? 0) + 1;
    }

    // Calculate average days between readings (if more than one reading)
    int? averageDaysBetweenReadings;
    if (readings.length > 1) {
      int totalDays = 0;
      for (int i = 1; i < readings.length; i++) {
        totalDays +=
            readings[i].timestamp.difference(readings[i - 1].timestamp).inDays;
      }
      averageDaysBetweenReadings = totalDays ~/ (readings.length - 1);
    }

    return ReadingStatistics(
      averageSystolic: totalSystolic / readings.length,
      averageDiastolic: totalDiastolic / readings.length,
      averageHeartRate: totalHeartRate / readings.length,
      totalReadings: readings.length,
      categoryDistribution: categoryDistribution,
      latestReadingDate: readings.last.timestamp,
      averageDaysBetweenReadings: averageDaysBetweenReadings,
    );
  }
}

class StatisticsParams {
  final int days;

  const StatisticsParams({this.days = 30});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatisticsParams && other.days == days;
  }

  @override
  int get hashCode => days.hashCode;

  @override
  String toString() => 'StatisticsParams(days: $days)';
}
