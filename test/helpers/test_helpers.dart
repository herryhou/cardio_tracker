import 'package:cardio_tracker/models/blood_pressure_reading.dart';

class TestHelpers {
  static BloodPressureReading createTestReading({
    String? id,
    int systolic = 120,
    int diastolic = 80,
    int heartRate = 72,
    DateTime? timestamp,
    String? notes,
    DateTime? lastModified,
    bool isDeleted = false,
  }) {
    final now = DateTime.now();
    return BloodPressureReading(
      id: id ?? 'test_reading_${now.millisecondsSinceEpoch}',
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      timestamp: timestamp ?? now.subtract(const Duration(days: 1)),
      notes: notes,
      lastModified: lastModified ?? now,
      isDeleted: isDeleted,
    );
  }

  static List<BloodPressureReading> createTestReadingsList() {
    final now = DateTime.now();
    return [
      createTestReading(
        id: 'reading_1',
        systolic: 120,
        diastolic: 80,
        timestamp: now.subtract(const Duration(days: 5)),
        lastModified: now.subtract(const Duration(days: 5)),
      ),
      createTestReading(
        id: 'reading_2',
        systolic: 135,
        diastolic: 85,
        timestamp: now.subtract(const Duration(days: 3)),
        lastModified: now.subtract(const Duration(days: 3)),
      ),
      createTestReading(
        id: 'reading_3',
        systolic: 118,
        diastolic: 78,
        timestamp: now.subtract(const Duration(days: 1)),
        lastModified: now.subtract(const Duration(days: 1)),
        notes: 'Feeling good today',
      ),
      createTestReading(
        id: 'reading_4',
        systolic: 122,
        diastolic: 82,
        timestamp: now.subtract(const Duration(hours: 5)),
        lastModified: now.subtract(const Duration(hours: 5)),
        isDeleted: true, // Soft deleted reading
      ),
    ];
  }

  static Map<String, String> createTestCredentials({
    String accountId = 'test_account_id',
    String namespaceId = 'test_namespace_id',
    String apiToken = 'test_api_token_1234567890',
  }) {
    return {
      'accountId': accountId,
      'namespaceId': namespaceId,
      'apiToken': apiToken,
    };
  }
}