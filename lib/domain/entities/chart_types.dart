import '../../domain/entities/blood_pressure_reading.dart';

enum ExtendedTimeRange {
  week,
  month,
  season,
  year,
}

class TimeSeriesData {
  final DateTime timestamp;
  final double systolic;
  final double diastolic;
  final double? heartRate;
  final String? notes;
  final String? category;
  final List<BloodPressureReading> originalReadings;

  TimeSeriesData({
    required this.timestamp,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.notes,
    this.category,
    this.originalReadings = const [],
  });
}
