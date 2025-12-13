# Clean Architecture Implementation

## Overview

This document describes the Clean Architecture implementation of the Cardio Tracker Flutter application. The architecture follows the principles defined by Robert C. Martin, ensuring separation of concerns, dependency inversion, and testable code.

## Project Structure

```
lib/
├── domain/                 # Pure business rules - no dependencies
│   ├── entities/          # Business objects (e.g., BloodPressureReading)
│   ├── repositories/      # Abstract repository interfaces
│   └── value_objects/     # Domain-specific types (e.g., BloodPressureCategory)
├── application/           # Application use cases - depends only on domain
│   └── use_cases/         # Business logic orchestration
├── infrastructure/        # External concerns - depends on domain
│   ├── data_sources/      # Concrete data sources (SQLite, Cloudflare KV)
│   ├── mappers/           # Data transformation utilities
│   ├── repositories/      # Repository implementations
│   └── services/          # External service adapters
├── presentation/          # UI and state - depends on application/domain
│   ├── providers/         # State management (Provider pattern)
│   ├── screens/           # UI screens
│   └── widgets/           # Reusable UI components
└── core/                  # Shared utilities across layers
    ├── errors/            # Error types and failure handling
    ├── injection/         # Dependency injection configuration
    ├── usecases/          # Base use case interface
    └── utils/             # Common utilities
```

## Dependency Rules

### 1. Domain Layer
- **No outgoing dependencies** - Pure business logic
- Contains entities, value objects, and repository interfaces
- Can import from core (for shared utilities like failures)

### 2. Application Layer
- **Depends only on Domain** (and core for shared utilities)
- Contains use cases that orchestrate business logic
- Implements application-specific rules

### 3. Infrastructure Layer
- **Depends on Domain and Application**
- Implements repository interfaces
- Handles external concerns (database, network, file system)
- Contains concrete implementations of interfaces

### 4. Presentation Layer
- **Depends only on Application and Domain**
- Contains UI components and state management
- Should NOT directly import infrastructure

## Data Flow

```
┌─────────────────┐
│   Presentation  │ ──► User Action
│   (UI/State)    │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│   Application   │ ──► Use Case
│   (Use Cases)   │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│     Domain      │ ◄── Business Rules
│ (Entities/VOs)  │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐
│ Infrastructure  │ ◄── Repository Impl
│   (Data Source) │
└─────────────────┘
```

1. **UI triggers action** in Provider (Presentation Layer)
2. **Provider calls** appropriate Use Case (Application Layer)
3. **Use Case orchestrates** business logic using Repository interfaces (Domain Layer)
4. **Repository implementation** handles data operations (Infrastructure Layer)
5. **Result flows back** through the same layers using Either<Failure, Success>

## Key Patterns

### 1. Repository Pattern
- Abstract interfaces in Domain layer
- Concrete implementations in Infrastructure layer
- Enables testability and flexibility

### 2. Use Case Pattern
- Encapsulates specific application operations
- Takes input parameters and returns results
- Handles business logic orchestration

### 3. Provider Pattern
- State management in Presentation layer
- Exposes data to UI widgets
- Handles user interactions

### 4. Value Objects
- Immutable objects with business meaning
- Domain-specific validation logic
- Examples: BloodPressureCategory, ReadingStatistics

## Dependency Injection

The app uses `get_it` with `injectable` for dependency injection:

```dart
// Registration in core/injection/
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
}
```

## Error Handling

Uses the Result pattern with `Either<Failure, Success>` from `dartz`:

```dart
abstract class Failure extends Equatable {
  // Base failure class
}

class DatabaseFailure extends Failure {
  final String message;
  const DatabaseFailure(this.message);
}

class NetworkFailure extends Failure {
  final String message;
  const NetworkFailure(this.message);
}
```

## Testing Strategy

### Unit Tests
- **Domain Layer**: Pure logic tests
- **Application Layer**: Use case tests with mocks
- **Infrastructure Layer**: Data source and repository tests
- **Presentation Layer**: Provider tests with mocked use cases

### Test Structure Mirrors Architecture
```
test/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── value_objects/
├── application/
│   └── use_cases/
├── infrastructure/
│   ├── data_sources/
│   └── repositories/
└── presentation/
    └── providers/
```

## Migration Notes

### Completed Tasks
1. ✅ Created Clean Architecture directory structure
2. ✅ Moved entities to domain layer
3. ✅ Created repository interfaces in domain
4. ✅ Implemented use cases in application layer
5. ✅ Migrated data sources to infrastructure
6. ✅ Implemented repository pattern
7. ✅ Set up dependency injection
8. ✅ Refactored providers to use use cases

### Known Violations (To be addressed)
1. **5 files in presentation import infrastructure directly**:
   - `lib/presentation/providers/settings_provider.dart`
   - `lib/presentation/screens/dashboard_screen.dart`
   - `lib/presentation/screens/cloudflare_settings_screen.dart`

   These need to be refactored to use repository interfaces through use cases instead of direct service imports.

## Benefits Achieved

1. **Testability**: Each layer can be tested in isolation
2. **Maintainability**: Clear separation of concerns
3. **Flexibility**: Easy to swap implementations (e.g., database, network)
4. **Scalability**: Adding new features follows established patterns
5. **Code Reuse**: Business logic is isolated and reusable

## Best Practices

1. **Never violate dependency rules** - dependencies point inward
2. **Keep domain layer pure** - no external dependencies
3. **Use dependency injection** - enables testing and flexibility
4. **Write tests first** - ensures proper layering
5. **Keep use cases focused** - single responsibility principle
6. **Handle errors explicitly** - use Either/Result pattern

## Future Improvements

1. Complete migration of remaining presentation layer violations
2. Add integration tests across layers
3. Implement caching layer in infrastructure
4. Add offline sync capabilities
5. Create more granular use cases for complex operations