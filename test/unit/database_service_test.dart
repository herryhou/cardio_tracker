import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../lib/models/blood_pressure_reading.dart';
import '../../lib/models/user_settings.dart';
import '../../lib/models/sync_status.dart';
import '../../lib/services/database_service.dart';

void main() {
  // Initialize Flutter test bindings
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize ffi loader
    sqfliteFfiInit();
    // Set global factory
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseService Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      databaseService = DatabaseService.instance;
      await databaseService.init('test_db.db');
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('should insert and retrieve a blood pressure reading', () async {
      final reading = BloodPressureReading(
        id: 'test-1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        notes: 'Test reading',
      );

      await databaseService.insertReading(reading);

      final retrieved = await databaseService.getReading('test-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.systolic, equals(120));
      expect(retrieved.diastolic, equals(80));
      expect(retrieved.heartRate, equals(72));
      expect(retrieved.notes, equals('Test reading'));
    });

    test('should get all blood pressure readings', () async {
      final reading1 = BloodPressureReading(
        id: 'test-2',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      );

      final reading2 = BloodPressureReading(
        id: 'test-3',
        systolic: 130,
        diastolic: 85,
        heartRate: 75,
        timestamp: DateTime.now(),
      );

      await databaseService.insertReading(reading1);
      await databaseService.insertReading(reading2);

      final allReadings = await databaseService.getAllReadings();
      expect(allReadings.length, equals(2));

      // Should be sorted by timestamp descending
      expect(allReadings.first.id, equals('test-3'));
      expect(allReadings.last.id, equals('test-2'));
    });

    test('should get readings by date range', () async {
      final baseDate = DateTime(2024, 1, 15);

      final reading1 = BloodPressureReading(
        id: 'test-4',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: baseDate,
      );

      final reading2 = BloodPressureReading(
        id: 'test-5',
        systolic: 130,
        diastolic: 85,
        heartRate: 75,
        timestamp: baseDate.add(Duration(days: 2)),
      );

      final reading3 = BloodPressureReading(
        id: 'test-6',
        systolic: 125,
        diastolic: 82,
        heartRate: 74,
        timestamp: baseDate.add(Duration(days: 5)),
      );

      await databaseService.insertReading(reading1);
      await databaseService.insertReading(reading2);
      await databaseService.insertReading(reading3);

      final startDate = baseDate.add(Duration(days: 1));
      final endDate = baseDate.add(Duration(days: 3));

      final readingsInRange = await databaseService.getReadingsByDateRange(startDate, endDate);
      expect(readingsInRange.length, equals(1));
      expect(readingsInRange.first.id, equals('test-5'));
    });

    test('should update a reading', () async {
      final reading = BloodPressureReading(
        id: 'test-7',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        notes: 'Original notes',
      );

      await databaseService.insertReading(reading);

      final updatedReading = reading.copyWith(
        systolic: 125,
        diastolic: 82,
        notes: 'Updated notes',
      );

      await databaseService.updateReading(updatedReading);

      final retrieved = await databaseService.getReading('test-7');
      expect(retrieved, isNotNull);
      expect(retrieved!.systolic, equals(125));
      expect(retrieved.diastolic, equals(82));
      expect(retrieved.notes, equals('Updated notes'));
    });

    test('should delete a reading', () async {
      final reading = BloodPressureReading(
        id: 'test-8',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
      );

      await databaseService.insertReading(reading);

      // Verify it exists
      var retrieved = await databaseService.getReading('test-8');
      expect(retrieved, isNotNull);

      // Delete it
      await databaseService.deleteReading('test-8');

      // Verify it's gone
      retrieved = await databaseService.getReading('test-8');
      expect(retrieved, isNull);
    });

    test('should insert and retrieve user settings', () async {
      final settings = UserSettings(
        id: 'settings-1',
        name: 'Test User',
        age: 30,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00', '21:00'],
        notificationsEnabled: true,
        dataSharingEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await databaseService.insertUserSettings(settings);

      final retrieved = await databaseService.getUserSettings();
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test User'));
      expect(retrieved.age, equals(30));
      expect(retrieved.gender, equals('male'));
      expect(retrieved.notificationsEnabled, isTrue);
      expect(retrieved.dataSharingEnabled, isFalse);
    });

    test('should update user settings', () async {
      final settings = UserSettings(
        id: 'settings-2',
        name: 'Test User',
        age: 30,
        gender: 'male',
        targetMinCategory: BloodPressureCategory.normal,
        targetMaxCategory: BloodPressureCategory.normal,
        medicationTimes: ['08:00'],
        reminderTimes: ['09:00'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await databaseService.insertUserSettings(settings);

      final updatedSettings = settings.copyWith(
        age: 31,
        medicationTimes: ['08:00', '20:00'],
        reminderTimes: ['09:00', '21:00'],
        notificationsEnabled: false,
        updatedAt: DateTime.now().add(Duration(seconds: 1)),
      );

      await databaseService.updateUserSettings(updatedSettings);

      final retrieved = await databaseService.getUserSettings();
      expect(retrieved, isNotNull);
      expect(retrieved!.age, equals(31));
      expect(retrieved.medicationTimes.length, equals(2));
      expect(retrieved.notificationsEnabled, isFalse);
    });

    test('should insert and retrieve sync status', () async {
      final syncStatus = SyncStatus(
        id: 'sync-1',
        lastSyncState: SyncState.success,
        lastSyncTime: DateTime.now(),
        pendingReadingsCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await databaseService.insertSyncStatus(syncStatus);

      final retrieved = await databaseService.getSyncStatus();
      expect(retrieved, isNotNull);
      expect(retrieved!.lastSyncState, equals(SyncState.success));
      expect(retrieved.pendingReadingsCount, equals(0));
      expect(retrieved.needsSync, isFalse);
    });

    test('should update sync status', () async {
      final syncStatus = SyncStatus(
        id: 'sync-2',
        lastSyncState: SyncState.idle,
        pendingReadingsCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await databaseService.insertSyncStatus(syncStatus);

      final updatedStatus = syncStatus.copyWith(
        lastSyncState: SyncState.success,
        lastSyncTime: DateTime.now(),
        pendingReadingsCount: 0,
        updatedAt: DateTime.now().add(Duration(seconds: 1)),
      );

      await databaseService.updateSyncStatus(updatedStatus);

      final retrieved = await databaseService.getSyncStatus();
      expect(retrieved, isNotNull);
      expect(retrieved!.lastSyncState, equals(SyncState.success));
      expect(retrieved.pendingReadingsCount, equals(0));
      expect(retrieved.needsSync, isFalse);
    });
  });
}