import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../mappers/blood_pressure_reading_mapper.dart';

class CloudflareKVService {
  static const String _accountIdKey = 'cloudflare_account_id';
  static const String _namespaceIdKey = 'cloudflare_namespace_id';
  static const String _apiTokenKey = 'cloudflare_api_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked,
      synchronizable: false,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Store credentials
  Future<void> setCredentials({
    required String accountId,
    required String namespaceId,
    required String apiToken,
  }) async {
    try {
      print('CloudflareKVService: Starting to store credentials...');

      // Validate inputs before storing
      if (accountId.trim().isEmpty) {
        print('CloudflareKVService: Validation failed - Account ID is empty');
        throw Exception('Account ID cannot be empty');
      }
      if (namespaceId.trim().isEmpty) {
        print('CloudflareKVService: Validation failed - Namespace ID is empty');
        throw Exception('Namespace ID cannot be empty');
      }
      if (apiToken.trim().isEmpty) {
        print('CloudflareKVService: Validation failed - API token is empty');
        throw Exception('API token cannot be empty');
      }

      print('CloudflareKVService: Validation passed, storing credentials...');
      print('CloudflareKVService: Account ID: ${accountId.trim()}');
      print('CloudflareKVService: Namespace ID: ${namespaceId.trim()}');
      print(
          'CloudflareKVService: API Token: ${apiToken.trim().substring(0, 10)}...');

      // Try secure storage first
      try {
        await _secureStorage.write(key: _accountIdKey, value: accountId.trim());
        print('CloudflareKVService: Stored Account ID successfully');

        await _secureStorage.write(
            key: _namespaceIdKey, value: namespaceId.trim());
        print('CloudflareKVService: Stored Namespace ID successfully');

        await _secureStorage.write(key: _apiTokenKey, value: apiToken.trim());
        print('CloudflareKVService: Stored API Token successfully');
      } catch (e) {
        // Fallback to SharedPreferences if keychain fails
        print(
            'CloudflareKVService: Keychain storage failed, using fallback: ${e.toString()}');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accountIdKey, accountId.trim());
        await prefs.setString(_namespaceIdKey, namespaceId.trim());
        await prefs.setString(_apiTokenKey, apiToken.trim());
        print(
            'CloudflareKVService: Stored credentials using SharedPreferences fallback');
      }

      // Verify storage was successful
      print('CloudflareKVService: Verifying stored credentials...');
      final storedCreds = await getCredentials();
      if (storedCreds == null) {
        print(
            'CloudflareKVService: Verification failed - could not retrieve stored credentials');
        throw Exception('Failed to store credentials - verification failed');
      }

      print(
          'CloudflareKVService: Credentials stored and verified successfully');
    } catch (e, stackTrace) {
      print('CloudflareKVService: Error storing credentials: ${e.toString()}');
      print('CloudflareKVService: Stack trace: $stackTrace');
      throw Exception('Failed to store credentials: ${e.toString()}');
    }
  }

  // Get credentials
  Future<Map<String, String>?> getCredentials() async {
    try {
      print('CloudflareKVService: Retrieving stored credentials...');
      String? accountId, namespaceId, apiToken;

      // Try secure storage first
      try {
        accountId = await _secureStorage.read(key: _accountIdKey);
        namespaceId = await _secureStorage.read(key: _namespaceIdKey);
        apiToken = await _secureStorage.read(key: _apiTokenKey);
        print(
            'CloudflareKVService: Retrieved from keychain - Account ID: ${accountId != null ? 'found' : 'not found'}');
      } catch (e) {
        print(
            'CloudflareKVService: Keychain read failed, trying fallback: ${e.toString()}');
        // Fallback to SharedPreferences if keychain fails
        final prefs = await SharedPreferences.getInstance();
        accountId = prefs.getString(_accountIdKey);
        namespaceId = prefs.getString(_namespaceIdKey);
        apiToken = prefs.getString(_apiTokenKey);
        print('CloudflareKVService: Retrieved from SharedPreferences fallback');
        return _validateAndReturnCredentials(accountId, namespaceId, apiToken);
      }

      // If keychain returned null for any credential, also try fallback
      if (accountId == null || namespaceId == null || apiToken == null) {
        print(
            'CloudflareKVService: Some credentials missing from keychain, trying fallback');
        final prefs = await SharedPreferences.getInstance();
        accountId = accountId ?? prefs.getString(_accountIdKey);
        namespaceId = namespaceId ?? prefs.getString(_namespaceIdKey);
        apiToken = apiToken ?? prefs.getString(_apiTokenKey);
        print('CloudflareKVService: Retrieved from SharedPreferences fallback');
      }

      return _validateAndReturnCredentials(accountId, namespaceId, apiToken);
    } catch (e, stackTrace) {
      print(
          'CloudflareKVService: Error retrieving credentials: ${e.toString()}');
      print('CloudflareKVService: Stack trace: $stackTrace');
      return null;
    }
  }

  // Helper method to validate and return credentials
  Map<String, String>? _validateAndReturnCredentials(
      String? accountId, String? namespaceId, String? apiToken) {
    print(
        'CloudflareKVService: Retrieved - Account ID: ${accountId != null ? 'found' : 'not found'}');
    print(
        'CloudflareKVService: Retrieved - Namespace ID: ${namespaceId != null ? 'found' : 'not found'}');
    print(
        'CloudflareKVService: Retrieved - API Token: ${apiToken != null ? 'found' : 'not found'}');

    if (accountId == null || namespaceId == null || apiToken == null) {
      print('CloudflareKVService: One or more credentials are missing');
      return null;
    }

    print('CloudflareKVService: All credentials retrieved successfully');
    return {
      'accountId': accountId,
      'namespaceId': namespaceId,
      'apiToken': apiToken,
    };
  }

  // Clear credentials
  Future<void> clearCredentials() async {
    // Try to clear from secure storage
    try {
      await _secureStorage.delete(key: _accountIdKey);
      await _secureStorage.delete(key: _namespaceIdKey);
      await _secureStorage.delete(key: _apiTokenKey);
    } catch (e) {
      print(
          'CloudflareKVService: Keychain delete failed, clearing fallback: ${e.toString()}');
    }

    // Also clear from SharedPreferences fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accountIdKey);
      await prefs.remove(_namespaceIdKey);
      await prefs.remove(_apiTokenKey);
      print(
          'CloudflareKVService: Cleared credentials from both keychain and fallback');
    } catch (e) {
      print(
          'CloudflareKVService: Error clearing fallback credentials: ${e.toString()}');
    }
  }

  // Check if configured
  Future<bool> isConfigured() async {
    final creds = await getCredentials();
    return creds != null;
  }

  // Store a reading
  Future<void> storeReading(BloodPressureReading reading) async {
    final creds = await getCredentials();
    if (creds == null) throw Exception('Cloudflare KV not configured');

    final key = 'bp_reading_${reading.id}';
    final value = jsonEncode(reading.toJson());

    final url = Uri.parse(
        'https://api.cloudflare.com/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/values/$key');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${creds['apiToken']}',
        'Content-Type': 'application/json',
      },
      body: value,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to store reading: ${response.body}');
    }
  }

  // Retrieve a reading
  Future<BloodPressureReading?> retrieveReading(String readingId) async {
    final creds = await getCredentials();
    if (creds == null) throw Exception('Cloudflare KV not configured');

    final key = 'bp_reading_$readingId';
    final url = Uri.parse(
        'https://api.cloudflare.com/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/values/$key');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${creds['apiToken']}',
      },
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to retrieve reading: ${response.body}');
    }

    return BloodPressureReadingMapper.fromJsonString(response.body);
  }

  // Delete a reading
  Future<void> deleteReading(String readingId) async {
    final creds = await getCredentials();
    if (creds == null) throw Exception('Cloudflare KV not configured');

    final key = 'bp_reading_$readingId';
    final url = Uri.parse(
        'https://api.cloudflare.com/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/values/$key');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${creds['apiToken']}',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Failed to delete reading: ${response.body}');
    }
  }

  // List all reading keys with metadata
  Future<Map<String, int>> listReadingKeys() async {
    final creds = await getCredentials();
    if (creds == null) throw Exception('Cloudflare KV not configured');

    final url = Uri.https(
      'api.cloudflare.com',
      '/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/keys',
      {'prefix': 'bp_reading_'},
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${creds['apiToken']}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to list keys: ${response.body}');
    }

    final json = jsonDecode(response.body);
    final result = json['result'] as List;

    final Map<String, int> keyMetadata = {};
    for (final item in result) {
      if (item['name'].toString().startsWith('bp_reading_')) {
        final readingId =
            item['name'].toString().substring('bp_reading_'.length);
        final expiration = item['expiration'] as int?;
        keyMetadata[readingId] = expiration ?? 0;
      }
    }

    return keyMetadata;
  }

  // Test connection to Cloudflare KV
  Future<bool> testConnection() async {
    try {
      final creds = await getCredentials();
      if (creds == null) {
        print(
            'CloudflareKVService: Test connection failed - no credentials stored');
        return false;
      }

      print(
          'CloudflareKVService: Testing connection with Account ID: ${creds['accountId']}, Namespace ID: ${creds['namespaceId']}');

      final url = Uri.https(
        'api.cloudflare.com',
        '/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/keys',
        {'prefix': 'bp_reading_'},
      );

      print(
          'CloudflareKVService: Making request to: ${creds['apiToken'] != null ? url.toString().replaceAll(creds['apiToken']!, '[REDACTED]') : url.toString()}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${creds['apiToken']}',
        },
      );

      print(
          'CloudflareKVService: Response status code: ${response.statusCode}');
      print('CloudflareKVService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final success = json['success'] as bool? ?? false;

        if (success) {
          print('CloudflareKVService: Connection test successful');
          return true;
        } else {
          final errors = json['errors'] as List? ?? [];
          print(
              'CloudflareKVService: Connection test failed - API returned success=false, errors: $errors');
          return false;
        }
      } else {
        print(
            'CloudflareKVService: Connection test failed - HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('CloudflareKVService: Connection test error: ${e.toString()}');
      print('CloudflareKVService: Stack trace: $stackTrace');
      return false;
    }
  }
}
