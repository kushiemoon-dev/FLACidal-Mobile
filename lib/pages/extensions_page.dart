import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';
import '../providers/core_provider.dart';
import 'extensions/add_source_dialog.dart';
import 'extensions/auth_dialog.dart';
import 'extensions/browse_tab.dart';
import 'extensions/enable_prompt.dart';
import 'extensions/installed_tab.dart';
import 'extensions/registry_merge.dart';

class ExtensionsPage extends ConsumerStatefulWidget {
  const ExtensionsPage({super.key});

  @override
  ConsumerState<ExtensionsPage> createState() => _ExtensionsPageState();
}

class _ExtensionsPageState extends ConsumerState<ExtensionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> _installed = [];
  List<Map<String, dynamic>> _registry = [];
  List<String> _sources = [];
  bool _loadingInstalled = true;
  bool _loadingRegistry = false;
  final Set<String> _installingIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInstalled();
    _loadSources();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _readInstalled() => [
    for (final e
        in ref.read(flacCoreProvider).callResult('getExtensions')
                as List<dynamic>? ??
            const [])
      if (e is Map) Map<String, dynamic>.from(e),
  ];

  List<String> _readSources() => [
    for (final s
        in ref.read(flacCoreProvider).callResult('getExtensionSources')
                as List<dynamic>? ??
            const [])
      s.toString(),
  ];

  Future<void> _loadInstalled() async {
    try {
      final installed = _readInstalled();
      if (mounted) {
        setState(() {
          _installed = installed;
          _loadingInstalled = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingInstalled = false);
    }
  }

  void _loadSources() {
    try {
      _sources = _readSources();
    } catch (_) {
      // The Browse tab still works with the default registry alone.
    }
  }

  /// Default registry first, then each added source. Calls run in parallel and
  /// a failing source never hides the others.
  Future<void> _loadRegistry() async {
    final l = AppLocalizations.of(context);
    final core = ref.read(flacCoreProvider);
    setState(() => _loadingRegistry = true);

    List<String> sources;
    try {
      sources = _readSources();
    } catch (_) {
      sources = _sources;
    }

    final urls = ['', ...sources];
    final outcomes = await Future.wait(
      urls.map((url) async {
        try {
          final result = await core.callResultAsync('getExtensionRegistry', {
            'url': url,
          });
          return (entries: registryEntries(result), error: null as Object?);
        } catch (e) {
          return (entries: <Map<String, dynamic>>[], error: e as Object?);
        }
      }),
    );

    if (!mounted) return;
    final failures = <String>[
      for (var i = 0; i < outcomes.length; i++)
        if (outcomes[i].error != null)
          i == 0
              ? l.extRegistryFailed(describeCoreError(l, outcomes[i].error!))
              : l.extRegistrySourceFailed(
                  urls[i],
                  describeCoreError(l, outcomes[i].error!),
                ),
    ];
    setState(() {
      _registry = mergeRegistries([for (final o in outcomes) o.entries]);
      _sources = sources;
      _loadingRegistry = false;
    });
    if (failures.isNotEmpty) _snack(failures.join('\n'));
  }

  Future<void> _installExtension(String id, String url) async {
    final l = AppLocalizations.of(context);
    final core = ref.read(flacCoreProvider);
    setState(() => _installingIds.add(id));
    List<Map<String, dynamic>> installed;
    try {
      await core.callResultAsync('installExtension', {'url': url});
      installed = _readInstalled();
      if (mounted) setState(() => _installed = installed);
      _snack(l.extAdded);
    } catch (e) {
      _snack(l.extInstallFailed(describeCoreError(l, e)));
      return;
    } finally {
      if (mounted) setState(() => _installingIds.remove(id));
    }
    // After the spinner is gone, so it does not keep spinning behind the dialog.
    await _promptEnable(id, installed);
  }

  /// A freshly installed extension is disabled. Ask before enabling it, using
  /// `hosts` from `getExtensions` (the install result only has the manifest).
  Future<void> _promptEnable(
    String id,
    List<Map<String, dynamic>> installed,
  ) async {
    final ext = installed.where((e) {
      final manifest = e['manifest'];
      return manifest is Map && manifest['id'] == id;
    }).firstOrNull;
    if (ext == null || ext['enabled'] == true || !mounted) return;

    final manifest = ext['manifest'] as Map<String, dynamic>;
    final accepted = await showEnablePrompt(
      context,
      name: manifest['name'] as String? ?? id,
      hosts: [for (final h in ext['hosts'] as List<dynamic>? ?? const []) '$h'],
      permissions: [
        for (final p in manifest['permissions'] as List<dynamic>? ?? const [])
          '$p',
      ],
    );
    if (accepted) await _toggleEnabled(id, true);
  }

  Future<void> _uninstall(String id) async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.extUninstallTitle),
        content: Text(l.extUninstallConfirm(id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.extUninstall),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      ref.read(flacCoreProvider).callSync('uninstallExtension', {'id': id});
      await _loadInstalled();
    } catch (e) {
      _snack(l.extActionFailed(describeCoreError(l, e)));
    }
  }

  Future<void> _toggleEnabled(String id, bool enabled) async {
    final l = AppLocalizations.of(context);
    try {
      ref.read(flacCoreProvider).callSync('enableExtension', {
        'id': id,
        'enabled': enabled,
      });
      await _loadInstalled();
    } catch (e) {
      _snack(l.extActionFailed(describeCoreError(l, e)));
    }
  }

  Future<void> _configure(Map<String, dynamic> ext) async {
    final l = AppLocalizations.of(context);
    final manifest = ext['manifest'] as Map<String, dynamic>? ?? {};
    final id = manifest['id'] as String? ?? '';
    final fields = [
      for (final f in manifest['authFields'] as List<dynamic>? ?? const [])
        if (f is Map) Map<String, dynamic>.from(f),
    ];
    if (fields.isEmpty) {
      _snack(l.extNothingToConfigure);
      return;
    }

    final data = await showAuthDialog(
      context,
      title: l.extConfigureTitle('${manifest['name'] ?? id}'),
      fields: fields,
      authSet: ext['authSet'] as Map<String, dynamic>? ?? const {},
    );
    // Cancelled, or nothing typed: Core keeps the stored values either way.
    if (data == null || data.isEmpty) return;

    try {
      ref.read(flacCoreProvider).callSync('setExtensionAuth', {
        'id': id,
        'data': data,
      });
      await _loadInstalled();
      _snack(l.extConfigUpdated);
    } catch (e) {
      _snack(l.extActionFailed(describeCoreError(l, e)));
    }
  }

  Future<void> _addSource() async {
    final l = AppLocalizations.of(context);
    final url = await showAddSourceDialog(context);
    if (url == null) return;
    try {
      ref.read(flacCoreProvider).callSync('addExtensionSource', {'url': url});
      setState(() => _sources = [..._sources, url]);
      _snack(l.extSourceAdded);
      await _loadRegistry();
    } catch (e) {
      _snack(l.extSourceAddFailed(describeCoreError(l, e)));
    }
  }

  Future<void> _removeSource(String url) async {
    final l = AppLocalizations.of(context);
    try {
      ref.read(flacCoreProvider).callSync('removeExtensionSource', {
        'url': url,
      });
      setState(() => _sources = [..._sources.where((s) => s != url)]);
    } catch (e) {
      _snack(l.extSourceRemoveFailed(describeCoreError(l, e)));
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, String> get _installedVersions => {
    for (final e in _installed)
      if (e['manifest'] is Map)
        '${(e['manifest'] as Map)['id']}':
            '${(e['manifest'] as Map)['version'] ?? ''}',
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.extTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.extTabInstalled),
            Tab(text: l.extTabBrowse),
          ],
          onTap: (i) {
            if (i == 1 && _registry.isEmpty && !_loadingRegistry) {
              _loadRegistry();
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InstalledTab(
            loading: _loadingInstalled,
            installed: _installed,
            onRefresh: _loadInstalled,
            onToggle: _toggleEnabled,
            onConfigure: _configure,
            onUninstall: _uninstall,
          ),
          BrowseTab(
            loading: _loadingRegistry,
            registry: _registry,
            installedVersions: _installedVersions,
            installingIds: _installingIds,
            sources: _sources,
            onRefresh: _loadRegistry,
            onInstall: _installExtension,
            onAddSource: _addSource,
            onRemoveSource: _removeSource,
          ),
        ],
      ),
    );
  }
}
