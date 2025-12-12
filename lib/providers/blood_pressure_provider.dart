import 'package:flutter/foundation.dart';
import '../models/blood_pressure_reading.dart';
import '../services/database_service.dart';

class BloodPressureProvider extends ChangeNotifier {
  final DatabaseService databaseService;
  List<BloodPressureReading> _readings = [];
  bool _isLoading = false;
  String? _error;

  BloodPressureProvider({required this.databaseService}) {
    loadReadings();
  }

  // Getters
  List<BloodPressureReading> get readings => List.unmodifiable(_readings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  double get averageSystolic {
    if (_readings.isEmpty) return 0.0;
    return _readings
        .map((r) => r.systolic)
        .reduce((a, b) => a + b) / _readings.length;
  }

  double get averageDiastolic {
    if (_readings.isEmpty) return 0.0;
    return _readings
        .map((r) => r.diastolic)
        .reduce((a, b) => a + b) / _readings.length;
  }

  double get averageHeartRate {
    if (_readings.isEmpty) return 0.0;
    return _readings
        .map((r) => r.heartRate)
        .reduce((a, b) => a + b) / _readings.length;
  }

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

  // CRUD operations
  Future<void> loadReadings() async {
    _setLoading(true);
    _clearError();

    try {
      _readings = await databaseService.getAllReadings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load readings: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addReading(BloodPressureReading reading) async {
    _setLoading(true);
    _clearError();

    try {
      // Insert reading and get generated ID
      final String generatedId = await databaseService.insertReading(reading);

      // Create new reading with generated ID
      final newReading = BloodPressureReading(
        id: generatedId,
        systolic: reading.systolic,
        diastolic: reading.diastolic,
        heartRate: reading.heartRate,
        timestamp: reading.timestamp,
        notes: reading.notes,
        lastModified: DateTime.now(),
      );

      _readings.insert(0, newReading); // Insert at beginning
      _readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      _setError('Failed to add reading: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReading(BloodPressureReading reading) async {
    _setLoading(true);
    _clearError();

    try {
      await databaseService.updateReading(reading);

      final index = _readings.indexWhere((r) => r.id == reading.id);
      if (index != -1) {
        _readings[index] = reading;
        _readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update reading: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReading(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await databaseService.deleteReading(id);
      _readings.removeWhere((reading) => reading.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete reading: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Utility methods
  List<BloodPressureReading> getReadingsByDateRange(DateTime start, DateTime end) {
    return _readings
        .where((reading) =>
            reading.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
            reading.timestamp.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<BloodPressureReading> getReadingsByCategory(BloodPressureCategory category) {
    return _readings
        .where((reading) => reading.category == category)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Map<BloodPressureCategory, int> getCategoryCounts() {
    final counts = <BloodPressureCategory, int>{};

    for (final category in BloodPressureCategory.values) {
      counts[category] = 0;
    }

    for (final reading in _readings) {
      counts[reading.category] = (counts[reading.category] ?? 0) + 1;
    }

    return counts;
  }

  void refresh() {
    loadReadings();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Private helper methods
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
  }

}