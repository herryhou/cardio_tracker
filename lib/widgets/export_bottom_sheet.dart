import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../domain/entities/blood_pressure_reading.dart';
import '../infrastructure/services/csv_export_service.dart';
import '../theme/app_theme.dart';
import 'neumorphic_container.dart';
import 'neumorphic_button.dart';
import 'csv_editor_button.dart';

/// A neumorphic bottom sheet for export options
/// Provides haptic feedback and smooth animations
class ExportBottomSheet extends StatefulWidget {
  /// List of blood pressure readings to export
  final List<BloodPressureReading> readings;

  const ExportBottomSheet({
    super.key,
    required this.readings,
  });

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExporting = false;
  String? _exportingOption;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    // Start the animation when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  Future<void> _handleExport(String option) async {
    if (_isExporting) return;

    _triggerHapticFeedback();
    setState(() {
      _isExporting = true;
      _exportingOption = option;
    });

    try {
      switch (option) {
        case 'all':
          await CsvExportService.exportToCsv(widget.readings);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All data exported successfully')),
            );
          }
          break;
        case 'summary':
          await CsvExportService.exportSummaryStats(widget.readings);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Summary exported successfully')),
            );
          }
          break;
        case 'month':
          await CsvExportService.exportCurrentMonth(widget.readings);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Monthly data exported successfully')),
            );
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingOption = null;
        });
        // Close bottom sheet after successful export
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildExportButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required String option,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: NeumorphicButton(
        key: Key('export_button_$option'),
        onPressed: isLoading ? null : () => _handleExport(option),
        borderRadius: 16.0,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              key: const Key('export_button_container'),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLoading
                    ? Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.5)
                    : Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLoading
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5)
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0,
              _slideAnimation.value * MediaQuery.of(context).size.height * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        bottom: AppSpacing.lg,
                      ),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Row(
                        children: [
                          NeumorphicContainer(
                            borderRadius: 12.0,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Icon(
                              Icons.file_download_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export Data',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Choose what to export',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Export options
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        children: [
                          _buildExportButton(
                            title: 'Export All Data',
                            subtitle: 'Complete blood pressure history',
                            icon: Icons.download,
                            option: 'all',
                            isLoading:
                                _isExporting && _exportingOption == 'all',
                          ),
                          _buildExportButton(
                            title: 'Export Summary',
                            subtitle: 'Statistics and averages',
                            icon: Icons.analytics,
                            option: 'summary',
                            isLoading:
                                _isExporting && _exportingOption == 'summary',
                          ),
                          _buildExportButton(
                            title: 'Export This Month',
                            subtitle: 'Current month readings only',
                            icon: Icons.today,
                            option: 'month',
                            isLoading:
                                _isExporting && _exportingOption == 'month',
                          ),
                          const SizedBox(height: 8),
                          const Divider(
                            height: 32,
                            thickness: 1,
                          ),
                          Text(
                            'Data Management',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const CsvEditorButton(),
                        ],
                      ),
                    ),
                    // Extra padding at bottom
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows the export bottom sheet
Future<void> showExportBottomSheet(
  BuildContext context, {
  required List<BloodPressureReading> readings,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ExportBottomSheet(readings: readings),
  );
}
