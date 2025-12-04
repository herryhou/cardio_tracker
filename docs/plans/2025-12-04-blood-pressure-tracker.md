# Blood Pressure Tracker Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Flutter app for tracking blood pressure and heart rate with Google Sheets two-way sync, scatter plot visualization, and modern Material Design 3 UI.

**Architecture:** Clean MVVM pattern with Provider state management, SQLite local storage, Google Sheets API integration, and fl_chart for data visualization.

**Tech Stack:** Flutter 3.x, Provider 6.x, sqflite 2.x, google_sheets_api, fl_chart, path_provider, intl, csv, google_sign_in

---

### Task 1: Project Setup and Dependencies

**Files:**
- Create: `pubspec.yaml`
- Create: `android/app/src/main/AndroidManifest.xml`
- Create: `ios/Runner/Info.plist`
- Create: `lib/`
- Create: `assets/`

**Step 1: Create pubspec.yaml with all dependencies**

```yaml
name: blood_pressure_tracker
description: Personal blood pressure and heart rate tracking app
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
  intl: ^0.19.0
  fl_chart: ^0.66.2
  google_sign_in: ^6.1.6
  googleapis: ^12.0.0
  googleapis_auth: ^1.5.1
  csv: ^6.0.0
  share_plus: ^7.2.1
  file_picker: ^6.1.1
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

**Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: SUCCESS - all dependencies downloaded

**Step 3: Create basic app structure**

```bash
mkdir -p lib/{models,screens,providers,services,utils,widgets}
mkdir -p test/{unit,widget,integration}
```

**Step 4: Commit**

```bash
git add pubspec.yaml android/ ios/ lib/ test/
git commit -m "feat: initial project setup with dependencies"
```

### Task 2: Data Models

**Files:**
- Create: `lib/models/blood_pressure_reading.dart`
- Create: `lib/models/user_settings.dart`
- Create: `lib/models/sync_status.dart`
- Test: `test/unit/models_test.dart`

**Step 1: Write failing test for BloodPressureReading model**

```dart
// test/unit/models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:blood_pressure_tracker/models/blood_pressure_reading.dart';

void main() {
  group('BloodPressureReading', () {
    test('should create reading from JSON', () {
      final json = {
        'id': 1,
        'systolic': 120,
        'diastolic': 80,
        'heartRate': 72,
        'timestamp': '2024-01-01T10:00:00Z',
        'notes': 'Morning reading',
      };

      final reading = BloodPressureReading.fromJson(json);

      expect(reading.systolic, 120);
      expect(reading.diastolic, 80);
      expect(reading.heartRate, 72);
      expect(reading.notes, 'Morning reading');
    });

    test('should convert to JSON', () {
      final reading = BloodPressureReading(
        id: 1,
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.parse('2024-01-01T10:00:00Z'),
        notes: 'Morning reading',
      );

      final json = reading.toJson();

      expect(json['systolic'], 120);
      expect(json['diastolic'], 80);
      expect(json['heartRate'], 72);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/unit/models_test.dart`
Expected: FAIL - "BloodPressureReading not found"

**Step 3: Implement BloodPressureReading model**

```dart
// lib/models/blood_pressure_reading.dart
class BloodPressureReading {
  final int? id;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final DateTime timestamp;
  final String? notes;

  BloodPressureReading({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.timestamp,
    this.notes,
  });

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) {
    return BloodPressureReading(
      id: json['id'] as int?,
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      heartRate: json['heartRate'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  BloodPressureCategory get category {
    if (systolic < 120 && diastolic < 80) {
      return BloodPressureCategory.normal;
    } else if (systolic < 130 && diastolic < 80) {
      return BloodPressureCategory.elevated;
    } else if (systolic < 140 || diastolic < 90) {
      return BloodPressureCategory.stage1;
    } else {
      return BloodPressureCategory.stage2;
    }
  }
}

enum BloodPressureCategory {
  normal,
  elevated,
  stage1,
  stage2;
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/unit/models_test.dart`
Expected: PASS

**Step 5: Add UserSettings and SyncStatus models**

```dart
// lib/models/user_settings.dart
class UserSettings {
  final bool darkMode;
  final bool autoSync;
  final String googleSheetsId;
  final String googleSheetsRange;

  UserSettings({
    this.darkMode = false,
    this.autoSync = true,
    this.googleSheetsId = '',
    this.googleSheetsRange = 'Sheet1!A:G',
  });

  UserSettings copyWith({
    bool? darkMode,
    bool? autoSync,
    String? googleSheetsId,
    String? googleSheetsRange,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      autoSync: autoSync ?? this.autoSync,
      googleSheetsId: googleSheetsId ?? this.googleSheetsId,
      googleSheetsRange: googleSheetsRange ?? this.googleSheetsRange,
    );
  }
}

// lib/models/sync_status.dart
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncState {
  final SyncStatus status;
  final String? message;
  final DateTime? lastSyncTime;

  SyncState({
    required this.status,
    this.message,
    this.lastSyncTime,
  });
}
```

**Step 6: Commit**

```bash
git add lib/models/ test/unit/models_test.dart
git commit -m "feat: implement data models with tests"
```

### Task 3: Local Database Service

**Files:**
- Create: `lib/services/database_service.dart`
- Test: `test/unit/database_service_test.dart`

**Step 1: Write failing test for database service**

```dart
// test/unit/database_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:blood_pressure_tracker/services/database_service.dart';
import 'package:blood_pressure_tracker/models/blood_pressure_reading.dart';

void main() {
  late DatabaseService databaseService;

  setUpAll(() {
    // Initialize ffi loader for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    databaseService = DatabaseService.instance;
  });

  tearDown(() async {
    await databaseService.database.then((db) => db.close());
  });

  group('DatabaseService', () {
    test('should insert and retrieve blood pressure reading', () async {
      final reading = BloodPressureReading(
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        notes: 'Test reading',
      );

      final id = await databaseService.insertReading(reading);
      expect(id, isNotNull);

      final retrieved = await databaseService.getReading(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.systolic, 120);
      expect(retrieved.diastolic, 80);
    });

    test('should get all readings', () async {
      final readings = await databaseService.getAllReadings();
      expect(readings, isA<List<BloodPressureReading>>());
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/unit/database_service_test.dart`
Expected: FAIL - "DatabaseService not found"

**Step 3: Implement DatabaseService**

```dart
// lib/services/database_service.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/blood_pressure_reading.dart';

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
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'blood_pressure_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blood_pressure_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        heart_rate INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        google_sheets_row_id INTEGER,
        last_modified TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        dark_mode INTEGER DEFAULT 0,
        auto_sync INTEGER DEFAULT 1,
        google_sheets_id TEXT,
        google_sheets_range TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_status (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        last_sync_time TEXT,
        sync_status TEXT,
        sync_message TEXT
      )
    ''');
  }

  Future<int> insertReading(BloodPressureReading reading) async {
    final db = await database;
    return await db.insert(
      'blood_pressure_readings',
      {
        'systolic': reading.systolic,
        'diastolic': reading.diastolic,
        'heart_rate': reading.heartRate,
        'timestamp': reading.timestamp.toIso8601String(),
        'notes': reading.notes,
        'last_modified': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BloodPressureReading?> getReading(int id) async {
    final db = await database;
    final maps = await db.query(
      'blood_pressure_readings',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BloodPressureReading.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BloodPressureReading>> getAllReadings() async {
    final db = await database;
    final maps = await db.query(
      'blood_pressure_readings',
      where: 'is_deleted = 0',
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => BloodPressureReading.fromJson(map)).toList();
  }

  Future<List<BloodPressureReading>> getReadingsByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'blood_pressure_readings',
      where: 'timestamp BETWEEN ? AND ? AND is_deleted = 0',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => BloodPressureReading.fromJson(map)).toList();
  }

  Future<int> updateReading(BloodPressureReading reading) async {
    final db = await database;
    return await db.update(
      'blood_pressure_readings',
      {
        'systolic': reading.systolic,
        'diastolic': reading.diastolic,
        'heart_rate': reading.heartRate,
        'timestamp': reading.timestamp.toIso8601String(),
        'notes': reading.notes,
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [reading.id],
    );
  }

  Future<int> deleteReading(int id) async {
    final db = await database;
    return await db.update(
      'blood_pressure_readings',
      {'is_deleted': 1, 'last_modified': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/unit/database_service_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/services/database_service.dart test/unit/database_service_test.dart
git commit -m "feat: implement local database service with tests"
```

### Task 4: Google Sheets Integration Service

**Files:**
- Create: `lib/services/google_sheets_service.dart`
- Test: `test/unit/google_sheets_service_test.dart`
- Create: `assets/google-credentials.json`

**Step 1: Set up Google Sheets API configuration**

Create `google-credentials.json` with placeholder structure (user will need to replace with actual credentials):

```json
{
  "installed": {
    "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
    "client_secret": "YOUR_CLIENT_SECRET",
    "redirect_uris": ["http://localhost"],
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token"
  }
}
```

**Step 2: Write failing test for Google Sheets service**

```dart
// test/unit/google_sheets_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:blood_pressure_tracker/services/google_sheets_service.dart';
import 'package:blood_pressure_tracker/models/blood_pressure_reading.dart';

void main() {
  group('GoogleSheetsService', () {
    test('should convert reading to row values', () {
      final service = GoogleSheetsService();
      final reading = BloodPressureReading(
        id: 1,
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.parse('2024-01-01T10:00:00Z'),
        notes: 'Test reading',
      );

      final row = service.readingToRow(reading);

      expect(row[0], equals('1'));
      expect(row[1], equals('2024-01-01T10:00:00.000Z'));
      expect(row[2], equals('120'));
      expect(row[3], equals('80'));
      expect(row[4], equals('72'));
      expect(row[5], equals('Test reading'));
    });

    test('should convert row to reading', () {
      final service = GoogleSheetsService();
      final row = [
        '1',
        '2024-01-01T10:00:00.000Z',
        '120',
        '80',
        '72',
        'Test reading',
        '2024-01-01T10:00:00.000Z'
      ];

      final reading = service.rowToReading(row);

      expect(reading, isNotNull);
      expect(reading!.id, equals(1));
      expect(reading.systolic, equals(120));
      expect(reading.diastolic, equals(80));
      expect(reading.heartRate, equals(72));
      expect(reading.notes, equals('Test reading'));
    });
  });
}
```

**Step 3: Run test to verify it fails**

Run: `flutter test test/unit/google_sheets_service_test.dart`
Expected: FAIL - "GoogleSheetsService not found"

**Step 4: Implement GoogleSheetsService**

```dart
// lib/services/google_sheets_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import '../models/blood_pressure_reading.dart';

class GoogleSheetsService {
  static const _storage = FlutterSecureStorage();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/spreadsheets'],
  );

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
      final authHeaders = await _googleSignIn.currentUser?.authHeaders;
      if (authHeaders != null) {
        await _storage.write(key: 'google_auth_token', value: authHeaders['Authorization']);
      }
    } catch (e) {
      throw Exception('Failed to sign in to Google: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'google_auth_token');
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<sheets.SheetsApi> _getSheetsApi() async {
    final authToken = await _storage.read(key: 'google_auth_token');
    if (authToken == null) {
      throw Exception('Not authenticated with Google');
    }

    final client = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', authToken.substring(7), DateTime.now().add(const Duration(days: 1))),
        null,
        ['https://www.googleapis.com/auth/spreadsheets'],
      ),
    );

    return sheets.SheetsApi(client);
  }

  Future<List<List<String>>> readSheet(String spreadsheetId, String range) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final result = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);

      return result.values?.map((row) => row.map((cell) => cell.toString()).toList()).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to read from Google Sheets: $e');
    }
  }

  Future<void> writeRow(String spreadsheetId, String range, List<String> values) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final valueRange = sheets.ValueRange(
        values: [values],
      );

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw Exception('Failed to write to Google Sheets: $e');
    }
  }

  Future<void> updateRow(String spreadsheetId, String range, List<String> values) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final valueRange = sheets.ValueRange(
        values: [values],
      );

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      throw Exception('Failed to update Google Sheets: $e');
    }
  }

  List<String> readingToRow(BloodPressureReading reading) {
    return [
      reading.id?.toString() ?? '',
      reading.timestamp.toIso8601String(),
      reading.systolic.toString(),
      reading.diastolic.toString(),
      reading.heartRate.toString(),
      reading.notes ?? '',
      DateTime.now().toIso8601String(), // last modified
    ];
  }

  BloodPressureReading? rowToReading(List<String> row) {
    if (row.length < 6 || row[0].isEmpty) return null;

    try {
      return BloodPressureReading(
        id: int.tryParse(row[0]),
        timestamp: DateTime.parse(row[1]),
        systolic: int.parse(row[2]),
        diastolic: int.parse(row[3]),
        heartRate: int.parse(row[4]),
        notes: row[5].isEmpty ? null : row[5],
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> createSpreadsheetWithTitle(String title) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final spreadsheet = sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(
          title: title,
        ),
        sheets: [
          sheets.Sheet(
            properties: sheets.SheetProperties(
              title: 'Blood Pressure Readings',
            ),
            data: [
              sheets.GridData(
                rowData: [
                  sheets.RowData(
                    values: [
                      sheets.CellData(
                        userEnteredValue: sheets.ExtendedValue(stringValue: 'ID'),
                      ),
                      sheets.CellData(
                        userEnteredValue: sheets.ExtendedValue(stringValue: 'Timestamp'),
                      ),
                      sheets.CellData(
                        userEnteredValue: sheets.ExtendedValue(stringValue: 'Systolic'),
                      ),
                      sheets.CellData(
                        userEnteredValue: sheets.ExtendedValue(stringValue: 'Diastolic'),
                      ),
                      sheets.CellData(
                        userEnteredValue: sheets.ExtendedValue(stringValue: 'Heart Rate'),
                      ),
                      sheets.CellData(
                        userEnteredValue: sheets.ExtendedValue(stringValue: 'Notes'),
                      ),
                      sheets.CellData(
                        userEnteredValue: sheets.ExtendedValue(stringValue: 'Last Modified'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await sheetsApi.spreadsheets.create(spreadsheet);
    } catch (e) {
      throw Exception('Failed to create spreadsheet: $e');
    }
  }
}
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/unit/google_sheets_service_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/services/google_sheets_service.dart test/unit/google_sheets_service_test.dart assets/google-credentials.json
git commit -m "feat: implement Google Sheets integration service with tests"
```

### Task 5: State Management with Provider

**Files:**
- Create: `lib/providers/blood_pressure_provider.dart`
- Create: `lib/providers/sync_provider.dart`
- Create: `lib/providers/settings_provider.dart`
- Test: `test/unit/providers_test.dart`

**Step 1: Write failing test for blood pressure provider**

```dart
// test/unit/providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blood_pressure_tracker/providers/blood_pressure_provider.dart';
import 'package:blood_pressure_tracker/models/blood_pressure_reading.dart';
import 'package:blood_pressure_tracker/services/database_service.dart';

import 'providers_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  group('BloodPressureProvider', () {
    late BloodPressureProvider provider;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      provider = BloodPressureProvider(databaseService: mockDatabaseService);
    });

    test('should add new reading', () async {
      final reading = BloodPressureReading(
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
      );

      when(mockDatabaseService.insertReading(reading))
          .thenAnswer((_) async => 1);

      await provider.addReading(reading);

      verify(mockDatabaseService.insertReading(reading)).called(1);
      expect(provider.readings.length, 1);
      expect(provider.readings.first.systolic, 120);
    });

    test('should load readings from database', () async {
      final readings = [
        BloodPressureReading(
          id: 1,
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockDatabaseService.getAllReadings())
          .thenAnswer((_) async => readings);

      await provider.loadReadings();

      verify(mockDatabaseService.getAllReadings()).called(1);
      expect(provider.readings.length, 1);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/unit/providers_test.dart`
Expected: FAIL - "BloodPressureProvider not found"

**Step 3: Implement BloodPressureProvider**

```dart
// lib/providers/blood_pressure_provider.dart
import 'package:flutter/foundation.dart';
import 'package:blood_pressure_tracker/models/blood_pressure_reading.dart';
import 'package:blood_pressure_tracker/services/database_service.dart';

class BloodPressureProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  List<BloodPressureReading> _readings = [];
  bool _isLoading = false;
  String? _error;

  BloodPressureProvider({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  List<BloodPressureReading> get readings => List.unmodifiable(_readings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BloodPressureReading> getReadingsForDateRange(DateTime start, DateTime end) {
    return _readings.where((reading) {
      return reading.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
             reading.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  BloodPressureReading? getLatestReading() {
    if (_readings.isEmpty) return null;
    return _readings.first;
  }

  double getAverageSystolic() {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.systolic).reduce((a, b) => a + b) / _readings.length;
  }

  double getAverageDiastolic() {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.diastolic).reduce((a, b) => a + b) / _readings.length;
  }

  double getAverageHeartRate() {
    if (_readings.isEmpty) return 0;
    return _readings.map((r) => r.heartRate).reduce((a, b) => a + b) / _readings.length;
  }

  Future<void> loadReadings() async {
    try {
      _setLoading(true);
      _error = null;
      _readings = await _databaseService.getAllReadings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load readings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addReading(BloodPressureReading reading) async {
    try {
      _setLoading(true);
      _error = null;

      final id = await _databaseService.insertReading(reading);
      final newReading = BloodPressureReading(
        id: id,
        systolic: reading.systolic,
        diastolic: reading.diastolic,
        heartRate: reading.heartRate,
        timestamp: reading.timestamp,
        notes: reading.notes,
      );

      _readings.insert(0, newReading);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add reading: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReading(BloodPressureReading reading) async {
    try {
      _setLoading(true);
      _error = null;

      await _databaseService.updateReading(reading);

      final index = _readings.indexWhere((r) => r.id == reading.id);
      if (index != -1) {
        _readings[index] = reading;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update reading: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReading(int id) async {
    try {
      _setLoading(true);
      _error = null;

      await _databaseService.deleteReading(id);
      _readings.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete reading: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<List<BloodPressureReading>> getReadingsForDateRange(
      DateTime start, DateTime end) async {
    try {
      return await _databaseService.getReadingsByDateRange(start, end);
    } catch (e) {
      _setError('Failed to get readings for date range: $e');
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

**Step 4: Implement SyncProvider and SettingsProvider**

```dart
// lib/providers/sync_provider.dart
import 'package:flutter/foundation.dart';
import 'package:blood_pressure_tracker/models/sync_status.dart';
import 'package:blood_pressure_tracker/services/google_sheets_service.dart';
import 'package:blood_pressure_tracker/services/database_service.dart';
import 'package:blood_pressure_tracker/providers/blood_pressure_provider.dart';

class SyncProvider extends ChangeNotifier {
  final GoogleSheetsService _googleSheetsService;
  final DatabaseService _databaseService;
  final BloodPressureProvider _bloodPressureProvider;

  SyncState _syncState = SyncState(status: SyncStatus.idle);

  SyncProvider({
    GoogleSheetsService? googleSheetsService,
    DatabaseService? databaseService,
    required BloodPressureProvider bloodPressureProvider,
  })  : _googleSheetsService = googleSheetsService ?? GoogleSheetsService(),
        _databaseService = databaseService ?? DatabaseService.instance,
        _bloodPressureProvider = bloodPressureProvider;

  SyncState get syncState => _syncState;
  bool get isSignedIn => _googleSheetsService.isSignedIn();

  Future<void> signIn() async {
    try {
      _setSyncState(SyncState(status: SyncStatus.syncing, message: 'Signing in...'));
      await _googleSheetsService.signIn();
      _setSyncState(SyncState(status: SyncStatus.success, message: 'Successfully signed in'));
    } catch (e) {
      _setSyncState(SyncState(status: SyncStatus.error, message: 'Sign in failed: $e'));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSheetsService.signOut();
      _setSyncState(SyncState(status: SyncStatus.idle));
    } catch (e) {
      _setSyncState(SyncState(status: SyncStatus.error, message: 'Sign out failed: $e'));
    }
  }

  Future<void> syncToGoogleSheets(String spreadsheetId, String range) async {
    try {
      _setSyncState(SyncState(status: SyncStatus.syncing, message: 'Syncing to Google Sheets...'));

      final readings = _bloodPressureProvider.readings;

      for (int i = 0; i < readings.length; i++) {
        final reading = readings[i];
        final row = _googleSheetsService.readingToRow(reading);
        final targetRange = '${range.split('!')[0]}!A${i + 2}:G${i + 2}'; // Skip header row

        if (reading.id == null || i == 0) {
          await _googleSheetsService.writeRow(spreadsheetId, targetRange, row);
        } else {
          await _googleSheetsService.updateRow(spreadsheetId, targetRange, row);
        }
      }

      _setSyncState(SyncState(
        status: SyncStatus.success,
        message: 'Successfully synced ${readings.length} readings',
        lastSyncTime: DateTime.now(),
      ));
    } catch (e) {
      _setSyncState(SyncState(status: SyncStatus.error, message: 'Sync failed: $e'));
    }
  }

  void _setSyncState(SyncState newState) {
    _syncState = newState;
    notifyListeners();
  }
}

// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:blood_pressure_tracker/models/user_settings.dart';

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = UserSettings();

  UserSettings get settings => _settings;

  void updateSettings(UserSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    notifyListeners();
  }

  void toggleAutoSync() {
    _settings = _settings.copyWith(autoSync: !_settings.autoSync);
    notifyListeners();
  }

  void updateGoogleSheetsConfig(String spreadsheetId, String range) {
    _settings = _settings.copyWith(
      googleSheetsId: spreadsheetId,
      googleSheetsRange: range,
    );
    notifyListeners();
  }
}
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/unit/providers_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/providers/ test/unit/providers_test.dart
git commit -m "feat: implement state management providers with tests"
```

### Task 6: Main App Structure and Navigation

**Files:**
- Create: `lib/main.dart`
- Create: `lib/app.dart`
- Test: `test/widget/app_test.dart`

**Step 1: Write failing test for app navigation**

```dart
// test/widget/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blood_pressure_tracker/app.dart';
import 'package:blood_pressure_tracker/providers/blood_pressure_provider.dart';

void main() {
  group('App Navigation', () {
    testWidgets('should display bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => BloodPressureProvider(),
          child: const MaterialApp(
            home: App(),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Chart'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('should navigate to add reading screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => BloodPressureProvider(),
          child: const MaterialApp(
            home: App(),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Add Blood Pressure Reading'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widget/app_test.dart`
Expected: FAIL - "App not found"

**Step 3: Implement main app structure**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/blood_pressure_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/settings_provider.dart';
import 'services/database_service.dart';
import 'services/google_sheets_service.dart';

void main() {
  runApp(const BloodPressureTrackerApp());
}

class BloodPressureTrackerApp extends StatelessWidget {
  const BloodPressureTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BloodPressureProvider(),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<BloodPressureProvider, SyncProvider>(
          create: (context) => SyncProvider(
            bloodPressureProvider: context.read<BloodPressureProvider>(),
          ),
          update: (context, bloodPressureProvider, syncProvider) =>
              syncProvider ?? SyncProvider(
                bloodPressureProvider: bloodPressureProvider,
              ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Blood Pressure Tracker',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: settings.settings.darkMode ? Brightness.dark : Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const App(),
          );
        },
      ),
    );
  }
}

// lib/app.dart
import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_reading_screen.dart';
import 'screens/distribution_screen.dart';
import 'screens/history_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AddReadingScreen(),
    const DistributionScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scatter_plot_outlined),
            activeIcon: Icon(Icons.scatter_plot),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
```

**Step 4: Create placeholder screens**

```dart
// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text('Dashboard - Coming Soon'),
      ),
    );
  }
}

// lib/screens/add_reading_screen.dart
import 'package:flutter/material.dart';

class AddReadingScreen extends StatelessWidget {
  const AddReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reading'),
      ),
      body: const Center(
        child: Text('Add Reading - Coming Soon'),
      ),
    );
  }
}

// lib/screens/distribution_screen.dart
import 'package:flutter/material.dart';

class DistributionScreen extends StatelessWidget {
  const DistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution'),
      ),
      body: const Center(
        child: Text('Distribution Chart - Coming Soon'),
      ),
    );
  }
}

// lib/screens/history_screen.dart
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: const Center(
        child: Text('History - Coming Soon'),
      ),
    );
  }
}
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/widget/app_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/main.dart lib/app.dart lib/screens/ test/widget/app_test.dart
git commit -m "feat: implement main app structure and navigation with tests"
```

## Implementation Complete

**Plan complete and saved to `docs/plans/2025-12-04-blood-pressure-tracker.md`.**

**Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**