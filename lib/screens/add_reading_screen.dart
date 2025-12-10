import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../models/blood_pressure_reading.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_slider.dart';

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

  // Slider values for visual input
  double _systolicValue = 120.0;
  double _diastolicValue = 80.0;
  final double _heartRateValue = 72.0;

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NeumorphicButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          borderRadius: 20.0,
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Add Reading',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeumorphicButton(
              onPressed: _isLoading ? null : _saveReading,
              borderRadius: 20.0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Save',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isLoading
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Blood Pressure Input with Card Design
                NeumorphicContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Blood Pressure',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildBloodPressureInput(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Heart Rate Input
                NeumorphicContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monitor_heart,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Heart Rate',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildHeartRateInput(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Date & Time
                NeumorphicContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _buildDateTimeSelector(),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Notes
                NeumorphicContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _buildNotesInput(),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Reference Guide
                _buildReferenceGuide(),

                const SizedBox(height: AppSpacing.xl * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBloodPressureInput() {
    return Column(
      children: [
        // Text input fields
        Row(
          children: [
            Expanded(
              child: _buildModernNumberField(
                controller: _systolicController,
                label: 'Systolic',
                hint: '120',
                value: _systolicValue,
                min: 70,
                max: 250,
                unit: 'mmHg',
                color: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    _systolicValue = value;
                    _systolicController.text = value.round().toString();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final systolic = int.tryParse(value);
                  if (systolic == null || systolic < 70 || systolic > 250) {
                    return 'Enter value between 70-250';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _buildModernNumberField(
                controller: _diastolicController,
                label: 'Diastolic',
                hint: '80',
                value: _diastolicValue,
                min: 40,
                max: 150,
                unit: 'mmHg',
                color: Theme.of(context).colorScheme.secondary,
                onChanged: (value) {
                  setState(() {
                    _diastolicValue = value;
                    _diastolicController.text = value.round().toString();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final diastolic = int.tryParse(value);
                  if (diastolic == null || diastolic < 40 || diastolic > 150) {
                    return 'Enter value between 40-150';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeartRateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _heartRateController,
                label: 'BPM',
                hint: '72',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final heartRate = int.tryParse(value);
                  if (heartRate == null || heartRate < 30 || heartRate > 250) {
                    return '';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required Function(double) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NeumorphicContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    value.round().toString(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    unit,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              NeumorphicSlider(
                value: (value - min) / (max - min),
                min: 0.0,
                max: 1.0,
                onChanged: (newValue) {
                  onChanged(min + newValue * (max - min));
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: color,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                validator: validator,
                onChanged: (text) {
                  final newValue = double.tryParse(text);
                  if (newValue != null && newValue >= min && newValue <= max) {
                    onChanged(newValue);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Date & Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NeumorphicButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _selectDateTime();
          },
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(_selectedDateTime),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTime(_selectedDateTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note_add,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Notes (Optional)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NeumorphicContainer(
          child: TextFormField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 150,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Add notes about this reading...',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceGuide() {
    return NeumorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'BP Reference Guide',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildReferenceRow(
              'Normal',
              '< 120/80 mmHg',
              Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildReferenceRow(
              'Elevated',
              '120-129/<80 mmHg',
              Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildReferenceRow(
              'High Stage 1',
              '130-139/80-89 mmHg',
              Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildReferenceRow(
              'High Stage 2',
              '≥ 140/90 mmHg',
              Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceRow(String label, String range, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            range,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            colorScheme: Theme.of(context).colorScheme,
            useMaterial3: true,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
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
    if (_systolicController.text.isEmpty || _diastolicController.text.isEmpty) {
      _showSnackBar(
          'Please enter blood pressure values', Theme.of(context).colorScheme.error);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final heartRate = _heartRateController.text.isNotEmpty
          ? int.parse(_heartRateController.text)
          : 72;

      final reading = BloodPressureReading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: _selectedDateTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        lastModified: DateTime.now(),
      );

      await context.read<BloodPressureProvider>().addReading(reading);

      if (mounted) {
        _showSnackBar('Reading saved', Theme.of(context).colorScheme.primary);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Theme.of(context).colorScheme.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(AppSpacing.screenMargin),
        duration: const Duration(seconds: 3),
        elevation: 4,
      ),
    );
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
                color: Colors.grey[300],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
              isDense: false,
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

/// Reusable content widget for adding readings (used in modal and full screen)
class AddReadingContent extends StatefulWidget {
  final bool isInModal;
  final VoidCallback? onSave;

  const AddReadingContent({
    super.key,
    this.isInModal = false,
    this.onSave,
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
          _buildBloodPressureInput(),
          const SizedBox(height: 16),
          _buildHeartRateInput(),
          const SizedBox(height: 16),
          _buildDateTimeSelector(),
          const SizedBox(height: 32),
          _buildNotesInput(),
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildBloodPressureInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _systolicController,
                label: 'SYS',
                hint: '120',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final systolic = int.tryParse(value);
                  if (systolic == null || systolic < 70 || systolic > 250) {
                    return '';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                controller: _diastolicController,
                label: 'DIA',
                hint: '80',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final diastolic = int.tryParse(value);
                  if (diastolic == null || diastolic < 40 || diastolic > 150) {
                    return '';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeartRateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _heartRateController,
                label: 'BPM',
                hint: '72',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final heartRate = int.tryParse(value);
                  if (heartRate == null || heartRate < 30 || heartRate > 250) {
                    return '';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
                color: Colors.grey[300],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
              isDense: false,
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date/Time',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          child: InkWell(
            onTap: _selectDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(_selectedDateTime),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        _formatTime(_selectedDateTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[500],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 1,
          maxLength: 60,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'e.g., After workout, woke up...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterText: '',
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return NeumorphicButton(
      onPressed: _isLoading ? null : _saveReading,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading) ...[
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else ...[
            Icon(
              Icons.save,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            'Save Reading',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: _isLoading
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
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
            colorScheme: Theme.of(context).colorScheme,
            useMaterial3: true,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
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
    if (_systolicController.text.isEmpty || _diastolicController.text.isEmpty) {
      _showSnackBar(
          'Please enter blood pressure values', Theme.of(context).colorScheme.error);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final heartRate = _heartRateController.text.isNotEmpty
          ? int.parse(_heartRateController.text)
          : 72;

      final reading = BloodPressureReading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: _selectedDateTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        lastModified: DateTime.now(),
      );

      await context.read<BloodPressureProvider>().addReading(reading);

      if (mounted) {
        _showSnackBar('Reading saved', Theme.of(context).colorScheme.primary);

        if (widget.onSave != null) {
          widget.onSave!();
        }

        if (widget.isInModal) {
          Navigator.pop(context);
        }

        _formKey.currentState?.reset();
        _systolicController.clear();
        _diastolicController.clear();
        _heartRateController.clear();
        _notesController.clear();
        setState(() {
          _selectedDateTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Theme.of(context).colorScheme.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(AppSpacing.screenMargin),
        duration: const Duration(seconds: 3),
        elevation: 4,
      ),
    );
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
}
