import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';

/// Reusable content widget for adding readings (used in modal)
class AddReadingContent extends StatefulWidget {
  final bool isInModal;
  final VoidCallback? onSave;
  final bool isLoading;
  final TextEditingController? systolicController;
  final TextEditingController? diastolicController;
  final TextEditingController? heartRateController;
  final TextEditingController? notesController;
  final DateTime? initialDateTime;

  const AddReadingContent({
    super.key,
    this.isInModal = false,
    this.onSave,
    this.isLoading = false,
    this.systolicController,
    this.diastolicController,
    this.heartRateController,
    this.notesController,
    this.initialDateTime,
  });

  @override
  State<AddReadingContent> createState() => _AddReadingContentState();
}

class _AddReadingContentState extends State<AddReadingContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _heartRateController;
  late final TextEditingController _notesController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _systolicController = widget.systolicController ?? TextEditingController();
    _diastolicController =
        widget.diastolicController ?? TextEditingController();
    _heartRateController =
        widget.heartRateController ?? TextEditingController();
    _notesController = widget.notesController ?? TextEditingController();
    _selectedDateTime = widget.initialDateTime ?? DateTime.now();
  }

  @override
  void dispose() {
    // Only dispose controllers that were created locally
    if (widget.systolicController == null) _systolicController.dispose();
    if (widget.diastolicController == null) _diastolicController.dispose();
    if (widget.heartRateController == null) _heartRateController.dispose();
    if (widget.notesController == null) _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.screenMargin),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Date/Time picker
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_formatDate(_selectedDateTime)} at ${_formatTime(_selectedDateTime)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _selectDateTime,
                        // icon: const Icon(Icons.edit_calendar),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        label: const Text('Change'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Simple input fields for modal
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _systolicController,
                    label: 'SYS',
                    hint: '120',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final systolic = int.tryParse(value);
                      if (systolic == null) return 'Invalid number';
                      if (systolic < 70 || systolic > 250) {
                        return '70-250';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildNumberField(
                    controller: _diastolicController,
                    label: 'DIA',
                    hint: '80',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final diastolic = int.tryParse(value);
                      if (diastolic == null) return 'Invalid number';
                      if (diastolic < 40 || diastolic > 150) {
                        return '40-150';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildNumberField(
                    controller: _heartRateController,
                    label: 'Pulse',
                    hint: '72',
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final heartRate = int.tryParse(value);
                      if (heartRate == null) return 'Invalid number';
                      if (heartRate < 30 || heartRate > 250) {
                        return '30-250';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              maxLength: 150,
              decoration: InputDecoration(
                // labelText: 'Notes (Optional)',
                hintText:
                    'e.g., wake up, after workout, felt dizzy, medication taken',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                counterText: '',
                helperText: ' ',
                helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.transparent,
                      height: 1.2,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Save button (only show in modal)
            if (widget.isInModal) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Reading',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: null,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        initialEntryMode: TimePickerEntryMode.dial,
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

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.outline,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  height: 1.2,
                ),
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            helperText: ' ',
            helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.transparent,
                  height: 1.2,
                ),
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  // Methods for modal communication
  bool validateAndSave() {
    if (!_formKey.currentState!.validate()) return false;

    final systolic = int.tryParse(_systolicController.text);
    final diastolic = int.tryParse(_diastolicController.text);
    final heartRate = _heartRateController.text.isNotEmpty
        ? int.tryParse(_heartRateController.text)
        : 0;

    return systolic != null && diastolic != null;
  }

  BloodPressureReading? getReadingData() {
    final systolic = int.tryParse(_systolicController.text);
    final diastolic = int.tryParse(_diastolicController.text);
    final heartRate = _heartRateController.text.isNotEmpty
        ? int.tryParse(_heartRateController.text) ?? 0
        : 0;

    if (systolic == null || diastolic == null) return null;

    return BloodPressureReading(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      timestamp: _selectedDateTime,
      notes: _notesController.text.trim(),
      lastModified: DateTime.now(),
    );
  }
}
