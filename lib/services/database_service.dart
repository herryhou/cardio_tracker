import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/blood_pressure_reading.dart';
import '../domain/entities/user_settings.dart';
import '../domain/value_objects/blood_pressure_category.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    // Check if we're in a testing environment
    try {
      // Try to get the documents directory (for production)
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'cardio_tracker.db');
    } catch (e) {
      // If we can't get documents directory, we're probably in a test
      // Use an in-memory database for testing
      path = ':memory:';
    }

    return await openDatabase(
      path,
      version: 2,  // Increment version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,  // Add this
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create blood_pressure_readings table
    await db.execute('''
      CREATE TABLE blood_pressure_readings (
        id TEXT PRIMARY KEY,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        heart_rate INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        notes TEXT,
        lastModified INTEGER NOT NULL,  -- NEW
        isDeleted INTEGER NOT NULL DEFAULT 0,  -- NEW (0 = false, 1 = true)
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create user_settings table
    await db.execute('''
      CREATE TABLE user_settings (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        target_min_category TEXT NOT NULL,
        target_max_category TEXT NOT NULL,
        medication_times TEXT NOT NULL,
        reminder_times TEXT NOT NULL,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        data_sharing_enabled INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  // Add migration handler
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for sync support
      await db.execute('ALTER TABLE blood_pressure_readings ADD COLUMN lastModified INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE blood_pressure_readings ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');

      // Set lastModified to timestamp for existing records
      await db.execute('UPDATE blood_pressure_readings SET lastModified = timestamp WHERE lastModified = 0');
    }
  }

  Future<void> init(String dbName) async {
    // For testing compatibility - the actual database is created in _initDatabase
    await database;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Blood Pressure Reading CRUD operations
  Future<String> insertReading(BloodPressureReading reading) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Generate unique ID if not provided
    final String id = reading.id.isEmpty ?
        DateTime.now().millisecondsSinceEpoch.toString() :
        reading.id;

    await db.insert(
      'blood_pressure_readings',
      {
        'id': id,
        'systolic': reading.systolic,
        'diastolic': reading.diastolic,
        'heart_rate': reading.heartRate,
        'timestamp': reading.timestamp.millisecondsSinceEpoch,
        'notes': reading.notes,
        'lastModified': now,
        'isDeleted': reading.isDeleted ? 1 : 0,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<BloodPressureReading?> getReading(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure_readings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return BloodPressureReading(
      id: map['id'] as String,
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      heartRate: map['heart_rate'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      notes: map['notes'] as String?,
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] as int),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }

  Future<List<BloodPressureReading>> getAllReadings({bool includeDeleted = false}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure_readings',
      where: includeDeleted ? null : 'isDeleted = ?',
      whereArgs: includeDeleted ? null : [0],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return BloodPressureReading(
        id: map['id'] as String,
        systolic: map['systolic'] as int,
        diastolic: map['diastolic'] as int,
        heartRate: map['heart_rate'] as int,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        notes: map['notes'] as String?,
        lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] as int),
        isDeleted: map['isDeleted'] == 1,
      );
    });
  }

  Future<List<BloodPressureReading>> getReadingsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'blood_pressure_readings',
      where: 'timestamp >= ? AND timestamp <= ? AND isDeleted = 0',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return BloodPressureReading(
        id: map['id'] as String,
        systolic: map['systolic'] as int,
        diastolic: map['diastolic'] as int,
        heartRate: map['heart_rate'] as int,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        notes: map['notes'] as String?,
        lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] as int),
        isDeleted: (map['isDeleted'] as int) == 1,
      );
    });
  }

  Future<void> updateReading(BloodPressureReading reading) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Get current reading to check if isDeleted changed
    final currentReading = await getReading(reading.id);
    if (currentReading == null) {
      throw Exception('Reading not found');
    }

    final isDeletedChanged = currentReading.isDeleted != reading.isDeleted;

    await db.update(
      'blood_pressure_readings',
      {
        'systolic': reading.systolic,
        'diastolic': reading.diastolic,
        'heart_rate': reading.heartRate,
        'timestamp': reading.timestamp.millisecondsSinceEpoch,
        'notes': reading.notes,
        'lastModified': isDeletedChanged ? now : reading.lastModified.millisecondsSinceEpoch,
        'isDeleted': reading.isDeleted ? 1 : 0,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [reading.id],
    );
  }

  Future<void> deleteReading(String id) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'blood_pressure_readings',
      {
        'isDeleted': 1,
        'lastModified': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User Settings operations
  Future<void> insertUserSettings(UserSettings settings) async {
    final db = await database;

    await db.insert(
      'user_settings',
      {
        'id': settings.id,
        'name': settings.name,
        'age': settings.age,
        'gender': settings.gender,
        'target_min_category': settings.targetMinCategory.toString().split('.').last,
        'target_max_category': settings.targetMaxCategory.toString().split('.').last,
        'medication_times': jsonEncode(settings.medicationTimes),
        'reminder_times': jsonEncode(settings.reminderTimes),
        'notifications_enabled': settings.notificationsEnabled ? 1 : 0,
        'data_sharing_enabled': settings.dataSharingEnabled ? 1 : 0,
        'created_at': settings.createdAt.millisecondsSinceEpoch,
        'updated_at': settings.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserSettings?> getUserSettings() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('user_settings');

    if (maps.isEmpty) return null;

    final map = maps.first;
    return UserSettings(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      targetMinCategory: BloodPressureCategory.values.firstWhere(
        (e) => e.toString() == 'BloodPressureCategory.${map['target_min_category']}',
      ),
      targetMaxCategory: BloodPressureCategory.values.firstWhere(
        (e) => e.toString() == 'BloodPressureCategory.${map['target_max_category']}',
      ),
      medicationTimes: List<String>.from(jsonDecode(map['medication_times'] as String)),
      reminderTimes: List<String>.from(jsonDecode(map['reminder_times'] as String)),
      notificationsEnabled: (map['notifications_enabled'] as int) == 1,
      dataSharingEnabled: (map['data_sharing_enabled'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    final db = await database;

    await db.update(
      'user_settings',
      {
        'name': settings.name,
        'age': settings.age,
        'gender': settings.gender,
        'target_min_category': settings.targetMinCategory.toString().split('.').last,
        'target_max_category': settings.targetMaxCategory.toString().split('.').last,
        'medication_times': jsonEncode(settings.medicationTimes),
        'reminder_times': jsonEncode(settings.reminderTimes),
        'notifications_enabled': settings.notificationsEnabled ? 1 : 0,
        'data_sharing_enabled': settings.dataSharingEnabled ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }
}