import 'package:flutter/foundation.dart';
import '../domain/entities/blood_pressure_reading.dart';

/// Provider for managing synchronized selection between dual charts
class DualChartProvider extends ChangeNotifier {
  BloodPressureReading? _selectedReading;

  /// Currently selected blood pressure reading
  BloodPressureReading? get selectedReading => _selectedReading;

  /// Select a reading and notify both charts
  void selectReading(BloodPressureReading? reading) {
    if (_selectedReading != reading) {
      _selectedReading = reading;
      notifyListeners();
    }
  }

  /// Clear selection
  void clearSelection() {
    if (_selectedReading != null) {
      _selectedReading = null;
      notifyListeners();
    }
  }

  /// Check if a reading is currently selected
  bool isSelected(BloodPressureReading reading) {
    return _selectedReading == reading;
  }

  /// Check if any reading is selected
  bool get hasSelection => _selectedReading != null;
}