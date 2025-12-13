/// Test runner for Cloudflare sync functionality
/// Run this with: dart test/run_sync_tests.dart
///
/// This script runs all sync-related tests and provides a summary of results.

import 'dart:io';

void main(List<String> args) async {
  print('🧪 Running Cloudflare Sync Tests\n');
  print('=' * 50);

  // List of test files to run
  final testFiles = [
    'test/services/cloudflare_kv_service_test.dart',
    'test/services/manual_sync_service_test.dart',
    'test/integration/sync_integration_test.dart',
    'test/services/sync_edge_cases_test.dart',
  ];

  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  final failedFiles = <String>[];

  for (final testFile in testFiles) {
    print('\n📂 Running: $testFile');
    print('-' * 50);

    // Run the test file
    final process = await Process.start(
      'dart',
      ['test', testFile, '--reporter=compact'],
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await process.exitCode;

    if (exitCode == 0) {
      passedTests++;
      print('✅ $testFile PASSED');
    } else {
      failedTests++;
      failedFiles.add(testFile);
      print('❌ $testFile FAILED');
    }
  }

  // Print summary
  print('\n' + '=' * 50);
  print('📊 Test Summary');
  print('=' * 50);
  print('Total test suites: ${testFiles.length}');
  print('Passed: $passedTests');
  print('Failed: $failedTests');

  if (failedTests > 0) {
    print('\n❌ Failed test files:');
    for (final file in failedFiles) {
      print('  - $file');
    }
    exitCode = 1;
  } else {
    print('\n✅ All sync tests passed!');
    exitCode = 0;
  }

  // Test coverage checklist
  print('\n📋 Coverage Checklist:');
  print('=' * 50);
  print('☐ Credential storage and retrieval');
  print('☐ Connection testing');
  print('☐ Reading CRUD operations');
  print('☐ Bidirectional sync');
  print('☐ Conflict resolution (last-write-wins)');
  print('☐ Soft delete handling');
  print('☐ Error handling and recovery');
  print('☐ Network failure scenarios');
  print('☐ Data integrity validation');
  print('☐ Edge cases and boundary conditions');
  print('☐ Security considerations');

  exit(exitCode);
}

// Helper class to track test results
class TestResult {
  final String file;
  final bool passed;
  final String? error;

  TestResult({required this.file, required this.passed, this.error});

  @override
  String toString() {
    if (passed) {
      return '✅ $file';
    } else {
      return '❌ $file: ${error ?? 'Unknown error'}';
    }
  }
}