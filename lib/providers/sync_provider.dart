import 'package:flutter/foundation.dart';
import '../models/sync_status.dart';
import '../models/blood_pressure_reading.dart';
import '../services/database_service.dart';
import '../services/google_sheets_service.dart';

class SyncProvider extends ChangeNotifier {
  final DatabaseService databaseService;
  final GoogleSheetsService googleSheetsService;

  SyncStatus? _syncStatus;
  bool _isSyncing = false;
  bool _isAuthenticated = false;
  String? _error;

  SyncProvider({
    required this.databaseService,
    required this.googleSheetsService,
  }) {
    _loadSyncStatus();
    _checkAuthStatus();
  }

  // Getters
  SyncStatus? get syncStatus => _syncStatus;
  bool get isSyncing => _isSyncing;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  bool get needsSync => _syncStatus?.needsSync ?? false;
  bool get hasError => _syncStatus?.hasError ?? false;
  DateTime? get lastSyncTime => _syncStatus?.lastSyncTime;

  // Authentication methods
  Future<bool> signIn() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await googleSheetsService.signIn();
      _isAuthenticated = result != null;

      if (_isAuthenticated) {
        await _updateSyncStatus(SyncState.success);
      }

      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _setError('Failed to sign in: ${e.toString()}');
      await _updateSyncStatus(SyncState.error, errorMessage: e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await googleSheetsService.signOut();
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Sync methods
  Future<void> syncToGoogleSheets() async {
    if (!_isAuthenticated) {
      _setError('Not authenticated. Please sign in first.');
      return;
    }

    _setLoading(true);
    _clearError();
    await _updateSyncStatus(SyncState.syncing);

    try {
      final spreadsheetId = await googleSheetsService.getSpreadsheetId();

      if (spreadsheetId == null) {
        throw Exception('No spreadsheet configured. Please set up Google Sheets first.');
      }

      // Get all readings from local database
      final readings = await databaseService.getAllReadings();

      if (readings.isEmpty) {
        await _updateSyncStatus(SyncState.success);
        return;
      }

      // Sync each reading to Google Sheets
      for (final reading in readings) {
        await googleSheetsService.syncReadingToGoogleSheets(reading, spreadsheetId);
      }

      // Mark all readings as synced
      await _updateSyncStatus(SyncState.success, pendingCount: 0);

    } catch (e) {
      await _updateSyncStatus(SyncState.error, errorMessage: e.toString());
      _setError('Sync failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncFromGoogleSheets() async {
    if (!_isAuthenticated) {
      _setError('Not authenticated. Please sign in first.');
      return;
    }

    _setLoading(true);
    _clearError();
    await _updateSyncStatus(SyncState.syncing);

    try {
      final spreadsheetId = await googleSheetsService.getSpreadsheetId();

      if (spreadsheetId == null) {
        throw Exception('No spreadsheet configured. Please set up Google Sheets first.');
      }

      // Fetch readings from Google Sheets
      final sheetsReadings = await googleSheetsService.fetchAllReadingsFromGoogleSheets(spreadsheetId);

      // Get local readings
      final localReadings = await databaseService.getAllReadings();

      // Merge logic: keep the most recent version of each reading
      final mergedReadings = <String, BloodPressureReading>{};

      // Add local readings first
      for (final reading in localReadings) {
        mergedReadings[reading.id] = reading;
      }

      // Add/overwrite with Google Sheets readings if they're newer
      for (final sheetsReading in sheetsReadings) {
        final existingReading = mergedReadings[sheetsReading.id];

        if (existingReading == null ||
            sheetsReading.timestamp.isAfter(existingReading.timestamp)) {
          mergedReadings[sheetsReading.id] = sheetsReading;
        }
      }

      // Save merged readings back to database
      for (final reading in mergedReadings.values) {
        await databaseService.insertReading(reading);
      }

      await _updateSyncStatus(SyncState.success, pendingCount: 0);

    } catch (e) {
      await _updateSyncStatus(SyncState.error, errorMessage: e.toString());
      _setError('Import failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> createNewSpreadsheet(String title) async {
    if (!_isAuthenticated) {
      throw Exception('Not authenticated. Please sign in first.');
    }

    _setLoading(true);
    _clearError();

    try {
      final spreadsheetId = await googleSheetsService.createSpreadsheetWithTitle(title);

      // Update sync status after creating spreadsheet
      await _updateSyncStatus(SyncState.success);

      return spreadsheetId;
    } catch (e) {
      _setError('Failed to create spreadsheet: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setSpreadsheetId(String spreadsheetId) async {
    try {
      await googleSheetsService.saveSpreadsheetId(spreadsheetId);
      await _updateSyncStatus(SyncState.success);
    } catch (e) {
      _setError('Failed to save spreadsheet ID: ${e.toString()}');
      rethrow;
    }
  }

  Future<String?> getSpreadsheetId() async {
    try {
      return await googleSheetsService.getSpreadsheetId();
    } catch (e) {
      _setError('Failed to get spreadsheet ID: ${e.toString()}');
      return null;
    }
  }

  // Status tracking methods
  Future<void> markReadingAsPendingSync() async {
    final currentPending = _syncStatus?.pendingReadingsCount ?? 0;
    await _updateSyncStatus(
      _syncStatus?.lastSyncState ?? SyncState.idle,
      pendingCount: currentPending + 1,
    );
  }

  Future<void> refreshSyncStatus() async {
    await _loadSyncStatus();
    await _checkAuthStatus();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  Future<void> _loadSyncStatus() async {
    try {
      _syncStatus = await databaseService.getSyncStatus();

      if (_syncStatus == null) {
        // Create initial sync status
        _syncStatus = SyncStatus(
          id: 'sync-status-1',
          lastSyncState: SyncState.idle,
          pendingReadingsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await databaseService.insertSyncStatus(_syncStatus!);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load sync status: ${e.toString()}');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final spreadsheetId = await googleSheetsService.getSpreadsheetId();
      _isAuthenticated = spreadsheetId != null;
    } catch (e) {
      _isAuthenticated = false;
    }
  }

  Future<void> _updateSyncStatus(
    SyncState state, {
    DateTime? lastSyncTime,
    String? errorMessage,
    int? pendingCount,
  }) async {
    final now = DateTime.now();

    _syncStatus = _syncStatus?.copyWith(
      lastSyncState: state,
      lastSyncTime: lastSyncTime ?? (state == SyncState.success ? now : _syncStatus?.lastSyncTime),
      errorMessage: errorMessage,
      pendingReadingsCount: pendingCount ?? _syncStatus?.pendingReadingsCount ?? 0,
      updatedAt: now,
    ) ?? SyncStatus(
      id: 'sync-status-1',
      lastSyncState: state,
      lastSyncTime: lastSyncTime,
      errorMessage: errorMessage,
      pendingReadingsCount: pendingCount ?? 0,
      createdAt: now,
      updatedAt: now,
    );

    try {
      if (_syncStatus!.id == 'sync-status-1') {
        await databaseService.insertSyncStatus(_syncStatus!);
      } else {
        await databaseService.updateSyncStatus(_syncStatus!);
      }
    } catch (e) {
      _setError('Failed to update sync status: ${e.toString()}');
    }

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isSyncing = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}