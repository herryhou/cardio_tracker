import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalDatabaseSource {
  Database? _database;
  bool _initialized = false;

  Future<void> initDatabase([String? path]) async {
    if (_initialized) return;

    String dbPath = path ?? await _getDatabasePath();
    _database = await openDatabase(
      dbPath,
      version: 3,  // Increment version to ensure proper migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _initialized = true;
  }

  Future<String> _getDatabasePath() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      return join(documentsDirectory.path, 'cardio_tracker.db');
    } catch (e) {
      // If we can't get documents directory, we're probably in a test
      return ':memory:';
    }
  }

  Future<Database> get database async {
    if (!_initialized) {
      await initDatabase();
    }
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blood_pressure_readings (
        id TEXT PRIMARY KEY,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        heartRate INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        lastModified TEXT NOT NULL,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migration from version 1 to 2
    if (oldVersion < 2) {
      // Check if columns already exist before adding them
      final tableInfo = await db.rawQuery("PRAGMA table_info(blood_pressure_readings)");
      final columns = <String>{};
      for (final column in tableInfo) {
        columns.add(column['name'] as String);
      }

      // Add heartRate column if it doesn't exist
      if (!columns.contains('heartRate')) {
        await db.execute('ALTER TABLE blood_pressure_readings ADD COLUMN heartRate INTEGER NOT NULL DEFAULT 0');
      }

      // Add isDeleted column if it doesn't exist
      if (!columns.contains('isDeleted')) {
        await db.execute('ALTER TABLE blood_pressure_readings ADD COLUMN isDeleted INTEGER DEFAULT 0');
      }

      // Add lastModified column if it doesn't exist
      if (!columns.contains('lastModified')) {
        final now = DateTime.now().toIso8601String();
        await db.execute('ALTER TABLE blood_pressure_readings ADD COLUMN lastModified TEXT NOT NULL DEFAULT "$now"');
        // Update existing rows to have a valid lastModified timestamp
        await db.execute('UPDATE blood_pressure_readings SET lastModified = "$now" WHERE lastModified = ""');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAllReadings() async {
    final db = await database;
    return await db.query(
      'blood_pressure_readings',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'timestamp DESC',
    );
  }

  Future<void> insertReading(Map<String, dynamic> reading) async {
    final db = await database;
    await db.insert('blood_pressure_readings', reading);
  }

  Future<void> updateReading(Map<String, dynamic> reading) async {
    final db = await database;
    await db.update(
      'blood_pressure_readings',
      reading,
      where: 'id = ?',
      whereArgs: [reading['id']],
    );
  }

  Future<void> deleteReading(String id) async {
    final db = await database;
    await db.update(
      'blood_pressure_readings',
      {'isDeleted': 1, 'lastModified': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getReadingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    return await db.query(
      'blood_pressure_readings',
      where: 'timestamp BETWEEN ? AND ? AND isDeleted = ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        0,
      ],
      orderBy: 'timestamp DESC',
    );
  }

  Future<Map<String, dynamic>?> getLatestReading() async {
    final db = await database;
    final result = await db.query(
      'blood_pressure_readings',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _initialized = false;
    }
  }
}