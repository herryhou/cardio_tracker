import 'package:flutter/material.dart';
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
  late final FocusNode _systolicFocusNode;
  late final FocusNode _diastolicFocusNode;
  late final FocusNode _heartRateFocusNode;
  late final FocusNode _notesFocusNode;
  late DateTime _selectedDateTime;

  // State for managing hints visibility
  bool _systolicHasFocus = false;
  bool _diastolicHasFocus = false;
  bool _heartRateHasFocus = false;
  bool _notesHasFocus = false;

  // Keyboard animation state
  bool _keyboardVisible = false;
  final double _keyboardHeight = 300; // Estimated keyboard height

  @override
  void initState() {
    super.initState();
    _systolicController = widget.systolicController ?? TextEditingController();
    _diastolicController =
        widget.diastolicController ?? TextEditingController();
    _heartRateController =
        widget.heartRateController ?? TextEditingController();
    _notesController = widget.notesController ?? TextEditingController();
    _systolicFocusNode = FocusNode();
    _diastolicFocusNode = FocusNode();
    _heartRateFocusNode = FocusNode();
    _notesFocusNode = FocusNode();
    _selectedDateTime = widget.initialDateTime ?? DateTime.now();

    // Add focus listener to systolic field
    _systolicFocusNode.addListener(_updateKeyboardVisibility);

    // Add listeners for auto-transition
    _systolicController.addListener(_onSystolicChanged);
    _diastolicController.addListener(_onDiastolicChanged);

    // Add focus listeners for hint management
    _systolicFocusNode.addListener(() {
      if (_systolicFocusNode.hasFocus != _systolicHasFocus) {
        setState(() {
          _systolicHasFocus = _systolicFocusNode.hasFocus;
        });
      }
    });
    _diastolicFocusNode.addListener(() {
      if (_diastolicFocusNode.hasFocus != _diastolicHasFocus) {
        setState(() {
          _diastolicHasFocus = _diastolicFocusNode.hasFocus;
        });
      }
    });
    _heartRateFocusNode.addListener(() {
      if (_heartRateFocusNode.hasFocus != _heartRateHasFocus) {
        setState(() {
          _heartRateHasFocus = _heartRateFocusNode.hasFocus;
        });
      }
    });
    _notesFocusNode.addListener(() {
      if (_notesFocusNode.hasFocus != _notesHasFocus) {
        setState(() {
          _notesHasFocus = _notesFocusNode.hasFocus;
        });
      }
    });

    // Request focus on systolic field to show keyboard after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _systolicFocusNode.requestFocus();
        // Start keyboard visibility listener after a short delay
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateKeyboardVisibility();
        });
      }
    });
  }

  @override
  void dispose() {
    // Always remove listeners
    _systolicController.removeListener(_onSystolicChanged);
    _diastolicController.removeListener(_onDiastolicChanged);

    // Only dispose controllers that were created locally
    if (widget.systolicController == null) _systolicController.dispose();
    if (widget.diastolicController == null) _diastolicController.dispose();
    if (widget.heartRateController == null) _heartRateController.dispose();
    if (widget.notesController == null) _notesController.dispose();
    _systolicFocusNode.dispose();
    _diastolicFocusNode.dispose();
    _heartRateFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    // Check if any text field has focus to determine keyboard visibility
    bool hasFocus =
        _systolicFocusNode.hasFocus || FocusScope.of(context).hasFocus;

    if (hasFocus != _keyboardVisible) {
      setState(() {
        _keyboardVisible = hasFocus;
      });
    }
  }

  void _onSystolicChanged() {
    if (_systolicFocusNode.hasFocus && _systolicController.text.isNotEmpty) {
      final systolic = int.tryParse(_systolicController.text);
      if (systolic != null && systolic >= 70 && systolic <= 250) {
        // Valid systolic value, move to diastolic field
        FocusScope.of(context).requestFocus(_diastolicFocusNode);
      }
    }
  }

  void _onDiastolicChanged() {
    if (_diastolicFocusNode.hasFocus && _diastolicController.text.isNotEmpty) {
      final diastolic = int.tryParse(_diastolicController.text);
      if (diastolic != null && diastolic >= 40 && diastolic <= 150) {
        // Valid diastolic value, move to pulse field
        FocusScope.of(context).requestFocus(_heartRateFocusNode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: 0,
          bottom: _keyboardVisible ? _keyboardHeight : AppSpacing.md,
        ),
        child: GestureDetector(
          onTap: () {
            // Hide keyboard when tapping outside
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              _updateKeyboardVisibility();
            });
          },
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                // White container for all input elements
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input fields row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            key: const Key('systolic_field'),
                            controller: _systolicController,
                            label: 'SYS',
                            hint: '120',
                            focusNode: _systolicFocusNode,
                            hasFocus: _systolicHasFocus,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final systolic = int.tryParse(value);
                              if (systolic == null) return 'Invalid number';
                              if (systolic < 70 || systolic > 250) {
                                return '70-250';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildNumberField(
                            key: const Key('diastolic_field'),
                            controller: _diastolicController,
                            label: 'DIA',
                            hint: '80',
                            focusNode: _diastolicFocusNode,
                            hasFocus: _diastolicHasFocus,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final diastolic = int.tryParse(value);
                              if (diastolic == null) return 'Invalid number';
                              if (diastolic < 40 || diastolic > 150) {
                                return '40-150';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildNumberField(
                            key: const Key('pulse_field'),
                            controller: _heartRateController,
                            label: 'Pulse',
                            hint: '72',
                            focusNode: _heartRateFocusNode,
                            hasFocus: _heartRateHasFocus,
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
                    // Date/Time picker
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_formatDate(_selectedDateTime)} ${_formatTime(_selectedDateTime)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: _selectDateTime,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _notesController,
                      focusNode: _notesFocusNode,
                      maxLines: 1,
                      maxLength: 150,
                      decoration: InputDecoration(
                        hintText: _notesHasFocus ? null : 'Notes (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        counterText: '',
                        helperText: ' ',
                        helperStyle:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.transparent,
                                  height: 1.0,
                                ),
                      ),
                    ),
                    // const SizedBox(height: AppSpacing.md),

                    // Save button (only show in modal)
                    if (widget.isInModal) ...[
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onSave,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
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
            ),
          ),
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

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        initialEntryMode: TimePickerEntryMode.dial,
      );

      if (pickedTime != null && mounted) {
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
    Key? key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    FocusNode? focusNode,
    bool hasFocus = false,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textInputAction: focusNode == _heartRateFocusNode
              ? TextInputAction.done
              : TextInputAction.next,
          onEditingComplete: () {
            if (focusNode == _systolicFocusNode) {
              final value = _systolicController.text;
              if (value.isNotEmpty) {
                final systolic = int.tryParse(value);
                if (systolic != null && systolic >= 70 && systolic <= 250) {
                  FocusScope.of(context).requestFocus(_diastolicFocusNode);
                }
              }
            } else if (focusNode == _diastolicFocusNode) {
              final value = _diastolicController.text;
              if (value.isNotEmpty) {
                final diastolic = int.tryParse(value);
                if (diastolic != null && diastolic >= 40 && diastolic <= 150) {
                  FocusScope.of(context).requestFocus(_heartRateFocusNode);
                }
              }
            } else if (focusNode == _heartRateFocusNode) {
              // Hide keyboard when done on pulse field
              FocusScope.of(context).unfocus();
            }
          },
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
          decoration: InputDecoration(
            hintText: hasFocus ? null : hint,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.outline,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  height: 1.0,
                ),
            errorMaxLines: 1,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            helperText: ' ',
            helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.transparent,
                  height: 1.0,
                ),
            isDense: true,
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
    // final heartRate = _heartRateController.text.isNotEmpty
    //     ? int.tryParse(_heartRateController.text)
    //     : 0;

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
