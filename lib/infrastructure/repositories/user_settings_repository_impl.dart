import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/value_objects/blood_pressure_category.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../../core/errors/failures.dart';
import '../data_sources/local_database_source.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final LocalDatabaseSource _dataSource;

  UserSettingsRepositoryImpl({required LocalDatabaseSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserSettings>> getSettings() async {
    try {
      final db = await _dataSource.database;
      final List<Map<String, dynamic>> maps = await db.query('user_settings');

      if (maps.isEmpty) {
        return Left(NotFoundFailure('Settings not found'));
      }

      final map = maps.first;
      final settings = UserSettings(
        id: map['id'] as String,
        name: map['name'] as String,
        age: map['age'] as int,
        gender: map['gender'] as String,
        targetMinCategory: BloodPressureCategory.values.firstWhere(
          (e) => e.toString() == 'BloodPressureCategory.${map['target_min_category']}',
          orElse: () => BloodPressureCategory.normal,
        ),
        targetMaxCategory: BloodPressureCategory.values.firstWhere(
          (e) => e.toString() == 'BloodPressureCategory.${map['target_max_category']}',
          orElse: () => BloodPressureCategory.normal,
        ),
        medicationTimes: map['medication_times'] != null
            ? List<String>.from(jsonDecode(map['medication_times'] as String))
            : [],
        reminderTimes: map['reminder_times'] != null
            ? List<String>.from(jsonDecode(map['reminder_times'] as String))
            : [],
        notificationsEnabled: (map['notifications_enabled'] as int? ?? 1) == 1,
        dataSharingEnabled: (map['data_sharing_enabled'] as int? ?? 0) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      );

      return Right(settings);
    } catch (e) {
      if (e is NotFoundFailure) {
        return Left(e);
      }
      return Left(DatabaseFailure('Failed to get settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(UserSettings settings) async {
    try {
      final db = await _dataSource.database;

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

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(bool enabled) async {
    try {
      final db = await _dataSource.database;

      await db.update(
        'user_settings',
        {
          'notifications_enabled': enabled ? 1 : 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: ['settings-1'],
      );

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update notification settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDataSharingSettings(bool enabled) async {
    try {
      final db = await _dataSource.database;

      await db.update(
        'user_settings',
        {
          'data_sharing_enabled': enabled ? 1 : 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: ['settings-1'],
      );

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update data sharing settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicationTimes(List<String> times) async {
    try {
      final db = await _dataSource.database;

      await db.update(
        'user_settings',
        {
          'medication_times': jsonEncode(times),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: ['settings-1'],
      );

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update medication times: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReminderTimes(List<String> times) async {
    try {
      final db = await _dataSource.database;

      await db.update(
        'user_settings',
        {
          'reminder_times': jsonEncode(times),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: ['settings-1'],
      );

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update reminder times: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTargetCategories(
    BloodPressureCategory minCategory,
    BloodPressureCategory maxCategory,
  ) async {
    try {
      final db = await _dataSource.database;

      await db.update(
        'user_settings',
        {
          'target_min_category': minCategory.toString().split('.').last,
          'target_max_category': maxCategory.toString().split('.').last,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: ['settings-1'],
      );

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update target categories: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetSettings() async {
    try {
      final db = await _dataSource.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final defaultSettings = {
        'name': 'User',
        'age': 30,
        'gender': 'other',
        'target_min_category': 'normal',
        'target_max_category': 'normal',
        'medication_times': jsonEncode([]),
        'reminder_times': jsonEncode([]),
        'notifications_enabled': 1,
        'data_sharing_enabled': 0,
        'updated_at': now,
      };

      await db.update(
        'user_settings',
        defaultSettings,
        where: 'id = ?',
        whereArgs: ['settings-1'],
      );

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to reset settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasSettings() async {
    try {
      final db = await _dataSource.database;
      final result = await db.query(
        'user_settings',
        limit: 1,
      );

      return Right(result.isNotEmpty);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check settings: ${e.toString()}'));
    }
  }
}