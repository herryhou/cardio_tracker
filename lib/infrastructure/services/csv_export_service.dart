import 'dart:io';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/value_objects/blood_pressure_category.dart';

class CsvExportService {
  /// Export blood pressure readings to CSV string
  String exportAllReadings(List<BloodPressureReading> readings) {
    // Create CSV data
    List<List<dynamic>> csvData = [
      [
        'Date',
        'Time',
        'Systolic (mmHg)',
        'Diastolic (mmHg)',
        'Heart Rate (bpm)',
        'Category',
        'Notes'
      ]
    ];

    // Sort readings by date (oldest first for editor)
    final sortedReadings = List<BloodPressureReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final reading in sortedReadings) {
      csvData.add([
        DateFormat('yyyy-MM-dd').format(reading.timestamp),
        DateFormat('HH:mm').format(reading.timestamp),
        reading.systolic,
        reading.diastolic,
        reading.heartRate,
        _getCategoryText(reading.category),
        reading.notes ?? '',
      ]);
    }

    // Convert to CSV string with explicit line endings
    final csvString = const ListToCsvConverter().convert(csvData);

    // Ensure proper line endings and that the CSV ends with a newline
    String normalized = csvString;
    if (!normalized.endsWith('\n')) {
      normalized += '\n';
    }

    // Normalize line endings to \n (not \r\n)
    normalized = normalized.replaceAll('\r\n', '\n');

    return normalized;
  }

  /// Export blood pressure readings to CSV file and share it
  static Future<void> exportToCsv(List<BloodPressureReading> readings) async {
    if (readings.isEmpty) {
      throw Exception('No readings to export');
    }

    try {
      // Create CSV data
      List<List<dynamic>> csvData = [
        [
          'Date',
          'Time',
          'Systolic (mmHg)',
          'Diastolic (mmHg)',
          'Heart Rate (bpm)',
          'Category',
          'Notes'
        ]
      ];

      // Sort readings by date (newest first)
      final sortedReadings = List<BloodPressureReading>.from(readings)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      for (final reading in sortedReadings) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(reading.timestamp),
          DateFormat('HH:mm').format(reading.timestamp),
          reading.systolic,
          reading.diastolic,
          reading.heartRate,
          _getCategoryText(reading.category),
          reading.notes ?? '',
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Create file
      final directory = Directory.systemTemp;
      final fileName =
          'blood_pressure_readings_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV to file
      await file.writeAsString(csv);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, name: fileName)],
        subject: 'Blood Pressure Readings',
        text:
            'Exported ${readings.length} blood pressure readings from Cardio Tracker',
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Export readings for a specific date range
  static Future<void> exportDateRange(
    List<BloodPressureReading> readings,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final filteredReadings = readings.where((reading) {
      return reading.timestamp
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          reading.timestamp.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    await exportToCsv(filteredReadings);
  }

  /// Export readings for last N days
  static Future<void> exportLastNDays(
      List<BloodPressureReading> readings, int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    await exportDateRange(readings, startDate, endDate);
  }

  /// Export readings for current month
  static Future<void> exportCurrentMonth(
      List<BloodPressureReading> readings) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    await exportDateRange(readings, startDate, endDate);
  }

  /// Get category text for CSV export
  static String _getCategoryText(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }

  /// Generate CSV summary statistics
  static String generateSummaryStats(List<BloodPressureReading> readings) {
    if (readings.isEmpty) {
      return 'No data available';
    }

    final avgSystolic =
        readings.map((r) => r.systolic).reduce((a, b) => a + b) /
            readings.length;
    final avgDiastolic =
        readings.map((r) => r.diastolic).reduce((a, b) => a + b) /
            readings.length;
    final avgHeartRate =
        readings.map((r) => r.heartRate).reduce((a, b) => a + b) /
            readings.length;

    final categoryCounts = <String, int>{};
    for (final reading in readings) {
      final category = _getCategoryText(reading.category);
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final sortedReadings = List<BloodPressureReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final dateRange =
        '${DateFormat('MMM dd, yyyy').format(sortedReadings.first.timestamp)} - ${DateFormat('MMM dd, yyyy').format(sortedReadings.last.timestamp)}';

    return '''
Blood Pressure Summary Report
Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}
Date Range: $dateRange
Total Readings: ${readings.length}

Average Values:
- Systolic: ${avgSystolic.toStringAsFixed(1)} mmHg
- Diastolic: ${avgDiastolic.toStringAsFixed(1)} mmHg
- Heart Rate: ${avgHeartRate.toStringAsFixed(1)} bpm

Category Distribution:
${categoryCounts.entries.map((entry) => '- ${entry.key}: ${entry.value} readings (${(entry.value / readings.length * 100).toStringAsFixed(1)}%)').join('\n')}
''';
  }

  /// Export summary statistics to a text file
  static Future<void> exportSummaryStats(
      List<BloodPressureReading> readings) async {
    try {
      final summary = generateSummaryStats(readings);

      final directory = Directory.systemTemp;
      final fileName =
          'bp_summary_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.txt';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(summary);

      await Share.shareXFiles(
        [XFile(file.path, name: fileName)],
        subject: 'Blood Pressure Summary Report',
        text: 'Blood pressure summary report generated from Cardio Tracker',
      );
    } catch (e) {
      throw Exception('Failed to export summary: $e');
    }
  }
}
