import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/blood_pressure_reading.dart';
import 'package:googleapis_auth/auth.dart' as auth;

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsScope];
  static const _storage = FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
    clientId: 'YOUR_CLIENT_ID_HERE.apps.googleusercontent.com',
  );

  /// Get authenticated HTTP client for Google Sheets API
  Future<http.Client> _getAuthenticatedClient() async {
    final googleUser = await _googleSignIn.signInSilently();
    if (googleUser == null) {
      throw Exception('User not authenticated');
    }

    final headers = await googleUser.authHeaders;
    final accessToken = headers['Authorization']?.replaceFirst('Bearer ', '');

    if (accessToken == null) {
      throw Exception('Failed to get access token');
    }

    // Create an authenticated client using the access token
    final credentials = auth.AccessCredentials(
      auth.AccessToken(
        'Bearer',
        accessToken,
        DateTime.now().add(const Duration(hours: 1)), // Token expires in 1 hour
      ),
      null, // No refresh token for Google Sign-In
      _scopes,
    );

    return auth.authenticatedClient(
      http.Client(),
      credentials,
    );
  }

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'google_sheets_spreadsheet_id');
  }

  /// Save spreadsheet ID to secure storage
  Future<void> saveSpreadsheetId(String spreadsheetId) async {
    await _storage.write(key: 'google_sheets_spreadsheet_id', value: spreadsheetId);
  }

  /// Get spreadsheet ID from secure storage
  Future<String?> getSpreadsheetId() async {
    return await _storage.read(key: 'google_sheets_spreadsheet_id');
  }

  /// Load Google credentials from assets
  Future<Map<String, dynamic>> _loadCredentials() async {
    try {
      final String credentialsJson =
          await rootBundle.loadString('assets/google-credentials.json');
      return json.decode(credentialsJson);
    } catch (e) {
      throw Exception('Failed to load Google credentials: $e');
    }
  }

  /// Read data from a specific sheet
  Future<List<List<dynamic>>> readSheet(String spreadsheetId, String range) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        range,
      );

      client.close();
      return response.values ?? [];
    } catch (e) {
      throw Exception('Failed to read sheet: $e');
    }
  }

  /// Write a single row to a specific sheet
  Future<void> writeRow(
    String spreadsheetId,
    String range,
    List<dynamic> values,
  ) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = SheetsApi(client);

      final valueRange = ValueRange(values: [values]);

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );

      client.close();
    } catch (e) {
      throw Exception('Failed to write row: $e');
    }
  }

  /// Update a specific row in a sheet
  Future<void> updateRow(
    String spreadsheetId,
    String range,
    List<dynamic> values,
  ) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = SheetsApi(client);

      final valueRange = ValueRange(values: [values]);

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );

      client.close();
    } catch (e) {
      throw Exception('Failed to update row: $e');
    }
  }

  /// Create a new spreadsheet with specified title and initial headers
  Future<String> createSpreadsheetWithTitle(String title) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = SheetsApi(client);

      final spreadsheet = Spreadsheet(
        properties: SpreadsheetProperties(
          title: title,
        ),
        sheets: [
          Sheet(
            properties: SheetProperties(
              title: 'Blood Pressure Readings',
            ),
            data: [
              GridData(
                rowData: [
                  RowData(
                    values: [
                      CellData(userEnteredValue: ExtendedValue(stringValue: 'Timestamp')),
                      CellData(userEnteredValue: ExtendedValue(stringValue: 'Systolic')),
                      CellData(userEnteredValue: ExtendedValue(stringValue: 'Diastolic')),
                      CellData(userEnteredValue: ExtendedValue(stringValue: 'Heart Rate')),
                      CellData(userEnteredValue: ExtendedValue(stringValue: 'Notes')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final response = await sheetsApi.spreadsheets.create(spreadsheet);
      client.close();

      final spreadsheetId = response.spreadsheetId!;
      await saveSpreadsheetId(spreadsheetId);

      return spreadsheetId;
    } catch (e) {
      throw Exception('Failed to create spreadsheet: $e');
    }
  }

  /// Convert BloodPressureReading to Google Sheets row format
  static List<dynamic> readingToRow(BloodPressureReading reading) {
    return [
      DateFormat('yyyy-MM-dd HH:mm:ss').format(reading.timestamp),
      reading.systolic,
      reading.diastolic,
      reading.heartRate,
      reading.notes ?? '',
    ];
  }

  /// Convert Google Sheets row to BloodPressureReading
  static BloodPressureReading rowToReading(List<dynamic> row, String id) {
    try {
      final timestampStr = row[0] as String;
      final systolic = row[1] as int;
      final diastolic = row[2] as int;
      final heartRate = row[3] as int;
      final notes = row.length > 4 ? row[4] as String? : '';

      return BloodPressureReading(
        id: id,
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').parse(timestampStr),
        notes: notes?.isEmpty == true ? '' : notes,
      );
    } catch (e) {
      throw Exception('Failed to convert row to reading: $e');
    }
  }

  /// Sync a blood pressure reading to Google Sheets
  Future<void> syncReadingToGoogleSheets(
    BloodPressureReading reading,
    String spreadsheetId,
  ) async {
    try {
      final row = readingToRow(reading);
      await writeRow(
        spreadsheetId,
        'Blood Pressure Readings!A:E',
        row,
      );
    } catch (e) {
      throw Exception('Failed to sync reading to Google Sheets: $e');
    }
  }

  /// Fetch all readings from Google Sheets
  Future<List<BloodPressureReading>> fetchAllReadingsFromGoogleSheets(
    String spreadsheetId,
  ) async {
    try {
      final rows = await readSheet(
        spreadsheetId,
        'Blood Pressure Readings!A:E',
      );

      // Skip header row, convert remaining rows to readings
      final dataRows = rows.skip(1).toList();
      return dataRows.asMap().entries.map((entry) {
        final rowIndex = entry.key + 2; // +2 to account for header and 0-based indexing
        final row = entry.value;
        return rowToReading(row, 'google_sheets_$rowIndex');
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch readings from Google Sheets: $e');
    }
  }
}