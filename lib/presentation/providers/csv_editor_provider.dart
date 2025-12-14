import 'package:flutter/material.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../infrastructure/services/csv_export_service.dart';
import '../../infrastructure/services/csv_import_service.dart';

enum CsvEditorStatus {
  idle,
  loading,
  validating,
  saving,
  success,
  error,
}

/// Provider for managing CSV editor state
class CsvEditorProvider with ChangeNotifier {
  final BloodPressureRepository _repository;
  final CsvExportService _exportService;
  final CsvImportService _importService;

  CsvEditorProvider(
    this._repository,
    this._exportService,
    this._importService,
  );

  // State
  CsvEditorStatus _status = CsvEditorStatus.idle;
  bool _isDisposed = false;
  String _csvContent = '';
  String _initialCsvContent = '';
  String _errorMessage = '';
  List<String> _validationErrors = [];
  int _readingCount = 0;
  bool _hasUnsavedChanges = false;

  // Getters
  CsvEditorStatus get status => _status;
  String get csvContent => _csvContent;
  String get errorMessage => _errorMessage;
  List<String> get validationErrors => _validationErrors;
  int get readingCount => _readingCount;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get canSave => _hasUnsavedChanges && _csvContent.trim().isNotEmpty;

  /// Initialize the editor with current readings
  Future<void> initialize() async {
    _setStatus(CsvEditorStatus.loading);
    _errorMessage = '';
    _validationErrors.clear();

    try {
      // Get all readings
      final result = await _repository.getAllReadings();

      result.fold(
        (failure) {
          _errorMessage = 'Failed to load readings: ${failure.message}';
          _setStatus(CsvEditorStatus.error);
        },
        (readings) {
          // Sort by timestamp for consistent export
          readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          print('[CSV Editor] Loaded ${readings.length} readings from database');
          // Export to CSV
          _csvContent = _exportService.exportAllReadings(readings);
          _initialCsvContent = _csvContent;

          // Debug: Show raw CSV with line endings visible
          print('[CSV Editor] Raw CSV with line endings:');
          print(_csvContent.replaceAll('\n', '\\n'));
          print('--- End of raw CSV ---');
          _readingCount = readings.length;
          _hasUnsavedChanges = false;
          _setStatus(CsvEditorStatus.idle);
        },
      );
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _setStatus(CsvEditorStatus.error);
    }
  }

  /// Update CSV content from editor
  void updateContent(String content) {
    if (_isDisposed) return;
    _csvContent = content;
    _hasUnsavedChanges = content != _initialCsvContent;
    _validationErrors.clear(); // Clear previous validation errors
    _errorMessage = '';

    // Debug: Log when content changes
    print('[CSV Editor] Content updated. Length: ${content.length}');
    print('First 200 chars: ${content.length > 200 ? content.substring(0, 200) + '...' : content}');

    notifyListeners();
  }

  /// Validate the current CSV content
  Future<bool> validate() async {
    if (_csvContent.trim().isEmpty) {
      _errorMessage = 'CSV content cannot be empty';
      _validationErrors = ['CSV content cannot be empty'];
      if (!_isDisposed) notifyListeners();
      return false;
    }

    // Check for common CSV formatting issues
    final lines = _csvContent.split('\n');
    print('[CSV Editor] Validating ${lines.length} lines');

    // Check for lines that look concatenated (missing line breaks)
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        final fields = line.split(',');
        if (fields.length > 7) {
          print('[CSV Editor] Warning: Line ${i + 1} has ${fields.length} fields, expected 7');
        }
      }
    }

    _setStatus(CsvEditorStatus.validating);
    _errorMessage = '';
    _validationErrors.clear();

    try {
      // Debug: print first 500 characters of CSV
      print('[CSV Editor] CSV content preview:');
      print(_csvContent.length > 500 ? _csvContent.substring(0, 500) + '...' : _csvContent);
      print('--- End of preview ---');

      final result = await _importService.importFromCsv(_csvContent);

      if (result.isValid) {
        _validationErrors.clear();
        _readingCount = result.readings.length;
        _setStatus(CsvEditorStatus.idle);
        notifyListeners();
        return true;
      } else {
        _validationErrors = result.errors.map((e) => e.toString()).toList();
        _errorMessage = 'Validation failed with ${_validationErrors.length} error(s)';
        _setStatus(CsvEditorStatus.idle);
        if (!_isDisposed) notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Validation error: $e';
      _validationErrors = ['Unexpected validation error: $e'];
      _setStatus(CsvEditorStatus.error);
      if (!_isDisposed) notifyListeners();
      return false;
    }
  }

  /// Save the validated CSV content to database
  Future<bool> save() async {
    print('[CSV Editor] Save called. Current content length: ${_csvContent.length}');
    print('[CSV Editor] Current content start: ${_csvContent.substring(0, _csvContent.length > 100 ? 100 : _csvContent.length)}');

    // First validate
    final isValid = await validate();
    if (!isValid) {
      print('[CSV Editor] Validation failed with ${_validationErrors.length} errors');
      return false;
    }

    _setStatus(CsvEditorStatus.saving);
    _errorMessage = '';

    try {
      // Parse CSV to get readings
      final result = await _importService.importFromCsv(_csvContent);

      if (!result.isValid) {
        _errorMessage = 'Validation failed during save';
        _setStatus(CsvEditorStatus.error);
        if (!_isDisposed) notifyListeners();
        return false;
      }

      // Replace all readings in database
      print('[CSV Editor] Saving ${result.readings.length} readings to database');
      for (int i = 0; i < result.readings.length; i++) {
        final reading = result.readings[i];
        print('  [${i + 1}] ${reading.timestamp} - ${reading.systolic}/${reading.diastolic}/${reading.heartRate}');
      }
      final saveResult = await _repository.replaceAllReadings(result.readings);

      saveResult.fold(
        (failure) {
          _errorMessage = 'Failed to save readings: ${failure.message}';
          _setStatus(CsvEditorStatus.error);
        },
        (_) {
          // Update state to reflect saved changes
          _initialCsvContent = _csvContent;
          _hasUnsavedChanges = false;
          _readingCount = result.readings.length;
          _setStatus(CsvEditorStatus.success);

          // Return to idle after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            // Check if not disposed before updating
            if (!_isDisposed && _status == CsvEditorStatus.success) {
              _setStatus(CsvEditorStatus.idle);
            }
          });
        },
      );

      if (!_isDisposed) notifyListeners();
      return _status == CsvEditorStatus.success;
    } catch (e) {
      _errorMessage = 'Save error: $e';
      _setStatus(CsvEditorStatus.error);
      if (!_isDisposed) notifyListeners();
      return false;
    }
  }

  /// Discard changes and reset to initial content
  void discardChanges() {
    if (_isDisposed) return;
    _csvContent = _initialCsvContent;
    _hasUnsavedChanges = false;
    _validationErrors.clear();
    _errorMessage = '';
    _setStatus(CsvEditorStatus.idle);
    notifyListeners();
  }

  /// Clear all errors
  void clearErrors() {
    if (_isDisposed) return;
    _errorMessage = '';
    _validationErrors.clear();
    notifyListeners();
  }

  /// Set status and notify listeners
  void _setStatus(CsvEditorStatus status) {
    // Don't update if disposed
    if (!_isDisposed) {
      _status = status;
      notifyListeners();
    }
  }

  /// Get formatted reading count
  String get formattedReadingCount {
    return '$_readingCount reading${_readingCount != 1 ? 's' : ''}';
  }

  /// Get status message for UI
  String get statusMessage {
    switch (_status) {
      case CsvEditorStatus.loading:
        return 'Loading readings...';
      case CsvEditorStatus.validating:
        return 'Validating CSV...';
      case CsvEditorStatus.saving:
        return 'Saving changes...';
      case CsvEditorStatus.success:
        return 'Successfully saved!';
      case CsvEditorStatus.error:
        return _errorMessage.isNotEmpty ? _errorMessage : 'An error occurred';
      case CsvEditorStatus.idle:
        if (_validationErrors.isNotEmpty) {
          return '${_validationErrors.length} validation error(s)';
        }
        if (_hasUnsavedChanges) {
          return 'You have unsaved changes';
        }
        return formattedReadingCount;
    }
  }

  /// Check if there are validation errors to show
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}