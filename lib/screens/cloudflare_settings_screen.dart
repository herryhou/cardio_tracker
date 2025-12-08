import 'package:flutter/material.dart';
import '../services/cloudflare_kv_service.dart';
import '../services/manual_sync_service.dart';

class CloudflareSettingsScreen extends StatefulWidget {
  const CloudflareSettingsScreen({super.key});

  @override
  State<CloudflareSettingsScreen> createState() => _CloudflareSettingsScreenState();
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

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    final configured = await _kvService.isConfigured();
    setState(() {
      _isConfigured = configured;
    });
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _kvService.setCredentials(
        accountId: _accountIdController.text.trim(),
        namespaceId: _namespaceIdController.text.trim(),
        apiToken: _apiTokenController.text.trim(),
      );

      setState(() {
        _isConfigured = true;
        _lastSyncStatus = 'Credentials saved successfully';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloudflare KV configured successfully')),
      );

    } catch (e) {
      setState(() {
        _lastSyncStatus = 'Error: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSync() async {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_lastSyncStatus ?? 'Sync complete')),
      );

    } catch (e) {
      setState(() {
        _lastSyncStatus = 'Sync error: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync error: ${e.toString()}')),
      );
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
      _lastSyncStatus = 'Configuration cleared';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloudflare Sync'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status section
            Card(
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    if (_lastSyncTime != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Last synced: ${_formatDateTime(_lastSyncTime!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (_lastSyncStatus != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _lastSyncStatus!,
                        style: TextStyle(
                          color: _lastSyncStatus!.contains('error')
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading || !_isConfigured ? null : _performSync,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isLoading ? 'Syncing...' : 'Sync Now'),
              ),
            ),

            const SizedBox(height: 24),

            // Configuration form
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloudflare KV Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _accountIdController,
                      decoration: const InputDecoration(
                        labelText: 'Account ID',
                        hintText: 'Your Cloudflare account ID',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account ID is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _namespaceIdController,
                      decoration: const InputDecoration(
                        labelText: 'Namespace ID',
                        hintText: 'Your KV namespace ID',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Namespace ID is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _apiTokenController,
                      decoration: const InputDecoration(
                        labelText: 'API Token',
                        hintText: 'Your Cloudflare API token',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'API token is required';
                        }
                        return null;
                      },
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveConfiguration,
                            child: Text(_isConfigured ? 'Update' : 'Save'),
                          ),
                        ),

                        if (_isConfigured) ...[
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _isLoading ? null : _clearConfiguration,
                            child: const Text('Clear'),
                          ),
                        ],
                      ],
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
}