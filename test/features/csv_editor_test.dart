import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/core/errors/failures.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/infrastructure/services/csv_export_service.dart';
import 'package:cardio_tracker/infrastructure/services/csv_import_service.dart';
import 'package:cardio_tracker/core/validators/reading_validator.dart';
import 'package:cardio_tracker/presentation/providers/csv_editor_provider.dart';

import 'csv_editor_test.mocks.dart';

@GenerateMocks([
  BloodPressureRepository,
  CsvExportService,
  CsvImportService,
  ReadingValidator,
])
void main() {
  group('CSV Editor Feature Tests', () {
    late MockBloodPressureRepository mockRepository;
    late MockCsvExportService mockExportService;
    late MockCsvImportService mockImportService;
    late MockReadingValidator mockValidator;
    late CsvEditorProvider provider;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
      mockExportService = MockCsvExportService();
      mockImportService = MockCsvImportService();
      mockValidator = MockReadingValidator();
      provider = CsvEditorProvider(
        mockRepository,
        mockExportService,
        mockImportService,
      );
    });

    test('should initialize with readings from repository', () async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
          isDeleted: false,
        ),
      ];
      final csvContent = 'Date,Time,Systolic,Diastolic,Heart Rate,Category,Notes\n'
          '2024-01-15,14:30,120,80,72,Normal,';

      when(mockRepository.getAllReadings())
          .thenAnswer((_) async => Right(readings));
      when(mockExportService.exportAllReadings(readings))
          .thenReturn(csvContent);

      // Act
      await provider.initialize();

      // Assert
      expect(provider.csvContent, csvContent);
      expect(provider.readingCount, 1);
      expect(provider.status, CsvEditorStatus.idle);
      expect(provider.hasUnsavedChanges, false);
    });

    test('should validate CSV content correctly', () async {
      // Arrange
      const csvContent = 'Date,Time,Systolic,Diastolic,Heart Rate,Category,Notes\n'
          '2024-01-15,14:30,120,80,72,Normal,';
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.parse('2024-01-15 14:30:00'),
          lastModified: DateTime.now(),
          isDeleted: false,
        ),
      ];
      final importResult = CsvImportResult(
        isValid: true,
        readings: readings,
        errors: [],
      );

      when(mockImportService.importFromCsv(csvContent))
          .thenAnswer((_) async => importResult);

      // Act
      provider.updateContent(csvContent);
      final isValid = await provider.validate();

      // Assert
      expect(isValid, true);
      expect(provider.readingCount, 1);
      expect(provider.hasValidationErrors, false);
    });

    test('should save validated changes', () async {
      // Arrange
      const csvContent = 'Date,Time,Systolic,Diastolic,Heart Rate,Category,Notes\n'
          '2024-01-15,14:30,120,80,72,Normal,';
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.parse('2024-01-15 14:30:00'),
          lastModified: DateTime.now(),
          isDeleted: false,
        ),
      ];
      final importResult = CsvImportResult(
        isValid: true,
        readings: readings,
        errors: [],
      );

      when(mockImportService.importFromCsv(csvContent))
          .thenAnswer((_) async => importResult);
      when(mockRepository.replaceAllReadings(readings))
          .thenAnswer((_) async => const Right(null));

      // Act
      provider.updateContent(csvContent);
      final success = await provider.save();

      // Assert
      expect(success, true);
      expect(provider.status, CsvEditorStatus.success);
      expect(provider.hasUnsavedChanges, false);
      verify(mockRepository.replaceAllReadings(readings)).called(1);
    });

    test('should reject invalid CSV content', () async {
      // Arrange
      const csvContent = 'invalid csv content';
      final importResult = CsvImportResult(
        isValid: false,
        readings: [],
        errors: [
          LineValidationError(1, CsvImportError.invalidFormat, 'Invalid CSV format'),
        ],
      );

      when(mockImportService.importFromCsv(csvContent))
          .thenAnswer((_) async => importResult);

      // Act
      provider.updateContent(csvContent);
      final isValid = await provider.validate();

      // Assert
      expect(isValid, false);
      expect(provider.hasValidationErrors, true);
      expect(provider.validationErrors.length, 1);
    });

    test('should track unsaved changes', () {
      // Arrange
      const initialContent = 'initial csv';
      const updatedContent = 'updated csv';

      when(mockExportService.exportAllReadings(any)).thenReturn(initialContent);

      // Act
      provider.updateContent(initialContent); // Initialize
      provider.updateContent(updatedContent);

      // Assert
      expect(provider.hasUnsavedChanges, true);
      expect(provider.canSave, true);
    });

    test('should discard changes', () {
      // Arrange
      const initialContent = 'initial csv';
      const updatedContent = 'updated csv';

      when(mockExportService.exportAllReadings(any)).thenReturn(initialContent);

      provider.updateContent(initialContent);
      provider.updateContent(updatedContent);

      // Act
      provider.discardChanges();

      // Assert
      expect(provider.hasUnsavedChanges, false);
      expect(provider.csvContent, initialContent);
    });
  });
}