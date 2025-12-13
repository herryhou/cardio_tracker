# Clean Architecture Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor the cardio tracker Flutter app to properly implement Clean Architecture with clear separation of concerns, dependency inversion, and testable layers.

**Architecture:** Implement proper layered architecture with Domain → Application → Infrastructure → Presentation layers, following dependency inversion principles with abstractions flowing inward.

**Tech Stack:** Flutter, Dart, Provider, SQLite, Cloudflare KV, get_it for DI

---

## Overview

This refactor will transform the current architecture from a basic 3-layer structure to a proper Clean Architecture implementation with:

1. **Domain Layer**: Pure business rules and entities
2. **Application Layer**: Use cases orchestrating business logic
3. **Infrastructure Layer**: Data sources and repository implementations
4. **Presentation Layer**: UI components and state management

## Phase 1: Foundation Setup

### Task 1: Create Clean Architecture Directory Structure

**Files:**
- Create: `lib/domain/`
- Create: `lib/domain/entities/`
- Create: `lib/domain/repositories/`
- Create: `lib/domain/value_objects/`
- Create: `lib/application/`
- Create: `lib/application/use_cases/`
- Create: `lib/infrastructure/`
- Create: `lib/infrastructure/data_sources/`
- Create: `lib/infrastructure/repositories/`
- Create: `lib/presentation/`
- Create: `lib/presentation/providers/`
- Create: `lib/presentation/screens/`
- Create: `lib/presentation/widgets/`
- Create: `lib/core/`
- Create: `lib/core/errors/`
- Create: `lib/core/utils/`
- Create: `lib/core/injection/`

**Step 1: Create directories**

```bash
mkdir -p lib/domain/{entities,repositories,value_objects}
mkdir -p lib/application/use_cases
mkdir -p lib/infrastructure/{data_sources,repositories}
mkdir -p lib/presentation/{providers,screens,widgets}
mkdir -p lib/core/{errors,utils,injection}
```

**Step 2: Run to verify directories created**

Run: `tree lib -d -L 3`
Expected: Show all new directories created

**Step 3: Create barrel exports**

Create: `lib/domain/domain.dart`
```dart
// Domain barrel export
export 'entities/blood_pressure_reading.dart';
export 'entities/user_settings.dart';
export 'repositories/blood_pressure_repository.dart';
export 'repositories/user_settings_repository.dart';
export 'value_objects/blood_pressure_category.dart';
```

**Step 4: Commit**

```bash
git add lib/
git commit -m "feat: create Clean Architecture directory structure"
```

### Task 2: Add Dependencies for DI and Result Pattern

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Add new dependencies**

```yaml
dependencies:
  # ... existing dependencies
  get_it: ^7.6.4
  injectable: ^2.3.2
  freezed_annotation: ^2.4.1
  dartz: ^0.10.1

dev_dependencies:
  # ... existing dev dependencies
  injectable_generator: ^2.4.1
  build_runner: ^2.4.7
  freezed: ^2.4.6
```

**Step 2: Install dependencies**

Run: `flutter pub get`
Expected: All dependencies installed successfully

**Step 3: Run flutter pub get to verify**

Run: `flutter pub deps`
Expected: Show get_it, injectable, dartz in dependency tree

**Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add DI and result pattern dependencies"
```

## Phase 2: Domain Layer Implementation

### Task 3: Move and Refactor Domain Entities

**Files:**
- Move: `lib/models/blood_pressure_reading.dart` → `lib/domain/entities/blood_pressure_reading.dart`
- Create: `lib/domain/value_objects/blood_pressure_category.dart`
- Move: `lib/models/user_settings.dart` → `lib/domain/entities/user_settings.dart`

**Step 1: Write tests for BloodPressureCategory value object**

Create: `test/domain/value_objects/blood_pressure_category_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cardio_tracker/domain/value_objects/blood_pressure_category.dart';

void main() {
  group('BloodPressureCategory', () {
    test('should return CRISIS for systolic >= 180', () {
      final category = BloodPressureCategory.fromValues(180, 80);
      expect(category, BloodPressureCategory.crisis);
    });

    test('should return CRISIS for diastolic >= 120', () {
      final category = BloodPressureCategory.fromValues(120, 120);
      expect(category, BloodPressureCategory.crisis);
    });

    test('should return NORMAL for valid normal range', () {
      final category = BloodPressureCategory.fromValues(115, 75);
      expect(category, BloodPressureCategory.normal);
    });

    test('should return LOW for low values', () {
      final category = BloodPressureCategory.fromValues(85, 55);
      expect(category, BloodPressureCategory.low);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/domain/value_objects/blood_pressure_category_test.dart`
Expected: FAIL with "BloodPressureCategory not found"

**Step 3: Create BloodPressureCategory value object**

Create: `lib/domain/value_objects/blood_pressure_category.dart`
```dart
enum BloodPressureCategory {
  low,
  normal,
  elevated,
  stage1,
  stage2,
  crisis;

  static BloodPressureCategory fromValues(int systolic, int diastolic) {
    // Check for hypertensive crisis first (highest priority)
    if (systolic >= 180 || diastolic >= 120) {
      return BloodPressureCategory.crisis;
    }

    // Check for Stage 2 hypertension
    if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureCategory.stage2;
    }

    // Check for Stage 1 hypertension
    if (systolic >= 130 || diastolic >= 85) {
      return BloodPressureCategory.stage1;
    }

    // Check for elevated
    if ((systolic >= 121 && systolic <= 129) ||
        (diastolic >= 81 && diastolic <= 84)) {
      return BloodPressureCategory.elevated;
    }

    // Check for normal
    if (systolic > 90 && systolic <= 120 && diastolic > 60 && diastolic <= 80) {
      return BloodPressureCategory.normal;
    }

    // Otherwise, it's low
    return BloodPressureCategory.low;
  }

  String get displayName {
    switch (this) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/domain/value_objects/blood_pressure_category_test.dart`
Expected: PASS

**Step 5: Move and refactor BloodPressureReading entity**

Move and update: `lib/domain/entities/blood_pressure_reading.dart`
```dart
import '../value_objects/blood_pressure_category.dart';

class BloodPressureReading {
  final String id;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final DateTime timestamp;
  final String? notes;
  final DateTime lastModified;
  final bool isDeleted;

  BloodPressureReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.timestamp,
    this.notes,
    required this.lastModified,
    this.isDeleted = false,
  });

  BloodPressureCategory get category {
    return BloodPressureCategory.fromValues(systolic, diastolic);
  }

  bool get hasHeartRate => heartRate > 0;

  BloodPressureReading copyWith({
    String? id,
    int? systolic,
    int? diastolic,
    int? heartRate,
    DateTime? timestamp,
    String? notes,
    DateTime? lastModified,
    bool? isDeleted,
  }) {
    return BloodPressureReading(
      id: id ?? this.id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      lastModified: lastModified ?? this.lastModified,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodPressureReading &&
        other.id == id &&
        other.systolic == systolic &&
        other.diastolic == diastolic &&
        other.heartRate == heartRate &&
        other.timestamp == timestamp &&
        other.notes == notes &&
        other.lastModified == lastModified &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        systolic.hashCode ^
        diastolic.hashCode ^
        heartRate.hashCode ^
        timestamp.hashCode ^
        notes.hashCode ^
        lastModified.hashCode ^
        isDeleted.hashCode;
  }
}
```

**Step 6: Commit**

```bash
git add test/domain/lib/domain/
git commit -m "feat: create BloodPressureCategory value object"
git add lib/domain/entities/blood_pressure_reading.dart lib/domain/value_objects/
git commit -m "refactor: move BloodPressureReading to domain layer"
```

### Task 4: Create Repository Interfaces

**Files:**
- Create: `lib/domain/repositories/blood_pressure_repository.dart`
- Create: `lib/domain/repositories/user_settings_repository.dart`

**Step 1: Write tests for repository interfaces**

Create: `test/domain/repositories/blood_pressure_repository_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'blood_pressure_repository_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('BloodPressureRepository', () {
    late MockBloodPressureRepository mockRepository;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
    });

    test('should return list of readings when getAll succeeds', () async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        )
      ];

      when(mockRepository.getAllReadings())
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await mockRepository.getAllReadings();

      // Assert
      expect(result, isA<Right>());
      expect(result.fold((l) => l, (r) => r), equals(readings));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/domain/repositories/blood_pressure_repository_test.dart`
Expected: FAIL with missing files

**Step 3: Create repository interface**

Create: `lib/core/errors/failures.dart`
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object?> get props => [];
}

class DatabaseFailure extends Failure {
  final String message;

  const DatabaseFailure(this.message);

  @override
  String toString() => 'DatabaseFailure: $message';
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure(this.message);

  @override
  String toString() => 'NetworkFailure: $message';
}

class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure(this.message);

  @override
  String toString() => 'ValidationFailure: $message';
}
```

Create: `lib/domain/repositories/blood_pressure_repository.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/blood_pressure_reading.dart';

abstract class BloodPressureRepository {
  Future<Either<Failure, List<BloodPressureReading>>> getAllReadings();
  Future<Either<Failure, void>> addReading(BloodPressureReading reading);
  Future<Either<Failure, void>> updateReading(BloodPressureReading reading);
  Future<Either<Failure, void>> deleteReading(String id);
  Future<Either<Failure, List<BloodPressureReading>>> getReadingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, BloodPressureReading?>> getLatestReading();
  Future<Either<Failure, List<BloodPressureReading>>> getRecentReadings({
    int days = 30,
  });
}
```

**Step 4: Generate test mocks**

Run: `flutter pub run build_runner build`
Expected: Mock files generated

**Step 5: Run test to verify it passes**

Run: `flutter test test/domain/repositories/blood_pressure_repository_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/core/errors/ lib/domain/repositories/
git commit -m "feat: create repository interfaces and failure types"
```

## Phase 3: Application Layer Implementation

### Task 5: Create Use Cases

**Files:**
- Create: `lib/application/use_cases/get_all_readings.dart`
- Create: `lib/application/use_cases/add_reading.dart`
- Create: `lib/application/use_cases/get_latest_reading.dart`
- Create: `lib/application/use_cases/get_reading_statistics.dart`

**Step 1: Write tests for GetAllReadings use case**

Create: `test/application/use_cases/get_all_readings_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/application/use_cases/get_all_readings.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'get_all_readings_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('GetAllReadings', () {
    late MockBloodPressureRepository mockRepository;
    late GetAllReadings useCase;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
      useCase = GetAllReadings(mockRepository);
    });

    test('should return readings when repository succeeds', () async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        )
      ];

      when(mockRepository.getAllReadings())
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Right>());
      expect(result.fold((l) => l, (r) => r), equals(readings));
      verify(mockRepository.getAllReadings());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/application/use_cases/get_all_readings_test.dart`
Expected: FAIL with missing use case

**Step 3: Implement GetAllReadings use case**

Create: `lib/application/use_cases/get_all_readings.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

class GetAllReadings implements UseCase<List<BloodPressureReading>, NoParams> {
  final BloodPressureRepository repository;

  GetAllReadings(this.repository);

  @override
  Future<Either<Failure, List<BloodPressureReading>>> call(NoParams params) {
    return repository.getAllReadings();
  }
}
```

**Step 4: Create base UseCase interface**

Create: `lib/core/usecases/usecase.dart`
```dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/application/use_cases/get_all_readings_test.dart`
Expected: PASS

**Step 6: Create AddReading use case with validation**

Create: `test/application/use_cases/add_reading_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/application/use_cases/add_reading.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'add_reading_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('AddReading', () {
    late MockBloodPressureRepository mockRepository;
    late AddReading useCase;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
      useCase = AddReading(mockRepository);
    });

    test('should add valid reading successfully', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      when(mockRepository.addReading(reading))
          .thenAnswer((_) async => Right(null));

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Right>());
      verify(mockRepository.addReading(reading));
    });

    test('should return validation failure for invalid systolic', () async {
      // Arrange
      final reading = BloodPressureReading(
        id: '1',
        systolic: 300, // Invalid high value
        diastolic: 80,
        heartRate: 72,
        timestamp: DateTime.now(),
        lastModified: DateTime.now(),
      );

      // Act
      final result = await useCase(reading);

      // Assert
      expect(result, isA<Left>());
      expect(result.fold((l) => l, (r) => r), isA<ValidationFailure>());
      verifyNever(mockRepository.addReading(any));
    });
  });
}
```

**Step 7: Implement AddReading use case**

Create: `lib/application/use_cases/add_reading.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

class AddReading implements UseCase<void, BloodPressureReading> {
  final BloodPressureRepository repository;

  AddReading(this.repository);

  @override
  Future<Either<Failure, void>> call(BloodPressureReading reading) {
    // Validate reading
    final validationFailure = _validateReading(reading);
    if (validationFailure != null) {
      return Future.value(Left(validationFailure));
    }

    return repository.addReading(reading);
  }

  ValidationFailure? _validateReading(BloodPressureReading reading) {
    if (reading.systolic < 50 || reading.systolic > 300) {
      return const ValidationFailure('Systolic must be between 50 and 300');
    }
    if (reading.diastolic < 30 || reading.diastolic > 200) {
      return const ValidationFailure('Diastolic must be between 30 and 200');
    }
    if (reading.heartRate < 0 || reading.heartRate > 300) {
      return const ValidationFailure('Heart rate must be between 0 and 300');
    }
    return null;
  }
}
```

**Step 8: Run tests to verify they pass**

Run: `flutter test test/application/use_cases/add_reading_test.dart`
Expected: PASS

**Step 9: Commit**

```bash
git add lib/core/usecases/ lib/application/use_cases/
git commit -m "feat: implement use cases for blood pressure operations"
```

### Task 6: Create GetStatistics Use Case

**Files:**
- Create: `lib/application/use_cases/get_reading_statistics.dart`
- Create: `lib/domain/value_objects/reading_statistics.dart`

**Step 1: Write tests for statistics**

Create: `test/application/use_cases/get_reading_statistics_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/application/use_cases/get_reading_statistics.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/domain/repositories/blood_pressure_repository.dart';
import 'package:cardio_tracker/domain/value_objects/reading_statistics.dart';

import 'get_reading_statistics_test.mocks.dart';

@GenerateMocks([BloodPressureRepository])
void main() {
  group('GetReadingStatistics', () {
    late MockBloodPressureRepository mockRepository;
    late GetReadingStatistics useCase;

    setUp(() {
      mockRepository = MockBloodPressureRepository();
      useCase = GetReadingStatistics(mockRepository);
    });

    test('should calculate statistics correctly', () async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        ),
        BloodPressureReading(
          id: '2',
          systolic: 130,
          diastolic: 85,
          heartRate: 75,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        ),
      ];

      when(mockRepository.getReadingsByDateRange(any, any))
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await useCase(const StatisticsParams(days: 30));

      // Assert
      expect(result, isA<Right>());
      final stats = result.fold((l) => null, (r) => r)!;
      expect(stats.averageSystolic, closeTo(125, 0.1));
      expect(stats.averageDiastolic, closeTo(82.5, 0.1));
      expect(stats.averageHeartRate, closeTo(73.5, 0.1));
      expect(stats.totalReadings, 2);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/application/use_cases/get_reading_statistics_test.dart`
Expected: FAIL with missing files

**Step 3: Create ReadingStatistics value object**

Create: `lib/domain/value_objects/reading_statistics.dart`
```dart
class ReadingStatistics {
  final double averageSystolic;
  final double averageDiastolic;
  final double averageHeartRate;
  final int totalReadings;
  final Map<String, int> categoryDistribution;
  final DateTime? latestReadingDate;
  final int? averageDaysBetweenReadings;

  const ReadingStatistics({
    required this.averageSystolic,
    required this.averageDiastolic,
    required this.averageHeartRate,
    required this.totalReadings,
    required this.categoryDistribution,
    this.latestReadingDate,
    this.averageDaysBetweenReadings,
  });

  bool get hasData => totalReadings > 0;
}
```

**Step 4: Implement GetReadingStatistics use case**

Create: `lib/application/use_cases/get_reading_statistics.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../domain/value_objects/blood_pressure_category.dart';
import '../../domain/value_objects/reading_statistics.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

class GetReadingStatistics implements UseCase<ReadingStatistics, StatisticsParams> {
  final BloodPressureRepository repository;

  GetReadingStatistics(this.repository);

  @override
  Future<Either<Failure, ReadingStatistics>> call(StatisticsParams params) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: params.days));

    final result = await repository.getReadingsByDateRange(startDate, endDate);

    return result.fold(
      (failure) => Left(failure),
      (readings) => Right(_calculateStatistics(readings)),
    );
  }

  ReadingStatistics _calculateStatistics(List<BloodPressureReading> readings) {
    if (readings.isEmpty) {
      return const ReadingStatistics(
        averageSystolic: 0,
        averageDiastolic: 0,
        averageHeartRate: 0,
        totalReadings: 0,
        categoryDistribution: {},
      );
    }

    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final totalSystolic = readings.fold<int>(0, (sum, r) => sum + r.systolic);
    final totalDiastolic = readings.fold<int>(0, (sum, r) => sum + r.diastolic);
    final totalHeartRate = readings.fold<int>(0, (sum, r) => sum + r.heartRate);

    final categoryDistribution = <String, int>{};
    for (final reading in readings) {
      final category = reading.category.displayName;
      categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
    }

    return ReadingStatistics(
      averageSystolic: totalSystolic / readings.length,
      averageDiastolic: totalDiastolic / readings.length,
      averageHeartRate: totalHeartRate / readings.length,
      totalReadings: readings.length,
      categoryDistribution: categoryDistribution,
      latestReadingDate: readings.last.timestamp,
    );
  }
}

class StatisticsParams {
  final int days;
  const StatisticsParams({this.days = 30});
}
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/application/use_cases/get_reading_statistics_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/domain/value_objects/reading_statistics.dart lib/application/use_cases/get_reading_statistics.dart
git commit -m "feat: implement reading statistics use case"
```

## Phase 4: Infrastructure Layer Implementation

### Task 7: Implement Data Sources

**Files:**
- Create: `lib/infrastructure/data_sources/local_database_source.dart`
- Create: `lib/infrastructure/data_sources/cloudflare_kv_source.dart`

**Step 1: Write tests for local database source**

Create: `test/infrastructure/data_sources/local_database_source_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cardio_tracker/infrastructure/data_sources/local_database_source.dart';

void main() {
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Set database factory
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalDatabaseSource', () {
    late LocalDatabaseSource dataSource;

    setUp(() async {
      dataSource = LocalDatabaseSource();
      await dataSource.initDatabase(':memory:');
    });

    tearDown(() async {
      await dataSource.closeDatabase();
    });

    test('should insert and retrieve reading', () async {
      // Arrange
      final readingMap = {
        'id': '1',
        'systolic': 120,
        'diastolic': 80,
        'heartRate': 72,
        'timestamp': DateTime.now().toIso8601String(),
        'notes': null,
        'lastModified': DateTime.now().toIso8601String(),
        'isDeleted': 0,
      };

      // Act
      await dataSource.insertReading(readingMap);
      final result = await dataSource.getAllReadings();

      // Assert
      expect(result.length, 1);
      expect(result.first['id'], '1');
      expect(result.first['systolic'], 120);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/infrastructure/data_sources/local_database_source_test.dart`
Expected: FAIL with missing data source

**Step 3: Implement LocalDatabaseSource**

Create: `lib/infrastructure/data_sources/local_database_source.dart`
```dart
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
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/infrastructure/data_sources/local_database_source_test.dart`
Expected: PASS

**Step 5: Add sqflite_common dependency for testing**

Modify: `pubspec.yaml`
```yaml
dev_dependencies:
  # ... existing
  sqflite_common_ffi: ^2.3.2
```

**Step 6: Install dependency**

Run: `flutter pub get`

**Step 7: Commit**

```bash
git add lib/infrastructure/data_sources/local_database_source.dart test/infrastructure/
git commit -m "feat: implement local database data source"
```

### Task 8: Implement Repository

**Files:**
- Create: `lib/infrastructure/repositories/blood_pressure_repository_impl.dart`

**Step 1: Write tests for repository implementation**

Create: `test/infrastructure/repositories/blood_pressure_repository_impl_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/infrastructure/repositories/blood_pressure_repository_impl.dart';
import 'package:cardio_tracker/infrastructure/data_sources/local_database_source.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'blood_pressure_repository_impl_test.mocks.dart';

@GenerateMocks([LocalDatabaseSource])
void main() {
  group('BloodPressureRepositoryImpl', () {
    late MockLocalDatabaseSource mockDataSource;
    late BloodPressureRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockLocalDatabaseSource();
      repository = BloodPressureRepositoryImpl(dataSource: mockDataSource);
    });

    test('should return list of readings on success', () async {
      // Arrange
      final readingsMap = [
        {
          'id': '1',
          'systolic': 120,
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': DateTime.now().toIso8601String(),
          'notes': null,
          'lastModified': DateTime.now().toIso8601String(),
          'isDeleted': 0,
        }
      ];

      when(mockDataSource.getAllReadings())
          .thenAnswer((_) async => readingsMap);

      // Act
      final result = await repository.getAllReadings();

      // Assert
      expect(result, isA<Right>());
      final readings = result.fold((l) => null, (r) => r)!;
      expect(readings.length, 1);
      expect(readings.first.systolic, 120);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/infrastructure/repositories/blood_pressure_repository_impl_test.dart`
Expected: FAIL with missing repository implementation

**Step 3: Implement BloodPressureRepositoryImpl**

Create: `lib/infrastructure/repositories/blood_pressure_repository_impl.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../core/errors/failures.dart';
import '../data_sources/local_database_source.dart';

class BloodPressureRepositoryImpl implements BloodPressureRepository {
  final LocalDatabaseSource dataSource;

  BloodPressureRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<BloodPressureReading>>> getAllReadings() async {
    try {
      final readingsMap = await dataSource.getAllReadings();
      final readings = readingsMap.map(_mapToReading).toList();
      return Right(readings);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get readings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addReading(BloodPressureReading reading) async {
    try {
      final readingMap = _mapFromReading(reading);
      await dataSource.insertReading(readingMap);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReading(BloodPressureReading reading) async {
    try {
      final readingMap = _mapFromReading(reading);
      await dataSource.updateReading(readingMap);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReading(String id) async {
    try {
      await dataSource.deleteReading(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BloodPressureReading>>> getReadingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final readingsMap = await dataSource.getReadingsByDateRange(startDate, endDate);
      final readings = readingsMap.map(_mapToReading).toList();
      return Right(readings);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get readings by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BloodPressureReading?>> getLatestReading() async {
    try {
      final readingMap = await dataSource.getLatestReading();
      if (readingMap == null) return const Right(null);
      return Right(_mapToReading(readingMap));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get latest reading: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BloodPressureReading>>> getRecentReadings({
    int days = 30,
  }) async {
    return getReadingsByDateRange(
      DateTime.now().subtract(Duration(days: days)),
      DateTime.now(),
    );
  }

  BloodPressureReading _mapToReading(Map<String, dynamic> map) {
    return BloodPressureReading(
      id: map['id'] as String,
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      heartRate: map['heartRate'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
      lastModified: DateTime.parse(map['lastModified'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }

  Map<String, dynamic> _mapFromReading(BloodPressureReading reading) {
    return {
      'id': reading.id,
      'systolic': reading.systolic,
      'diastolic': reading.diastolic,
      'heartRate': reading.heartRate,
      'timestamp': reading.timestamp.toIso8601String(),
      'notes': reading.notes,
      'lastModified': reading.lastModified.toIso8601String(),
      'isDeleted': reading.isDeleted ? 1 : 0,
    };
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/infrastructure/repositories/blood_pressure_repository_impl_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/infrastructure/repositories/ test/infrastructure/repositories/
git commit -m "feat: implement blood pressure repository"
```

## Phase 5: Dependency Injection Setup

### Task 9: Configure Dependency Injection

**Files:**
- Create: `lib/core/injection/injection.dart`

**Step 1: Create injection configuration**

Create: `lib/core/injection/injection.dart`
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();
}
```

**Step 2: Create module configuration**

Create: `lib/core/injection/injection_module.dart`
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../../application/use_cases/get_all_readings.dart';
import '../../application/use_cases/add_reading.dart';
import '../../application/use_cases/get_reading_statistics.dart';
import '../injection/injection.dart';

@module
abstract class InjectionModule {
  // Data Sources
  @lazySingleton
  LocalDatabaseSource getLocalDatabaseSource() => LocalDatabaseSource();

  // Repositories
  @lazySingleton
  BloodPressureRepository getBloodPressureRepository(LocalDatabaseSource dataSource) {
    return BloodPressureRepositoryImpl(dataSource: dataSource);
  }

  // Use Cases
  @lazySingleton
  GetAllReadings getAllReadings(BloodPressureRepository repository) {
    return GetAllReadings(repository);
  }

  @lazySingleton
  AddReading addReading(BloodPressureRepository repository) {
    return AddReading(repository);
  }

  @lazySingleton
  GetReadingStatistics getReadingStatistics(BloodPressureRepository repository) {
    return GetReadingStatistics(repository);
  }
}
```

**Step 3: Update imports in injection.dart**

Modify: `lib/core/injection/injection.dart`
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';
import '../../infrastructure/data_sources/local_database_source.dart';
import '../../infrastructure/repositories/blood_pressure_repository_impl.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();
}
```

**Step 4: Generate injection configuration**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: Generated files in injection.config.dart

**Step 5: Initialize DI in main.dart**

Modify: `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/injection/injection.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/providers/blood_pressure_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BloodPressureProvider(
            getAllReadings: getIt<GetAllReadings>(),
            addReading: getIt<AddReading>(),
            getReadingStatistics: getIt<GetReadingStatistics>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Cardio Tracker',
        theme: ThemeData(
          // Your existing theme configuration
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
```

**Step 6: Commit**

```bash
git add lib/core/injection/
git commit -m "feat: configure dependency injection with get_it"
```

## Phase 6: Presentation Layer Refactoring

### Task 10: Refactor BloodPressureProvider

**Files:**
- Move: `lib/providers/blood_pressure_provider.dart` → `lib/presentation/providers/blood_pressure_provider.dart`

**Step 1: Write tests for refactored provider**

Create: `test/presentation/providers/blood_pressure_provider_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cardio_tracker/presentation/providers/blood_pressure_provider.dart';
import 'package:cardio_tracker/application/use_cases/get_all_readings.dart';
import 'package:cardio_tracker/application/use_cases/add_reading.dart';
import 'package:cardio_tracker/application/use_cases/get_reading_statistics.dart';
import 'package:cardio_tracker/domain/entities/blood_pressure_reading.dart';
import 'package:cardio_tracker/core/errors/failures.dart';

import 'blood_pressure_provider_test.mocks.dart';

@GenerateMocks([GetAllReadings, AddReading, GetReadingStatistics])
void main() {
  group('BloodPressureProvider', () {
    late MockGetAllReadings mockGetAllReadings;
    late MockAddReading mockAddReading;
    late MockGetReadingStatistics mockGetStatistics;
    late BloodPressureProvider provider;

    setUp(() {
      mockGetAllReadings = MockGetAllReadings();
      mockAddReading = MockAddReading();
      mockGetStatistics = MockGetReadingStatistics();

      provider = BloodPressureProvider(
        getAllReadings: mockGetAllReadings,
        addReading: mockAddReading,
        getReadingStatistics: mockGetStatistics,
      );
    });

    test('should load readings successfully', () async {
      // Arrange
      final readings = [
        BloodPressureReading(
          id: '1',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          timestamp: DateTime.now(),
          lastModified: DateTime.now(),
        )
      ];

      when(mockGetAllReadings(any))
          .thenAnswer((_) async => Right(readings));

      // Act
      await provider.loadReadings();

      // Assert
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.readings.length, 1);
      expect(provider.readings.first.systolic, 120);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/blood_pressure_provider_test.dart`
Expected: FAIL with refactored provider not found

**Step 3: Refactor BloodPressureProvider**

Create: `lib/presentation/providers/blood_pressure_provider.dart`
```dart
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../domain/value_objects/reading_statistics.dart';
import '../../application/use_cases/get_all_readings.dart';
import '../../application/use_cases/add_reading.dart';
import '../../application/use_cases/get_reading_statistics.dart';
import '../../core/usecases/usecase.dart';
import '../../core/errors/failures.dart';

class BloodPressureProvider extends ChangeNotifier {
  final GetAllReadings _getAllReadings;
  final AddReading _addReading;
  final GetReadingStatistics _getReadingStatistics;

  List<BloodPressureReading> _readings = [];
  bool _isLoading = false;
  String? _error;
  ReadingStatistics? _statistics;

  BloodPressureProvider({
    required GetAllReadings getAllReadings,
    required AddReading addReading,
    required GetReadingStatistics getReadingStatistics,
  })  : _getAllReadings = getAllReadings,
        _addReading = addReading,
        _getReadingStatistics = getReadingStatistics;

  // Getters
  List<BloodPressureReading> get readings => List.unmodifiable(_readings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  ReadingStatistics? get statistics => _statistics;

  // Computed properties
  double get averageSystolic => _statistics?.averageSystolic ?? 0.0;
  double get averageDiastolic => _statistics?.averageDiastolic ?? 0.0;
  double get averageHeartRate => _statistics?.averageHeartRate ?? 0.0;

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

  Future<void> loadReadings() async {
    _setLoading(true);
    _clearError();

    final result = await _getAllReadings(const NoParams());

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (readings) {
        _readings = readings;
        _computeStatistics();
      },
    );

    _setLoading(false);
  }

  Future<bool> addReading(BloodPressureReading reading) async {
    _setLoading(true);
    _clearError();

    final result = await _addReading(reading);

    bool success = false;
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (_) {
        success = true;
        _readings.add(reading);
        _computeStatistics();
      },
    );

    _setLoading(false);
    return success;
  }

  void _computeStatistics() {
    if (_readings.isEmpty) {
      _statistics = const ReadingStatistics(
        averageSystolic: 0,
        averageDiastolic: 0,
        averageHeartRate: 0,
        totalReadings: 0,
        categoryDistribution: {},
      );
    } else {
      // Use the use case for statistics
      _getReadingStatistics(const StatisticsParams(days: 365)).then((result) {
        result.fold(
          (failure) => debugPrint('Failed to compute statistics: $failure'),
          (statistics) {
            _statistics = statistics;
            notifyListeners();
          },
        );
      });

      // Compute basic statistics locally for immediate feedback
      final totalSystolic = _readings.fold<int>(0, (sum, r) => sum + r.systolic);
      final totalDiastolic = _readings.fold<int>(0, (sum, r) => sum + r.diastolic);
      final totalHeartRate = _readings.fold<int>(0, (sum, r) => sum + r.heartRate);

      final categoryDistribution = <String, int>{};
      for (final reading in _readings) {
        final category = reading.category.displayName;
        categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
      }

      _statistics = ReadingStatistics(
        averageSystolic: totalSystolic / _readings.length,
        averageDiastolic: totalDiastolic / _readings.length,
        averageHeartRate: totalHeartRate / _readings.length,
        totalReadings: _readings.length,
        categoryDistribution: categoryDistribution,
        latestReadingDate: latestReading?.timestamp,
      );
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

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure:
        return (failure as DatabaseFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case ValidationFailure:
        return (failure as ValidationFailure).message;
      default:
        return 'An unexpected error occurred';
    }
  }
}
```

**Step 4: Update imports in main.dart**

Modify: `lib/main.dart`
```dart
// Add import
import 'infrastructure/data_sources/local_database_source.dart';
import 'infrastructure/repositories/blood_pressure_repository_impl.dart';
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/providers/blood_pressure_provider_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/presentation/providers/ test/presentation/providers/
git commit -m "refactor: move BloodPressureProvider to presentation layer with use cases"
```

### Task 11: Update Screens to Use New Architecture

**Files:**
- Move: All screens from `lib/screens/` → `lib/presentation/screens/`
- Update: All screen imports to use new providers

**Step 1: Move screens directory**

```bash
mv lib/screens/* lib/presentation/screens/
rmdir lib/screens
```

**Step 2: Update imports in screens**

Update all screen files to import providers from the new location.

Example for dashboard_screen.dart:
```dart
// Change from:
import '../providers/blood_pressure_provider.dart';
// To:
import '../providers/blood_pressure_provider.dart';
```

**Step 3: Update main.dart imports**

Modify: `lib/main.dart`
```dart
// Update path
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/providers/blood_pressure_provider.dart';
```

**Step 4: Commit**

```bash
git add lib/
git commit -m "refactor: move screens to presentation layer and update imports"
```

## Phase 7: Migration Strategy

### Task 12: Clean Up Old Architecture

**Files:**
- Remove: `lib/models/` (already moved to domain)
- Remove: `lib/providers/` (already moved to presentation)
- Remove: `lib/services/` (replaced by infrastructure)
- Update: All imports throughout the project

**Step 1: Remove old service dependencies**

Remove direct imports of services from screens and widgets.

**Step 2: Create adapters for services not yet migrated**

For services like CloudflareKVService and CSVExportService, create adapter interfaces in the domain layer.

**Step 3: Commit**

```bash
git add lib/
git commit -m "cleanup: remove old architecture files and update imports"
```

### Task 13: Update Tests

**Files:**
- Update: All test imports to reflect new architecture
- Add: Integration tests for the new architecture

**Step 1: Update test imports**

```bash
find test -name "*.dart" -exec sed -i '' 's|../../models/|../../domain/entities/|g' {} \;
find test -name "*.dart" -exec sed -i '' 's|../../providers/|../../presentation/providers/|g' {} \;
find test -name "*.dart" -exec sed -i '' 's|../../services/|../../infrastructure/data_sources/|g' {} \;
```

**Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass

**Step 3: Commit**

```bash
git add test/
git commit -m "test: update tests for new architecture"
```

## Phase 8: Final Review

### Task 14: Architecture Validation

**Files:**
- Verify: All dependency rules are followed
- Check: No violations of Clean Architecture principles

**Step 1: Check dependency violations**

Run these commands to verify no architecture violations:

```bash
# Check no presentation layer imports infrastructure directly
grep -r "import '../infrastructure/" lib/presentation/ && echo "VIOLATION: Presentation imports Infrastructure" || echo "OK"

# Check no domain layer imports anything
grep -r "import '../" lib/domain/ && echo "VIOLATION: Domain has imports" || echo "OK"

# Check no application layer imports presentation
grep -r "import '../presentation/" lib/application/ && echo "VIOLATION: Application imports Presentation" || echo "OK"
```

**Step 2: Create architecture documentation**

Create: `docs/architecture.md`
```markdown
# Clean Architecture Implementation

## Project Structure

```
lib/
├── domain/                 # Pure business rules
│   ├── entities/          # Business objects
│   ├── repositories/      # Abstract repositories
│   └── value_objects/     # Domain-specific types
├── application/           # Application use cases
│   └── use_cases/         # Business logic orchestration
├── infrastructure/        # External concerns
│   ├── data_sources/      # Concrete data sources
│   └── repositories/      # Repository implementations
├── presentation/          # UI and state
│   ├── providers/         # State management
│   ├── screens/           # UI screens
│   └── widgets/           # Reusable UI
└── core/                  # Shared utilities
    ├── errors/            # Error types
    ├── injection/         # DI configuration
    └── usecases/          # Base use case interface
```

## Dependency Rules

1. **Domain** has no dependencies
2. **Application** depends only on Domain
3. **Infrastructure** depends on Domain and Application
4. **Presentation** depends only on Application and Domain

## Data Flow

1. UI triggers action in Provider
2. Provider calls appropriate Use Case
3. Use Case orchestrates business logic using Repository interfaces
4. Repository implementation handles data operations
5. Result flows back through the same layers
```

**Step 3: Final commit**

```bash
git add docs/
git commit -m "docs: add Clean Architecture documentation"
```

## Summary

This refactor transforms your Flutter app to properly implement Clean Architecture with:

- ✅ Clear separation of concerns
- ✅ Dependency inversion
- ✅ Testable architecture
- ✅ Single responsibility principle
- ✅ Repository pattern
- ✅ Use case pattern
- ✅ Dependency injection

The refactored codebase is now more maintainable, testable, and follows SOLID principles.