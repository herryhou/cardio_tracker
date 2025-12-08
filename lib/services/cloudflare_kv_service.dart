import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/blood_pressure_reading.dart';

class CloudflareKVService {
  static const String _accountIdKey = 'cloudflare_account_id';
  static const String _namespaceIdKey = 'cloudflare_namespace_id';
  static const String _apiTokenKey = 'cloudflare_api_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Store credentials
  Future<void> setCredentials({
    required String accountId,
    required String namespaceId,
    required String apiToken,
  }) async {
    await _secureStorage.write(key: _accountIdKey, value: accountId);
    await _secureStorage.write(key: _namespaceIdKey, value: namespaceId);
    await _secureStorage.write(key: _apiTokenKey, value: apiToken);
  }

  // Get credentials
  Future<Map<String, String>?> getCredentials() async {
    final accountId = await _secureStorage.read(key: _accountIdKey);
    final namespaceId = await _secureStorage.read(key: _namespaceIdKey);
    final apiToken = await _secureStorage.read(key: _apiTokenKey);

    if (accountId == null || namespaceId == null || apiToken == null) {
      return null;
    }

    return {
      'accountId': accountId,
      'namespaceId': namespaceId,
      'apiToken': apiToken,
    };
  }

  // Clear credentials
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _accountIdKey);
    await _secureStorage.delete(key: _namespaceIdKey);
    await _secureStorage.delete(key: _apiTokenKey);
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
      'https://api.cloudflare.com/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/values/$key'
    );

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
      'https://api.cloudflare.com/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/values/$key'
    );

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

    final json = jsonDecode(response.body);
    return BloodPressureReading.fromJson(json);
  }

  // Delete a reading
  Future<void> deleteReading(String readingId) async {
    final creds = await getCredentials();
    if (creds == null) throw Exception('Cloudflare KV not configured');

    final key = 'bp_reading_$readingId';
    final url = Uri.parse(
      'https://api.cloudflare.com/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/values/$key'
    );

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

    final url = Uri.parse(
      'https://api.cloudflare.com/client/v4/accounts/${creds['accountId']}/storage/kv/namespaces/${creds['namespaceId']}/keys?prefix=bp_reading_'
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
        final readingId = item['name'].toString().substring('bp_reading_'.length);
        final expiration = item['expiration'] as int?;
        keyMetadata[readingId] = expiration ?? 0;
      }
    }

    return keyMetadata;
  }
}