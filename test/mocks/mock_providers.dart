import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cardio_tracker/providers/blood_pressure_provider.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';

/// Mock BloodPressureProvider for testing
class MockBloodPressureProvider extends ChangeNotifier implements BloodPressureProvider {
  List<BloodPressureReading> _readings = [];
  bool _isLoading = false;
  String? _error;
  BloodPressureReading? _latestReading;
  List<BloodPressureReading> _recentReadings = [];

  // Note: Using dynamic since we can't extend the singleton DatabaseService
  @override
  dynamic get databaseService => MockDatabaseService();

  @override
  List<BloodPressureReading> get readings => _readings;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  BloodPressureReading? get latestReading => _latestReading;

  @override
  List<BloodPressureReading> get recentReadings => _recentReadings;

  @override
  double get averageSystolic {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.systolic).reduce((a, b) => a + b) / _readings.length;
  }

  @override
  double get averageDiastolic {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.diastolic).reduce((a, b) => a + b) / _readings.length;
  }

  @override
  double get averageHeartRate {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.heartRate).reduce((a, b) => a + b) / _readings.length;
  }

  @override
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
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

  @override
  List<BloodPressureReading> getReadingsByCategory(BloodPressureCategory category) {
    return _readings.where((r) => r.category == category).toList();
  }

  @override
  List<BloodPressureReading> getReadingsByDateRange(DateTime start, DateTime end) {
    return _readings.where((reading) {
      return reading.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
             reading.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  void refresh() {
    loadReadings();
  }

  void setMockReadings(List<BloodPressureReading> readings) {
    _readings = readings;
    _latestReading = readings.isNotEmpty ? readings.first : null;
    _recentReadings = readings.take(5).toList();
    notifyListeners();
  }

  void setMockLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setMockError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  Future<void> loadReadings() async {
    _isLoading = true;
    notifyListeners();

    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> addReading(BloodPressureReading reading) async {
    _readings.insert(0, reading);
    _latestReading = reading;
    _recentReadings = _readings.take(5).toList();
    notifyListeners();
  }

  @override
  Future<void> updateReading(BloodPressureReading reading) async {
    final index = _readings.indexWhere((r) => r.id == reading.id);
    if (index != -1) {
      _readings[index] = reading;
      if (_latestReading?.id == reading.id) {
        _latestReading = reading;
      }
      _recentReadings = _readings.take(5).toList();
      notifyListeners();
    }
  }

  @override
  Future<void> deleteReading(String id) async {
    _readings.removeWhere((r) => r.id == id);
    if (_latestReading?.id == id) {
      _latestReading = _readings.isNotEmpty ? _readings.first : null;
    }
    _recentReadings = _readings.take(5).toList();
    notifyListeners();
  }

  @override
  Future<void> deleteAllReadings() async {
    _readings.clear();
    _latestReading = null;
    _recentReadings.clear();
    notifyListeners();
  }

  @override
  Future<void> syncReadings() async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  BloodPressureReading? getReadingById(String id) {
    try {
      return _readings.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<BloodPressureReading> getReadingsForDateRange(DateTime start, DateTime end) {
    return _readings.where((reading) {
      return reading.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
             reading.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}

/// Mock DatabaseService for testing
class MockDatabaseService {
  MockDatabaseService();

  Future<void> initialize() async {
    // Mock implementation
  }

  Future<void> close() async {
    // Mock implementation
  }

  Future<String> addReading(BloodPressureReading reading) async {
    return reading.id;
  }

  Future<List<BloodPressureReading>> getAllReadings({bool includeDeleted = false}) async {
    return [];
  }

  Future<BloodPressureReading?> getReadingById(String id) async {
    return null;
  }

  Future<int> updateReading(BloodPressureReading reading) async {
    return 1;
  }

  Future<int> deleteReading(String id) async {
    return 1;
  }

  Future<int> deleteAllReadings() async {
    return 0;
  }
}