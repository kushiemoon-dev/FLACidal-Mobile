import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

/// Sources settings page — manage Qobuz credentials, preferred source, fallback.
class SourcesPage extends ConsumerStatefulWidget {
  const SourcesPage({super.key});

  @override
  ConsumerState<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends ConsumerState<SourcesPage> {
  final _appIdController = TextEditingController();
  final _appSecretController = TextEditingController();
  final _authTokenController = TextEditingController();

  List<Map<String, dynamic>> _sources = [];
  String _preferredSource = '';
  bool _fallbackEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _appSecretController.dispose();
    _authTokenController.dispose();
    super.dispose();
  }

  void _loadData() {
    final core = ref.read(flacCoreProvider);
    try {
      final sourcesResult = core.callSync('getAvailableSources');
      final sources = sourcesResult['sources'];
      if (sources is List) {
        _sources = sources.cast<Map<String, dynamic>>();
      }

      final prefResult = core.callSync('getPreferredSource');
      _preferredSource = prefResult['source'] as String? ?? '';
      _fallbackEnabled = prefResult['fallback'] as bool? ?? false;
    } catch (e) {
      _showError('Failed to load sources: $e');
    }
    setState(() => _loading = false);
  }

  void _setPreferredSource(String source) {
    final core = ref.read(flacCoreProvider);
    try {
      core.callSync('setPreferredSource', {'source': source});
      setState(() => _preferredSource = source);
    } catch (e) {
      _showError('Failed to set preferred source: $e');
    }
  }

  void _toggleFallback(bool value) {
    final core = ref.read(flacCoreProvider);
    try {
      core.callSync('setPreferredSource', {
        'source': _preferredSource,
        'fallback': value,
      });
      setState(() => _fallbackEnabled = value);
    } catch (e) {
      _showError('Failed to update fallback setting: $e');
    }
  }

  void _saveQobuzCredentials() {
    final core = ref.read(flacCoreProvider);
    try {
      core.callSync('updateQobuzCredentials', {
        'appId': _appIdController.text.trim(),
        'appSecret': _appSecretController.text.trim(),
        'authToken': _authTokenController.text.trim(),
      });
      _showSuccess('Qobuz credentials saved');
    } catch (e) {
      _showError('Failed to save credentials: $e');
    }
  }

  void _testConnection() {
    final core = ref.read(flacCoreProvider);
    try {
      final result = core.callSync('testQobuzConnection');
      final ok = result['success'] as bool? ?? false;
      if (ok) {
        _showSuccess('Connection successful');
      } else {
        final msg = result['error'] as String? ?? 'Unknown error';
        _showError('Connection failed: $msg');
      }
    } catch (e) {
      _showError('Connection test failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sources')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // ── Available Sources ────────────────
                const _SectionHeader('Available Sources'),
                if (_sources.isEmpty)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('No sources available'),
                  ),
                for (final source in _sources)
                  ListTile(
                    leading: Icon(
                      (source['enabled'] as bool? ?? false)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: (source['enabled'] as bool? ?? false)
                          ? Colors.greenAccent
                          : Colors.grey,
                    ),
                    title: Text(source['name'] as String? ?? 'Unknown'),
                    subtitle: Text(source['status'] as String? ?? ''),
                  ),

                // ── Preferred Source ─────────────────
                const _SectionHeader('Preferred Source'),
                if (_sources.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      value: _preferredSource.isNotEmpty &&
                              _sources.any((s) =>
                                  s['name'] == _preferredSource)
                          ? _preferredSource
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Primary source',
                        border: OutlineInputBorder(),
                      ),
                      items: _sources
                          .map((s) => DropdownMenuItem(
                                value: s['name'] as String?,
                                child: Text(s['name'] as String? ?? ''),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _setPreferredSource(value);
                      },
                    ),
                  ),

                // ── Source Fallback ───────────────────
                const _SectionHeader('Fallback'),
                SwitchListTile(
                  secondary: const Icon(Icons.swap_horiz),
                  title: const Text('Source fallback'),
                  subtitle:
                      const Text('If primary fails, try secondary'),
                  value: _fallbackEnabled,
                  onChanged: _toggleFallback,
                ),

                // ── Qobuz Credentials ────────────────
                const _SectionHeader('Qobuz Credentials'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      TextField(
                        controller: _appIdController,
                        decoration: const InputDecoration(
                          labelText: 'App ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _appSecretController,
                        decoration: const InputDecoration(
                          labelText: 'App Secret',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _authTokenController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Auth Token',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.token),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saveQobuzCredentials,
                              icon: const Icon(Icons.save),
                              label: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _testConnection,
                              icon: const Icon(Icons.wifi_tethering),
                              label: const Text('Test Connection'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
