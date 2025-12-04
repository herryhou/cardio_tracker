import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key});

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blood Pressure Reading'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveReading,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Selection
              _buildDateTimeCard(),
              const SizedBox(height: 16),

              // Blood Pressure Input
              _buildBloodPressureCard(),
              const SizedBox(height: 16),

              // Heart Rate Input
              _buildHeartRateCard(),
              const SizedBox(height: 16),

              // Notes Input
              _buildNotesCard(),
              const SizedBox(height: 24),

              // Reference Information
              _buildReferenceCard(),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveReading,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text('Save Reading'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Date & Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                _formatDate(_selectedDateTime),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(_formatTime(_selectedDateTime)),
              trailing: const Icon(Icons.edit),
              onTap: _selectDateTime,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Blood Pressure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _systolicController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Systolic',
                      suffixText: 'mmHg',
                      border: OutlineInputBorder(),
                      helperText: '90-180',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter systolic pressure';
                      }
                      final systolic = int.tryParse(value);
                      if (systolic == null) {
                        return 'Please enter a valid number';
                      }
                      if (systolic < 70 || systolic > 250) {
                        return 'Please enter a value between 70-250';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _diastolicController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Diastolic',
                      suffixText: 'mmHg',
                      border: OutlineInputBorder(),
                      helperText: '60-120',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter diastolic pressure';
                      }
                      final diastolic = int.tryParse(value);
                      if (diastolic == null) {
                        return 'Please enter a valid number';
                      }
                      if (diastolic < 40 || diastolic > 150) {
                        return 'Please enter a value between 40-150';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_systolicController.text.isNotEmpty && _diastolicController.text.isNotEmpty)
              _buildCategoryPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPreview() {
    final systolic = int.tryParse(_systolicController.text);
    final diastolic = int.tryParse(_diastolicController.text);

    if (systolic == null || diastolic == null) return const SizedBox();

    final reading = BloodPressureReading(
      id: '', // New reading doesn't have an ID yet
      systolic: systolic,
      diastolic: diastolic,
      heartRate: 72, // Default for preview
      timestamp: _selectedDateTime,
    );

    final category = reading.category;
    final categoryColor = _getCategoryColor(category);
    final categoryText = _getCategoryText(category);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: categoryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: categoryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Category: $categoryText',
            style: TextStyle(
              color: categoryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Colors.pink,
                ),
                const SizedBox(width: 8),
                Text(
                  'Heart Rate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heartRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Heart Rate',
                suffixText: 'bpm',
                border: OutlineInputBorder(),
                helperText: '40-200 beats per minute',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter heart rate';
                }
                final heartRate = int.tryParse(value);
                if (heartRate == null) {
                  return 'Please enter a valid number';
                }
                if (heartRate < 30 || heartRate > 250) {
                  return 'Please enter a value between 30-250';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notes (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Add notes about this reading',
                border: OutlineInputBorder(),
                helperText: 'e.g., After exercise, feeling stressed, medication taken',
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Blood Pressure Categories',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCategoryRow('Normal', '< 120 and < 80', Colors.green),
            _buildCategoryRow('Elevated', '121-129 and < 80', Colors.orange),
            _buildCategoryRow('Stage 1', '130-139 OR 80-89', Colors.deepOrange),
            _buildCategoryRow('Stage 2', '≥ 140 OR ≥ 90', Colors.red),
            _buildCategoryRow('Crisis', '≥ 180 OR ≥ 120', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveReading() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final heartRate = int.parse(_heartRateController.text);

      final reading = BloodPressureReading(
        id: '', // New reading doesn't have an ID yet
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: _selectedDateTime,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await context.read<BloodPressureProvider>().addReading(reading);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Blood pressure reading saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Clear form
        _formKey.currentState?.reset();
        _systolicController.clear();
        _diastolicController.clear();
        _heartRateController.clear();
        _notesController.clear();
        setState(() {
          _selectedDateTime = DateTime.now();
        });

        // Navigate back to dashboard - TabController isn't available in this context
        // For now, we'll just clear the form and show success message
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error saving reading: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getCategoryColor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return Colors.blue;
      case BloodPressureCategory.normal:
        return Colors.green;
      case BloodPressureCategory.elevated:
        return Colors.orange;
      case BloodPressureCategory.stage1:
        return Colors.deepOrange;
      case BloodPressureCategory.stage2:
        return Colors.red;
      case BloodPressureCategory.crisis:
        return Colors.purple;
    }
  }

  String _getCategoryText(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Reusable content widget for adding readings (used in modal and full screen)
class AddReadingContent extends StatefulWidget {
  final bool isInModal;

  const AddReadingContent({
    super.key,
    this.isInModal = false,
  });

  @override
  State<AddReadingContent> createState() => _AddReadingContentState();
}

class _AddReadingContentState extends State<AddReadingContent> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date and Time Selection
          _buildDateTimeCard(),
          const SizedBox(height: 16),

          // Blood Pressure Input
          _buildBloodPressureCard(),
          const SizedBox(height: 16),

          // Heart Rate Input
          _buildHeartRateCard(),
          const SizedBox(height: 16),

          // Notes
          _buildNotesCard(),
          const SizedBox(height: 24),

          // Save Button
          if (widget.isInModal)
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveReading,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Reading'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),

          // Reference Card
          _buildReferenceCard(),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Date & Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(_selectedDateTime),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          _formatTime(_selectedDateTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Blood Pressure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _systolicController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Systolic',
                      hintText: '120',
                      border: OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final systolic = int.tryParse(value);
                      if (systolic == null) {
                        return 'Invalid number';
                      }
                      if (systolic < 70 || systolic > 250) {
                        return 'Must be between 70-250';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _diastolicController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Diastolic',
                      hintText: '80',
                      border: OutlineInputBorder(),
                      suffixText: 'mmHg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final diastolic = int.tryParse(value);
                      if (diastolic == null) {
                        return 'Invalid number';
                      }
                      if (diastolic < 40 || diastolic > 150) {
                        return 'Must be between 40-150';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_systolicController.text.isNotEmpty &&
                _diastolicController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildCategoryIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Heart Rate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heartRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Heart Rate',
                hintText: '72',
                border: OutlineInputBorder(),
                suffixText: 'bpm',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final heartRate = int.tryParse(value);
                if (heartRate == null) {
                  return 'Invalid number';
                }
                if (heartRate < 30 || heartRate > 220) {
                  return 'Must be between 30-220';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notes (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Add notes about this reading',
                border: OutlineInputBorder(),
                helperText: 'e.g., After exercise, feeling stressed, medication taken',
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIndicator() {
    final systolic = int.tryParse(_systolicController.text) ?? 0;
    final diastolic = int.tryParse(_diastolicController.text) ?? 0;
    final category = _getBPCategory(systolic, diastolic);
    final categoryColor = _getCategoryColor(category);
    final categoryText = _getCategoryText(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: categoryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Category: $categoryText',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Blood Pressure Reference',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildReferenceRow('Normal', '< 120 and < 80', Colors.green),
            _buildReferenceRow('Elevated', '120-129 and < 80', Colors.orange),
            _buildReferenceRow('Stage 1', '130-139 or 80-89', Colors.deepOrange),
            _buildReferenceRow('Stage 2', '≥ 140 or ≥ 90', Colors.red),
            _buildReferenceRow('Crisis', '≥ 180 or ≥ 120', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              range,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (timePicked != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  Future<void> _saveReading() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final heartRate = int.parse(_heartRateController.text);
      final notes = _notesController.text.trim();

      final reading = BloodPressureReading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: _selectedDateTime,
        notes: notes.isNotEmpty ? notes : null,
      );

      await context.read<BloodPressureProvider>().addReading(reading);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood pressure reading saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Close modal if we're in one
        if (widget.isInModal) {
          Navigator.pop(context);
        }

        // Reset form
        _formKey.currentState?.reset();
        _selectedDateTime = DateTime.now();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving reading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  BloodPressureCategory _getBPCategory(int systolic, int diastolic) {
    // Check for hypertensive crisis first (highest priority)
    if (systolic >= 180 || diastolic >= 120) {
      return BloodPressureCategory.crisis;
    }

    // Check for Stage 2
    if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureCategory.stage2;
    }

    // Check for Stage 1
    if (systolic >= 130 || diastolic >= 80) {
      return BloodPressureCategory.stage1;
    }

    // Check for Elevated
    if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return BloodPressureCategory.elevated;
    }

    // Check for Low (optional, not in standard guidelines)
    if (systolic < 90 || diastolic < 60) {
      return BloodPressureCategory.low;
    }

    // Normal
    return BloodPressureCategory.normal;
  }

  Color _getCategoryColor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return Colors.blue;
      case BloodPressureCategory.normal:
        return Colors.green;
      case BloodPressureCategory.elevated:
        return Colors.orange;
      case BloodPressureCategory.stage1:
        return Colors.deepOrange;
      case BloodPressureCategory.stage2:
        return Colors.red;
      case BloodPressureCategory.crisis:
        return Colors.purple;
    }
  }

  String _getCategoryText(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.stage1:
        return 'Stage 1';
      case BloodPressureCategory.stage2:
        return 'Stage 2';
      case BloodPressureCategory.crisis:
        return 'Crisis';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}