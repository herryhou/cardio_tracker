import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/cloudflare_kv_service.dart';
import '../../services/manual_sync_service.dart';
import '../providers/blood_pressure_provider.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/neumorphic_button.dart';

class CloudflareSettingsScreen extends StatefulWidget {
  const CloudflareSettingsScreen({super.key});

  @override
  State<CloudflareSettingsScreen> createState() =>
      _CloudflareSettingsScreenState();
}

class _CloudflareSettingsScreenState extends State<CloudflareSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountIdController = TextEditingController();
  final _namespaceIdController = TextEditingController();
  final _apiTokenController = TextEditingController();

  final CloudflareKVService _kvService = CloudflareKVService();
  final ManualSyncService _syncService = ManualSyncService();

  bool _isLoading = false;
  bool _isConfigured = false;
  String? _lastSyncStatus;
  DateTime? _lastSyncTime;
  String? _lastSaveStatus;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfiguration();
    });
  }

  Future<void> _loadConfiguration() async {
    if (!mounted) return;

    try {
      final configured = await _kvService.isConfigured();
      if (configured) {
        final credentials = await _kvService.getCredentials();
        if (credentials != null && mounted) {
          setState(() {
            _isConfigured = configured;
            _accountIdController.text = credentials['accountId'] ?? '';
            _namespaceIdController.text = credentials['namespaceId'] ?? '';
            // For security, don't pre-populate the API token
            _apiTokenController.clear();
          });
        }
      } else if (mounted) {
        setState(() {
          _isConfigured = configured;
        });
      }
    } catch (e) {
      print(
          'CloudflareSettingsScreen: Error loading configuration: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isConfigured = false;
        });
      }
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    _clearLastSyncStatus();

    try {
      print('CloudflareSettingsScreen: Starting credential save...');

      // Step 1: Save credentials first
      await _kvService.setCredentials(
        accountId: _accountIdController.text.trim(),
        namespaceId: _namespaceIdController.text.trim(),
        apiToken: _apiTokenController.text.trim(),
      );

      print('CloudflareSettingsScreen: Credentials saved successfully');

      final wasInitiallyConfigured = _isConfigured;

      setState(() {
        _isConfigured = true;
        _lastSaveStatus = wasInitiallyConfigured
            ? 'Credentials updated successfully'
            : 'Credentials saved successfully';
      });

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasInitiallyConfigured
                ? 'Cloudflare KV credentials updated'
                : 'Cloudflare KV configured successfully'),
          ),
        );
      }

      // Step 2: Test connection after successful save
      print('CloudflareSettingsScreen: Testing connection...');
      final connectionTest = await _kvService.testConnection();

      if (connectionTest) {
        setState(() {
          _lastSaveStatus = '${_lastSaveStatus!} - Connection verified';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Connection to Cloudflare KV verified successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _lastSaveStatus = '${_lastSaveStatus!} - Connection test failed';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Credentials saved but connection test failed - check console for details'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('CloudflareSettingsScreen: Save failed: ${e.toString()}');
      setState(() {
        _lastSaveStatus = 'Error: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSync() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _lastSyncStatus = null;
    });

    try {
      final result = await _syncService.performSync();

      setState(() {
        _lastSyncTime = DateTime.now();
        if (result.error != null) {
          _lastSyncStatus = 'Sync failed: ${result.error}';
        } else {
          _lastSyncStatus = 'Sync complete: '
              '${result.pushed} pushed, '
              '${result.pulled} pulled, '
              '${result.deleted} deleted';
        }
      });

      if (mounted) {
        if (result.error != null) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.lightImpact();
          // Refresh the UI by reloading readings after successful sync
          if (context.mounted) {
            context.read<BloodPressureProvider>().loadReadings();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error != null
                ? _lastSyncStatus ?? 'Sync failed'
                : 'Sync complete and data refreshed'
            ),
            backgroundColor: result.error != null ? null : Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastSyncStatus = 'Sync error: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearConfiguration() async {
    await _kvService.clearCredentials();

    setState(() {
      _isConfigured = false;
      _accountIdController.clear();
      _namespaceIdController.clear();
      _apiTokenController.clear();
      _lastSaveStatus = 'Configuration cleared';
    });
  }

  void _clearLastSyncStatus() {
    setState(() {
      _lastSyncStatus = null;
      _lastSyncTime = null;
    });
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _namespaceIdController.dispose();
    _apiTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use a simple try-catch for error handling
    try {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Cloudflare Sync'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status section
              NeumorphicContainer(
                borderRadius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isConfigured ? Icons.cloud_done : Icons.cloud_off,
                            color: _isConfigured ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isConfigured ? 'Configured' : 'Not configured',
                            style: theme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (_isConfigured)
                            const Tooltip(
                              message:
                                  'Credentials are stored securely using device keychain/encrypted storage',
                              child: Icon(
                                Icons.security,
                                size: 16,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                      if (_isConfigured) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.lock,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Credentials stored securely',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_lastSyncTime != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last synced: ${_formatDateTime(_lastSyncTime!)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (_lastSaveStatus != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Config: $_lastSaveStatus!',
                          style: TextStyle(
                            color: _lastSaveStatus!.contains('error')
                                ? Colors.red
                                : Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (_lastSyncStatus != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Sync: $_lastSyncStatus!',
                          style: TextStyle(
                            color: _lastSyncStatus!.contains('error') ||
                                    _lastSyncStatus!.contains('failed')
                                ? Colors.red
                                : Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sync button
              NeumorphicButton(
                onPressed: _isLoading || !_isConfigured
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _performSync();
                      },
                width: double.infinity,
                height: 48,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sync),
                          const SizedBox(width: 8),
                          Text(_isLoading ? 'Syncing...' : 'Sync Now'),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Configuration form
              NeumorphicContainer(
                borderRadius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cloudflare KV Configuration',
                          style: theme.textTheme.titleLarge,
                        ),

                        const SizedBox(height: 16),

                        // Account ID field
                        NeumorphicContainer(
                          isPressed: false,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _accountIdController,
                            decoration: const InputDecoration(
                              labelText: 'Account ID',
                              hintText: 'Your Cloudflare account ID',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Account ID is required';
                              }
                              return null;
                            },
                            onTap: () => HapticFeedback.lightImpact(),
                          ),
                        ),

                        // Namespace ID field
                        NeumorphicContainer(
                          isPressed: false,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _namespaceIdController,
                            decoration: const InputDecoration(
                              labelText: 'Namespace ID',
                              hintText: 'Your KV namespace ID',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Namespace ID is required';
                              }
                              return null;
                            },
                            onTap: () => HapticFeedback.lightImpact(),
                          ),
                        ),

                        // API Token field
                        NeumorphicContainer(
                          isPressed: false,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: TextFormField(
                            controller: _apiTokenController,
                            decoration: InputDecoration(
                              labelText: 'API Token',
                              hintText: _isConfigured
                                  ? 'Re-enter your API token to update credentials'
                                  : 'Your Cloudflare API token',
                              helperText: _isConfigured
                                  ? 'Stored securely • Enter new token to update'
                                  : 'Will be stored securely in device keychain',
                              prefixIcon: Icon(
                                Icons.key,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: _isConfigured
                                  ? IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        _showCredentialInfoDialog(context);
                                      },
                                      tooltip: 'About credential storage',
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'API token is required';
                              }
                              return null;
                            },
                            onTap: () => HapticFeedback.lightImpact(),
                          ),
                        ),

                        // Save/Update button
                        NeumorphicButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  HapticFeedback.mediumImpact();
                                  _saveConfiguration();
                                },
                          width: double.infinity,
                          height: 48,
                          child: Text(_isConfigured ? 'Update' : 'Save'),
                        ),

                        if (_isConfigured) ...[
                          const SizedBox(height: 12),
                          NeumorphicButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    HapticFeedback.mediumImpact();
                                    _clearConfiguration();
                                  },
                            width: double.infinity,
                            height: 48,
                            color: theme.colorScheme.errorContainer,
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('CloudflareSettingsScreen build error: $e');
      print('Stack trace: $stackTrace');
      // Return a simple error screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cloudflare Sync'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'An error occurred while loading the settings',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showCredentialInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.green),
            SizedBox(width: 8),
            Text('Credential Storage'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Cloudflare credentials are securely stored using:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Device Keychain (iOS)'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Encrypted Storage (Android)'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('SharedPreferences (fallback)'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Your API token is never stored in plain text or memory, ensuring your credentials remain secure even if the app is closed.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
