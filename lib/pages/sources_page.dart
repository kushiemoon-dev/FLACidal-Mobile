import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';
import '../providers/config_provider.dart';
import '../providers/core_provider.dart';
import 'sources/sources_data.dart';

class SourcesPage extends ConsumerStatefulWidget {
  const SourcesPage({super.key});

  @override
  ConsumerState<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends ConsumerState<SourcesPage> {
  final _appIdController = TextEditingController();
  final _appSecretController = TextEditingController();
  final _authTokenController = TextEditingController();
  final _soulseekUsernameController = TextEditingController();
  final _soulseekPasswordController = TextEditingController();

  SourcesData? _data;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _appSecretController.dispose();
    _authTokenController.dispose();
    _soulseekUsernameController.dispose();
    _soulseekPasswordController.dispose();
    super.dispose();
  }

  /// Initial load or retry: shows the loader and fills the credential fields.
  void _load() {
    setState(() {
      _data = null;
      _loadError = null;
    });
    try {
      final data = loadSources(ref.read(flacCoreProvider));
      _appIdController.text = data.config['qobuzAppId'] as String? ?? '';
      _appSecretController.text =
          data.config['qobuzAppSecret'] as String? ?? '';
      _authTokenController.text =
          data.config['qobuzAuthToken'] as String? ?? '';
      _soulseekUsernameController.text =
          data.config['soulseekUsername'] as String? ?? '';
      _soulseekPasswordController.text =
          data.config['soulseekPassword'] as String? ?? '';
      setState(() => _data = data);
    } catch (e) {
      setState(() => _loadError = e);
    }
  }

  /// Re-reads Core without touching what the user is typing.
  void _refresh() {
    try {
      final data = loadSources(ref.read(flacCoreProvider));
      setState(() => _data = data);
    } catch (e) {
      setState(() => _loadError = e);
    }
  }

  void _setPreferredSource(String source) {
    final l = AppLocalizations.of(context);
    try {
      ref.read(flacCoreProvider).callSync('setPreferredSource', {
        'source': source,
      });
      ref.invalidate(configProvider);
      _refresh();
    } catch (e) {
      _showError(l.sourcesSetPreferredFailed(describeCoreError(l, e)));
    }
  }

  void _toggleQualityFallback(bool value) {
    final data = _data;
    if (data == null) return;
    final l = AppLocalizations.of(context);
    try {
      final preferred = data.preferred;
      if (preferred != null) {
        ref.read(flacCoreProvider).callSync('setPreferredSource', {
          'source': preferred,
          'fallback': value,
        });
        ref.invalidate(configProvider);
      } else {
        // No preferred source: save the COMPLETE config, never a partial one.
        final updated = Map<String, dynamic>.from(data.config)
          ..['autoQualityFallback'] = value;
        ref.read(configProvider.notifier).save(updated);
      }
      _refresh();
    } catch (e) {
      _showError(l.sourcesFallbackFailed(describeCoreError(l, e)));
    }
  }

  void _saveQobuzCredentials() {
    final l = AppLocalizations.of(context);
    try {
      ref.read(flacCoreProvider).callSync('updateQobuzCredentials', {
        'appId': _appIdController.text.trim(),
        'appSecret': _appSecretController.text.trim(),
        'authToken': _authTokenController.text.trim(),
      });
      // Core wrote the config itself: drop the stale cached copy.
      ref.invalidate(configProvider);
      _showSuccess(l.sourcesQobuzUpdated);
    } catch (e) {
      _showError(l.sourcesSaveCredentialsFailed(describeCoreError(l, e)));
    }
  }

  void _saveSoulseekCredentials() {
    final l = AppLocalizations.of(context);
    try {
      final current = ref.read(configProvider).value ?? {};
      final updated = Map<String, dynamic>.from(current)
        ..['soulseekEnabled'] = true
        ..['soulseekUsername'] = _soulseekUsernameController.text.trim()
        ..['soulseekPassword'] = _soulseekPasswordController.text.trim();
      ref.read(configProvider.notifier).save(updated);
      _showSuccess(l.sourcesSoulseekUpdated);
    } catch (e) {
      _showError(l.sourcesSaveCredentialsFailed(describeCoreError(l, e)));
    }
  }

  void _testConnection() {
    final l = AppLocalizations.of(context);
    try {
      final inner =
          ref.read(flacCoreProvider).callResult('testQobuzConnection')
              as Map<String, dynamic>? ??
          {};
      if (inner['success'] == true) {
        _showSuccess(l.sourcesConnected);
      } else {
        _showError(
          l.sourcesConnectFailed(
            inner['error'] as String? ?? l.coreErrorGeneric,
          ),
        );
      }
    } catch (e) {
      _showError(l.sourcesTestFailed(describeCoreError(l, e)));
    }
  }

  void _saveSourceOrder(List<String> order) {
    final l = AppLocalizations.of(context);
    try {
      ref.read(flacCoreProvider).callSync('setSourceOrder', {'order': order});
    } catch (e) {
      _showError(l.sourcesSaveOrderFailed(describeCoreError(l, e)));
      _refresh();
    }
  }

  void _reorder(SourcesData data, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final order = [...data.order];
    order.insert(newIndex, order.removeAt(oldIndex));
    setState(
      () => _data = SourcesData(
        sources: data.sources,
        order: order,
        preferred: data.preferred,
        qualityFallback: data.qualityFallback,
        extensionNames: data.extensionNames,
        config: data.config,
      ),
    );
    _saveSourceOrder(order);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = _data;
    return Scaffold(
      appBar: AppBar(title: Text(l.sourcesTitle)),
      body: switch ((data, _loadError)) {
        (_, final Object error) => _LoadError(
          message: l.sourcesLoadFailed(describeCoreError(l, error)),
          onRetry: _load,
        ),
        (null, _) => const Center(child: CircularProgressIndicator()),
        (final SourcesData d, _) => _buildContent(context, l, d),
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l,
    SourcesData d,
  ) {
    return ListView(
      children: [
        _SectionHeader(l.sourcesPriority),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (o, n) => _reorder(d, o, n),
            children: [
              for (int i = 0; i < d.order.length; i++)
                ListTile(
                  key: ValueKey(d.order[i]),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(d.labelFor(d.order[i])),
                  trailing: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),

        _SectionHeader(l.sourcesAvailable),
        if (d.sources.isEmpty)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.sourcesNone),
          ),
        for (final source in d.sources)
          ListTile(
            leading: Icon(
              source.available ? Icons.check_circle : Icons.cancel,
              color: source.available ? Colors.greenAccent : Colors.grey,
            ),
            title: Text(source.label),
            subtitle: Text(source.available ? l.configured : l.notConfigured),
          ),

        _SectionHeader(l.sourcesPreferred),
        if (d.sources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: d.sources.any((s) => s.name == d.preferred)
                  ? d.preferred
                  : null,
              decoration: InputDecoration(
                labelText: l.sourcesPrimary,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final s in d.sources)
                  DropdownMenuItem(value: s.name, child: Text(s.label)),
              ],
              onChanged: (value) {
                if (value != null) _setPreferredSource(value);
              },
            ),
          ),

        SwitchListTile(
          secondary: const Icon(Icons.swap_horiz),
          title: Text(l.sourcesQualityFallback),
          subtitle: Text(l.sourcesQualityFallbackHint),
          value: d.qualityFallback,
          onChanged: _toggleQualityFallback,
        ),

        _SectionHeader(l.sourcesQobuzCredentials),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _field(_appIdController, l.sourcesAppId, Icons.key),
              const SizedBox(height: 12),
              _field(
                _appSecretController,
                l.sourcesAppSecret,
                Icons.lock_outline,
              ),
              const SizedBox(height: 12),
              _field(
                _authTokenController,
                l.sourcesAuthToken,
                Icons.token,
                obscure: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveQobuzCredentials,
                      icon: const Icon(Icons.save),
                      label: Text(l.save),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testConnection,
                      icon: const Icon(Icons.wifi_tethering),
                      label: Text(l.sourcesTestConnection),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        _SectionHeader(l.sourcesSoulseekCredentials),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _field(
                _soulseekUsernameController,
                l.sourcesUsername,
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _field(
                _soulseekPasswordController,
                l.sourcesPassword,
                Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveSoulseekCredentials,
                  icon: const Icon(Icons.save),
                  label: Text(l.save),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
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
