import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseSource {
  Database? _database;

  Future<void> initDatabase(String path) async {
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE blood_pressure_readings ADD COLUMN isDeleted INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE blood_pressure_readings ADD COLUMN lastModified TEXT NOT NULL DEFAULT ""');
    }
  }

  Future<List<Map<String, dynamic>>> getAllReadings() async {
    final db = _database!;
    return await db.query(
      'blood_pressure_readings',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'timestamp DESC',
    );
  }

  Future<void> insertReading(Map<String, dynamic> reading) async {
    final db = _database!;
    await db.insert('blood_pressure_readings', reading);
  }

  Future<void> updateReading(Map<String, dynamic> reading) async {
    final db = _database!;
    await db.update(
      'blood_pressure_readings',
      reading,
      where: 'id = ?',
      whereArgs: [reading['id']],
    );
  }

  Future<void> deleteReading(String id) async {
    final db = _database!;
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
    final db = _database!;
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
    final db = _database!;
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
    await _database?.close();
  }
}