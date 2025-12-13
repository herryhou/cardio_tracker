class ReadingStatistics {
  final double averageSystolic;
  final double averageDiastolic;
  final double averageHeartRate;
  final int totalReadings;
  final Map<String, int> categoryDistribution;
  final DateTime? latestReadingDate;
  final int? averageDaysBetweenReadings;

  const ReadingStatistics({
    required this.averageSystolic,
    required this.averageDiastolic,
    required this.averageHeartRate,
    required this.totalReadings,
    required this.categoryDistribution,
    this.latestReadingDate,
    this.averageDaysBetweenReadings,
  });

  bool get hasData => totalReadings > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingStatistics &&
        other.averageSystolic == averageSystolic &&
        other.averageDiastolic == averageDiastolic &&
        other.averageHeartRate == averageHeartRate &&
        other.totalReadings == totalReadings &&
        other.categoryDistribution == categoryDistribution &&
        other.latestReadingDate == latestReadingDate &&
        other.averageDaysBetweenReadings == averageDaysBetweenReadings;
  }

  @override
  int get hashCode {
    return averageSystolic.hashCode ^
        averageDiastolic.hashCode ^
        averageHeartRate.hashCode ^
        totalReadings.hashCode ^
        categoryDistribution.hashCode ^
        latestReadingDate.hashCode ^
        averageDaysBetweenReadings.hashCode;
  }

  @override
  String toString() {
    return 'ReadingStatistics('
        'averageSystolic: $averageSystolic, '
        'averageDiastolic: $averageDiastolic, '
        'averageHeartRate: $averageHeartRate, '
        'totalReadings: $totalReadings, '
        'categoryDistribution: $categoryDistribution, '
        'latestReadingDate: $latestReadingDate, '
        'averageDaysBetweenReadings: $averageDaysBetweenReadings)';
  }
}