import 'package:flutter/foundation.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/value_objects/reading_statistics.dart';
import '../../application/use_cases/get_all_readings.dart';
import '../../application/use_cases/add_reading.dart';
import '../../application/use_cases/get_reading_statistics.dart';
import '../../core/usecases/usecase.dart';
import '../../core/errors/failures.dart';

class BloodPressureProvider extends ChangeNotifier {
  final GetAllReadings _getAllReadings;
  final AddReading _addReading;
  final GetReadingStatistics _getReadingStatistics;

  List<BloodPressureReading> _readings = [];
  bool _isLoading = false;
  String? _error;
  ReadingStatistics? _statistics;

  BloodPressureProvider({
    required GetAllReadings getAllReadings,
    required AddReading addReading,
    required GetReadingStatistics getReadingStatistics,
  })  : _getAllReadings = getAllReadings,
        _addReading = addReading,
        _getReadingStatistics = getReadingStatistics;

  // Getters
  List<BloodPressureReading> get readings => List.unmodifiable(_readings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  ReadingStatistics? get statistics => _statistics;

  // Computed properties
  double get averageSystolic => _statistics?.averageSystolic ?? 0.0;
  double get averageDiastolic => _statistics?.averageDiastolic ?? 0.0;
  double get averageHeartRate => _statistics?.averageHeartRate ?? 0.0;

  BloodPressureReading? get latestReading {
    if (_readings.isEmpty) return null;
    return _readings.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  List<BloodPressureReading> get recentReadings {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return _readings
        .where((reading) => reading.timestamp.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> loadReadings() async {
    _setLoading(true);
    _clearError();

    final result = await _getAllReadings(const NoParams());

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (readings) {
        _readings = readings;
        _computeStatistics();
      },
    );

    _setLoading(false);
  }

  Future<bool> addReading(BloodPressureReading reading) async {
    _setLoading(true);
    _clearError();

    final result = await _addReading(reading);

    bool success = false;
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (_) {
        success = true;
        _readings.add(reading);
        _computeStatistics();
      },
    );

    _setLoading(false);
    return success;
  }

  void _computeStatistics() {
    if (_readings.isEmpty) {
      _statistics = const ReadingStatistics(
        averageSystolic: 0,
        averageDiastolic: 0,
        averageHeartRate: 0,
        totalReadings: 0,
        categoryDistribution: {},
      );
    } else {
      // Use the use case for statistics
      _getReadingStatistics(const StatisticsParams(days: 365)).then((result) {
        result.fold(
          (failure) => debugPrint('Failed to compute statistics: $failure'),
          (statistics) {
            _statistics = statistics;
            notifyListeners();
          },
        );
      });

      // Compute basic statistics locally for immediate feedback
      final totalSystolic = _readings.fold<int>(0, (sum, r) => sum + r.systolic);
      final totalDiastolic = _readings.fold<int>(0, (sum, r) => sum + r.diastolic);
      final totalHeartRate = _readings.fold<int>(0, (sum, r) => sum + r.heartRate);

      final categoryDistribution = <String, int>{};
      for (final reading in _readings) {
        final category = reading.category.displayName;
        categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
      }

      _statistics = ReadingStatistics(
        averageSystolic: totalSystolic / _readings.length,
        averageDiastolic: totalDiastolic / _readings.length,
        averageHeartRate: totalHeartRate / _readings.length,
        totalReadings: _readings.length,
        categoryDistribution: categoryDistribution,
        latestReadingDate: latestReading?.timestamp,
      );
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure _:
        return (failure as DatabaseFailure).message;
      case NetworkFailure _:
        return (failure as NetworkFailure).message;
      case ValidationFailure _:
        return (failure as ValidationFailure).message;
      default:
        return 'An unexpected error occurred';
    }
  }
}