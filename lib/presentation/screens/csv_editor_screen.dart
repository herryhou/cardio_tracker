import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/csv_editor_provider.dart';

class CsvEditorScreen extends StatefulWidget {
  const CsvEditorScreen({Key? key}) : super(key: key);

  @override
  State<CsvEditorScreen> createState() => _CsvEditorScreenState();
}

class _CsvEditorScreenState extends State<CsvEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize the editor when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CsvEditorProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<CsvEditorProvider>(
        builder: (context, provider, child) {
          // Update controller when provider content changes
          if (_controller.text != provider.csvContent) {
            _controller.value = TextEditingValue(
              text: provider.csvContent,
              selection: TextSelection.collapsed(offset: provider.csvContent.length),
            );
          }

          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              title: const Text('Edit All Readings'),
              backgroundColor: colorScheme.surface,
              elevation: 0,
              iconTheme: IconThemeData(color: colorScheme.onSurface),
              titleTextStyle: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              actions: [
                if (provider.hasUnsavedChanges)
                  TextButton(
                    onPressed: () => _discardChanges(context, provider),
                    child: const Text('Discard'),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                _buildStatusBar(context, provider, colorScheme, textTheme),
                Expanded(
                  child: _buildEditor(context, provider, colorScheme, textTheme),
                ),
                _buildActionButtons(context, provider, colorScheme, textTheme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, CsvEditorProvider provider,
      ColorScheme colorScheme, TextTheme textTheme) {
    Color statusColor;
    IconData statusIcon;

    switch (provider.status) {
      case CsvEditorStatus.loading:
      case CsvEditorStatus.validating:
      case CsvEditorStatus.saving:
        statusColor = colorScheme.primary;
        statusIcon = Icons.hourglass_empty;
        break;
      case CsvEditorStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case CsvEditorStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case CsvEditorStatus.idle:
        if (provider.hasValidationErrors) {
          statusColor = Colors.orange;
          statusIcon = Icons.warning;
        } else if (provider.hasUnsavedChanges) {
          statusColor = colorScheme.primary;
          statusIcon = Icons.edit;
        } else {
          statusColor = colorScheme.onSurface.withOpacity(0.6);
          statusIcon = Icons.info;
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.statusMessage,
              style: textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: provider.hasValidationErrors ? FontWeight.w500 : null,
              ),
            ),
          ),
          if (provider.status == CsvEditorStatus.validating ||
              provider.status == CsvEditorStatus.saving)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, CsvEditorProvider provider,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'Line',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CSV Content',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Editor content
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: provider.status != CsvEditorStatus.saving &&
                    provider.status != CsvEditorStatus.validating,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                  isDense: true,
                ),
                onChanged: (value) {
                  provider.updateContent(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CsvEditorProvider provider,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: provider.canSave && provider.status == CsvEditorStatus.idle
                  ? () => _saveChanges(context, provider)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.canSave ? colorScheme.primary : colorScheme.surface,
                foregroundColor: provider.canSave ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: provider.canSave ? 4 : 2,
              ),
              child: provider.status == CsvEditorStatus.saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context, CsvEditorProvider provider) async {
    HapticFeedback.lightImpact();
    final success = await provider.save();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All readings have been updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      // Show validation errors if any
      if (provider.hasValidationErrors) {
        _showValidationErrors(context, provider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _discardChanges(BuildContext context, CsvEditorProvider provider) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard all unsaved changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.discardChanges();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationErrors(BuildContext context, CsvEditorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Validation Errors (${provider.validationErrors.length})',
          style: const TextStyle(color: Colors.red),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: provider.validationErrors.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.validationErrors[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              provider.clearErrors();
              Navigator.of(context).pop();
              // Focus back to editor
              _focusNode.requestFocus();
            },
            child: const Text('Fix Errors'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final provider = context.read<CsvEditorProvider>();

    if (!provider.hasUnsavedChanges) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }
}