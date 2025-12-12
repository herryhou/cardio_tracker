import 'package:flutter/foundation.dart';
import 'package:cardio_tracker/providers/blood_pressure_provider.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';
import 'package:cardio_tracker/services/database_service.dart';

class MockBloodPressureProvider extends ChangeNotifier implements BloodPressureProvider {
  // Implement all the required properties and methods from BloodPressureProvider

  @override
  List<BloodPressureReading> get readings => [];

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  double get averageSystolic => 0.0;

  @override
  double get averageDiastolic => 0.0;

  @override
  double get averageHeartRate => 0.0;

  @override
  BloodPressureReading? get latestReading => null;

  @override
  List<BloodPressureReading> get recentReadings => [];

  @override
  DatabaseService get databaseService => MockDatabaseService();

  @override
  Future<void> loadReadings() async {
    // Mock implementation
  }

  @override
  Future<void> addReading(BloodPressureReading reading) async {
    // Mock implementation
  }

  @override
  Future<void> updateReading(BloodPressureReading reading) async {
    // Mock implementation
  }

  @override
  Future<void> deleteReading(String id) async {
    // Mock implementation
  }

  @override
  Future<void> clearAllReadings() async {
    // Mock implementation
  }

  @override
  void clearError() {
    // Mock implementation
  }
}

class MockDatabaseService implements DatabaseService {
  @override
  Future<List<BloodPressureReading>> getAllReadings() async => [];

  @override
  Future<void> saveReading(BloodPressureReading reading) async {}

  @override
  Future<void> updateReading(BloodPressureReading reading) async {}

  @override
  Future<void> deleteReading(String id) async {}

  @override
  Future<void> clearAllReadings() async {}
}