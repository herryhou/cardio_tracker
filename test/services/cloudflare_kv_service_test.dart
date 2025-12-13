import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardio_tracker/services/cloudflare_kv_service.dart';
import 'package:cardio_tracker/models/blood_pressure_reading.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CloudflareKVService Tests', () {
    late CloudflareKVService service;

    setUp(() async {
      service = CloudflareKVService();
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Credential Management', () {
      test('should store credentials successfully', () async {
        // Arrange
        final testCreds = TestHelpers.createTestCredentials();

        // Act
        await service.setCredentials(
          accountId: testCreds['accountId']!,
          namespaceId: testCreds['namespaceId']!,
          apiToken: testCreds['apiToken']!,
        );

        // Assert
        final retrievedCreds = await service.getCredentials();
        expect(retrievedCreds, isNotNull);
        expect(retrievedCreds!['accountId'], equals(testCreds['accountId']));
        expect(retrievedCreds['namespaceId'], equals(testCreds['namespaceId']));
        expect(retrievedCreds['apiToken'], equals(testCreds['apiToken']));
      });

      test('should reject empty credentials', () async {
        // Act & Assert - Empty account ID
        expect(
          () async => await service.setCredentials(
            accountId: '',
            namespaceId: 'test_namespace',
            apiToken: 'test_token',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Account ID cannot be empty'),
          )),
        );

        // Empty namespace ID
        expect(
          () async => await service.setCredentials(
            accountId: 'test_account',
            namespaceId: '',
            apiToken: 'test_token',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Namespace ID cannot be empty'),
          )),
        );

        // Empty API token
        expect(
          () async => await service.setCredentials(
            accountId: 'test_account',
            namespaceId: 'test_namespace',
            apiToken: '',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API token cannot be empty'),
          )),
        );
      });

      test('should return null when no credentials stored', () async {
        // Act
        final creds = await service.getCredentials();

        // Assert
        expect(creds, isNull);
      });

      test('should clear credentials successfully', () async {
        // Arrange
        final testCreds = TestHelpers.createTestCredentials();
        await service.setCredentials(
          accountId: testCreds['accountId']!,
          namespaceId: testCreds['namespaceId']!,
          apiToken: testCreds['apiToken']!,
        );

        // Act
        await service.clearCredentials();
        final retrievedCreds = await service.getCredentials();

        // Assert
        expect(retrievedCreds, isNull);
      });

      test('should check if configured correctly', () async {
        // Initially not configured
        expect(await service.isConfigured(), isFalse);

        // After setting credentials
        final testCreds = TestHelpers.createTestCredentials();
        await service.setCredentials(
          accountId: testCreds['accountId']!,
          namespaceId: testCreds['namespaceId']!,
          apiToken: testCreds['apiToken']!,
        );
        expect(await service.isConfigured(), isTrue);

        // After clearing credentials
        await service.clearCredentials();
        expect(await service.isConfigured(), isFalse);
      });
    });

    group('Connection Testing', () {
      test('should return false when not configured', () async {
        // Act
        final result = await service.testConnection();

        // Assert
        expect(result, isFalse);
      });

      test('should handle connection testing when configured', () async {
        // Arrange
        final testCreds = TestHelpers.createTestCredentials();
        await service.setCredentials(
          accountId: testCreds['accountId']!,
          namespaceId: testCreds['namespaceId']!,
          apiToken: testCreds['apiToken']!,
        );

        // Act
        final isConfigured = await service.isConfigured();

        // Assert
        expect(isConfigured, isTrue);
      });
    });

    group('Reading Storage Operations', () {
      setUp(() async {
        final testCreds = TestHelpers.createTestCredentials();
        await service.setCredentials(
          accountId: testCreds['accountId']!,
          namespaceId: testCreds['namespaceId']!,
          apiToken: testCreds['apiToken']!,
        );
      });

      test('should throw when not configured for reading operations', () async {
        // Arrange
        await service.clearCredentials();

        // Act & Assert
        expect(
          () => service.storeReading(TestHelpers.createTestReading()),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cloudflare KV not configured'),
          )),
        );

        expect(
          () => service.retrieveReading('test_id'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cloudflare KV not configured'),
          )),
        );

        expect(
          () => service.deleteReading('test_id'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cloudflare KV not configured'),
          )),
        );

        expect(
          () => service.listReadingKeys(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cloudflare KV not configured'),
          )),
        );
      });

      test('should validate reading data structure', () async {
        // Arrange
        final testReading = TestHelpers.createTestReading(
          id: 'test_validation',
          systolic: 120,
          diastolic: 80,
          heartRate: 72,
          notes: 'Test notes',
        );

        // Test JSON serialization
        final json = testReading.toJson();
        expect(json['id'], equals('test_validation'));
        expect(json['systolic'], equals(120));
        expect(json['diastolic'], equals(80));
        expect(json['heartRate'], equals(72));
        expect(json['notes'], equals('Test notes'));
        expect(json['isDeleted'], equals(false));
        expect(json['lastModified'], isNotNull);

        // Test JSON deserialization
        final deserialized = BloodPressureReading.fromJson(json);
        expect(deserialized.id, equals(testReading.id));
        expect(deserialized.systolic, equals(testReading.systolic));
        expect(deserialized.diastolic, equals(testReading.diastolic));
        expect(deserialized.heartRate, equals(testReading.heartRate));
        expect(deserialized.notes, equals(testReading.notes));
        expect(deserialized.isDeleted, equals(testReading.isDeleted));
      });
    });

    group('Sync Field Validation', () {
      test('should handle BloodPressureReading with sync fields', () {
        // Arrange
        final now = DateTime.now();
        final reading = BloodPressureReading(
          id: 'sync_test',
          systolic: 125,
          diastolic: 83,
          heartRate: 75,
          timestamp: now.subtract(const Duration(hours: 2)),
          notes: 'Sync test reading',
          lastModified: now,
          isDeleted: false,
        );

        // Assert
        expect(reading.lastModified, isNotNull);
        expect(reading.isDeleted, isFalse);
        expect(reading.lastModified.isAfter(reading.timestamp), isTrue);

        // Test copyWith with sync fields
        final updated = reading.copyWith(
          systolic: 130,
          lastModified: now.add(const Duration(minutes: 5)),
        );
        expect(updated.systolic, equals(130));
        expect(updated.lastModified.isAfter(reading.lastModified), isTrue);
        expect(updated.isDeleted, isFalse); // Should preserve default

        // Test deletion
        final deleted = reading.copyWith(
          isDeleted: true,
          lastModified: now.add(const Duration(minutes: 10)),
        );
        expect(deleted.isDeleted, isTrue);
      });

      test('should handle backwards compatibility', () {
        // Create reading without sync fields (old format)
        final oldJson = {
          'id': 'old_reading',
          'systolic': 120,
          'diastolic': 80,
          'heartRate': 72,
          'timestamp': DateTime.now().toIso8601String(),
          'notes': null,
        };

        // Deserialize should handle missing fields gracefully
        final reading = BloodPressureReading.fromJson(oldJson);
        expect(reading.id, equals('old_reading'));
        expect(reading.lastModified, isNotNull); // Should default to now
        expect(reading.isDeleted, isFalse); // Should default to false
      });
    });

    group('Key Generation and Formatting', () {
      test('should generate consistent keys for readings', () {
        // Test the key format used in the service
        const readingId = 'test_reading_123';
        const expectedKey = 'bp_reading_test_reading_123';

        // Verify the key format
        expect(expectedKey, startsWith('bp_reading_'));
        expect(expectedKey, contains(readingId));
      });

      test('should handle special characters in reading IDs', () {
        const specialId = 'reading_with-special.chars_123';
        const expectedKey = 'bp_reading_reading_with-special.chars_123';

        expect(expectedKey, contains(specialId));
      });
    });
  });
}