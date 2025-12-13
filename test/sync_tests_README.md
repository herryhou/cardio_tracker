# Cloudflare Sync Test Suite

This directory contains comprehensive tests for the Cloudflare KV sync functionality in the Cardio Tracker app.

## Overview

The sync algorithm implements a bidirectional sync between local SQLite database and Cloudflare KV storage with the following key features:
- **Manual sync**: User-initiated sync operations
- **Last-write-wins conflict resolution**: More recent modifications override older ones
- **Soft delete support**: Deletions are synced and propagated
- **Partial failure handling**: Sync continues even if some operations fail
- **Credential security**: Secure storage with fallback mechanism

## Test Structure

### 1. Test Helpers (`test/helpers/test_helpers.dart`)
Utility functions for creating test data:
- `createTestReading()`: Creates a test BloodPressureReading with customizable fields
- `createTestReadingsList()`: Returns a list of varied test readings
- `createTestCredentials()`: Returns test Cloudflare credentials

### 2. Mock Services (`test/mocks/mock_services.dart`)
Mock implementations for testing:
- `MockCloudflareKVService`: Simulates Cloudflare KV operations
- `MockDatabaseService`: Simulates local database operations
- Test control methods to simulate failures and edge cases

### 3. Unit Tests

#### CloudflareKVService Tests (`test/services/cloudflare_kv_service_test.dart`)
Tests core Cloudflare KV service functionality:
- Credential management (store, retrieve, clear, validate)
- Reading operations (store, retrieve, delete, list)
- Connection testing
- Error handling
- Fallback storage mechanism

#### ManualSyncService Tests (`test/services/manual_sync_service_test.dart`)
Tests the sync orchestration logic:
- Sync availability checking
- Sync result validation
- Various sync scenarios (new, updates, deletions)
- Conflict resolution
- Error handling

### 4. Integration Tests (`test/integration/sync_integration_test.dart`)
End-to-end sync workflow tests:
- Complete sync from empty state
- Sync with deletions
- Conflict resolution in real scenarios
- Large dataset handling
- Data integrity validation
- Concurrent sync operations

### 5. Edge Cases Tests (`test/services/sync_edge_cases_test.dart`)
Comprehensive edge case and error scenario testing:
- Network and connectivity issues
- Data corruption handling
- Missing sync fields
- Invalid timestamps
- Duplicate IDs
- Storage limitations
- Sync recovery
- Security considerations

## Running Tests

### Run All Sync Tests
```bash
# Using the test runner script
dart test/run_sync_tests.dart

# Or directly with dart test
dart test test/services/cloudflare_kv_service_test.dart
dart test test/services/manual_sync_service_test.dart
dart test test/integration/sync_integration_test.dart
dart test test/services/sync_edge_cases_test.dart
```

### Run Individual Test Files
```bash
# Cloudflare KV service tests
dart test test/services/cloudflare_kv_service_test.dart

# Manual sync service tests
dart test test/services/manual_sync_service_test.dart

# Integration tests
dart test test/integration/sync_integration_test.dart

# Edge cases tests
dart test test/services/sync_edge_cases_test.dart
```

### Run with Coverage
```bash
dart test --coverage=coverage test/services/ test/integration/sync_integration_test.dart
```

## Test Coverage Areas

### ✅ Credential Management
- Storing and retrieving credentials
- Validation of credential format
- Secure storage with SharedPreferences fallback
- Credential clearing and reset

### ✅ Connection and Authentication
- Connection testing with valid credentials
- Handling invalid/expired credentials
- Network failure scenarios
- API authentication errors

### ✅ Data Operations
- Create, read, update, delete operations
- Bulk operations and batching
- Metadata handling (keys listing)
- Data serialization/deserialization

### ✅ Sync Algorithm
- Bidirectional sync logic
- Last-write-wins conflict resolution
- Soft delete propagation
- Incremental sync (only changes)
- State consistency maintenance

### ✅ Error Handling
- Network timeouts and failures
- Partial sync failures
- Data corruption scenarios
- Storage unavailability
- Retry mechanisms

### ✅ Edge Cases
- Empty datasets
- Large datasets (100+ readings)
- Duplicate IDs
- Invalid timestamps
- Special characters in data
- Very large text fields
- Null value handling

### ✅ Data Integrity
- Consistency across sync operations
- Data preservation during failures
- Atomic operations where possible
- Validation of synced data

## Key Test Scenarios

### 1. New User Setup
- No existing data locally or remotely
- First sync creates baseline
- Subsequent readings sync correctly

### 2. Existing Data Migration
- Local data exists, remote is empty
- Remote data exists, local is empty
- Both have data with conflicts

### 3. Conflict Resolution
- Same reading modified on both sides
- Last-write-wins based on `lastModified` timestamp
- Verification of winning data

### 4. Deletion Propagation
- Local deletions sync to remote
- Remote deletions sync to local
- Soft delete handling

### 5. Error Recovery
- Network interruptions during sync
- Partial failures with continuation
- Retry logic for failed operations

## Mock Configuration

The mock services provide fine-grained control for testing various scenarios:

```dart
// Simulate network failures
mockKv.setShouldFailConnection(true);
mockKv.setShouldFailStorage(true);
mockKv.setShouldFailRetrieval(true);

// Control database operations
mockDb.setShouldFailInsert(true);
mockDb.setShouldFailGetAll(true);
```

## Best Practices Tested

1. **Fail-Safe Operations**: Sync failures don't corrupt existing data
2. **Idempotent Operations**: Multiple sync attempts are safe
3. **Incremental Updates**: Only changed data is transferred
4. **Validation**: All data is validated before storage
5. **Security**: Credentials never exposed in logs or errors
6. **Performance**: Efficient handling of large datasets

## Troubleshooting Test Failures

1. **Mock Configuration**: Ensure mocks are properly configured before each test
2. **Asynchronous Operations**: Use `await` for all async operations
3. **Test Isolation**: Tests should not depend on each other's state
4. **Date Comparisons**: Be careful with timestamp precision in comparisons
5. **JSON Serialization**: Verify all fields are properly serialized

## Future Test Enhancements

1. **Performance Testing**: Measure sync times with large datasets
2. **Concurrency Testing**: Multiple sync operations simultaneously
3. **Rate Limiting**: Test behavior under API rate limits
4. **Data Retention**: Test old data cleanup policies
5. **Multi-Device Sync**: Simulate 3+ devices syncing

## Contributing

When adding new tests:
1. Use the helper functions for consistent test data
2. Follow the existing naming conventions
3. Include both positive and negative test cases
4. Add documentation for complex scenarios
5. Update this README with new coverage areas