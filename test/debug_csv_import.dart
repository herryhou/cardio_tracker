import 'package:cardio_tracker/infrastructure/services/csv_import_service.dart';
import 'package:cardio_tracker/core/validators/reading_validator.dart';

void main() {
  // Test CSV content with 12 readings
  const csvContent = '''Date,Time,Systolic,Diastolic,Heart Rate,Category,Notes
2024-12-01,09:00,120,80,72,Normal,
2024-12-02,09:30,118,78,70,Normal,
2024-12-03,10:00,122,82,75,Normal,
2024-12-04,08:45,125,83,78,Normal,
2024-12-05,09:15,119,79,71,Normal,
2024-12-06,08:30,121,81,73,Normal,
2024-12-07,09:45,123,82,74,Normal,
2024-12-08,08:15,124,83,76,Normal,
2024-12-09,09:20,120,80,72,Normal,
2024-12-10,08:50,122,81,74,Normal,
2024-12-11,09:10,121,80,73,Normal,
2024-12-12,08:40,125,84,77,Normal,''';

  final importService = CsvImportService(ReadingValidator());

  importService.importFromCsv(csvContent).then((result) {
    print('Total parsed readings: ${result.readings.length}');
    print('Is valid: ${result.isValid}');
    print('Errors: ${result.errors.length}');

    if (result.errors.isNotEmpty) {
      print('\nErrors:');
      for (final error in result.errors) {
        print('  $error');
      }
    }

    if (result.readings.isNotEmpty) {
      print('\nReadings:');
      for (int i = 0; i < result.readings.length; i++) {
        final reading = result.readings[i];
        print('  ${i + 1}. ${reading.timestamp} - ${reading.systolic}/${reading.diastolic}');
      }
    }
  });
}