import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

class ExtensionsPage extends ConsumerStatefulWidget {
  const ExtensionsPage({super.key});

  @override
  ConsumerState<ExtensionsPage> createState() => _ExtensionsPageState();
}

class _ExtensionsPageState extends ConsumerState<ExtensionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<dynamic> _installed = [];
  List<dynamic> _registry = [];
  List<String> _sources = [];
  bool _loadingInstalled = true;
  bool _loadingRegistry = false;
  final Set<String> _installingIds = {};

  // Filters used on the Browse tab
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  static const _categories = [
    'All',
    'Download',
    'Metadata',
    'Lyrics',
    'Utility',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInstalled();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstalled() async {
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('getExtensions');
      setState(() {
        _installed = result['result'] as List<dynamic>? ?? [];
        _loadingInstalled = false;
      });
    } catch (e) {
      setState(() => _loadingInstalled = false);
    }
  }

  Future<void> _loadRegistry() async {
    setState(() => _loadingRegistry = true);
    try {
      final core = ref.read(flacCoreProvider);
      final result = await core.callAsync('getExtensionRegistry', {'url': ''});
      final sourcesResult = core.callSync('getExtensionSources');
      setState(() {
        _registry = result['result'] as List<dynamic>? ?? [];
        _sources =
            (sourcesResult['result'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        _loadingRegistry = false;
      });
    } catch (e) {
      setState(() {
        _loadingRegistry = false;
        _registry = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load the registry: $e')),
        );
      }
    }
  }

  Future<void> _installExtension(String id, String url) async {
    setState(() => _installingIds.add(id));
    try {
      final core = ref.read(flacCoreProvider);
      await core.callAsync('installExtension', {'url': url});
      _loadInstalled();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Extension added')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Installation failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _installingIds.remove(id));
    }
  }

  Future<void> _uninstall(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uninstall Extension'),
        content: Text('Remove the "$id" extension?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        ref.read(flacCoreProvider).callSync('uninstallExtension', {'id': id});
        _loadInstalled();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
        }
      }
    }
  }

  Future<void> _toggleEnabled(String id, bool enabled) async {
    try {
      ref.read(flacCoreProvider).callSync('enableExtension', {
        'id': id,
        'enabled': enabled,
      });
      _loadInstalled();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
      }
    }
  }

  Future<void> _configure(Map<String, dynamic> ext) async {
    final manifest = ext['manifest'] as Map<String, dynamic>? ?? {};
    final id = manifest['id'] as String? ?? '';
    final authFields = manifest['authFields'] as List<dynamic>? ?? [];
    final currentAuth = ext['authData'] as Map<String, dynamic>? ?? {};

    if (authFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to configure here')),
      );
      return;
    }

    final controllers = <String, TextEditingController>{};
    for (final field in authFields) {
      final f = field as Map<String, dynamic>;
      final key = f['key'] as String? ?? '';
      controllers[key] = TextEditingController(
        text: currentAuth[key]?.toString() ?? '',
      );
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Configure ${manifest['name'] ?? id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: authFields.map((field) {
            final f = field as Map<String, dynamic>;
            final key = f['key'] as String? ?? '';
            final label = f['label'] as String? ?? key;
            final isPassword = f['type'] == 'password';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: controllers[key],
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
                obscureText: isPassword,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      final data = <String, String>{};
      for (final entry in controllers.entries) {
        data[entry.key] = entry.value.text;
      }
      try {
        ref.read(flacCoreProvider).callSync('setExtensionAuth', {
          'id': id,
          'data': data,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuration updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
        }
      }
    }

    for (final c in controllers.values) {
      c.dispose();
    }
  }

  Future<void> _addSource() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Extension Source'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'GitHub Repository URL',
            hintText: 'https://github.com/owner/repo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (url != null && url.isNotEmpty) {
      try {
        ref.read(flacCoreProvider).callSync('addExtensionSource', {'url': url});
        setState(() => _sources.add(url));
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('New source added')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
        }
      }
    }
  }

  Future<void> _removeSource(String url) async {
    try {
      ref.read(flacCoreProvider).callSync('removeExtensionSource', {
        'url': url,
      });
      setState(() => _sources.remove(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extensions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Installed'),
            Tab(text: 'Browse'),
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
        children: [_buildInstalledTab(), _buildRegistryTab()],
      ),
    );
  }

  Widget _buildInstalledTab() {
    if (_loadingInstalled) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_installed.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.extension, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nothing installed yet'),
            SizedBox(height: 8),
            Text(
              'Check the registry to find extensions',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInstalled,
      child: ListView.builder(
        itemCount: _installed.length,
        itemBuilder: (context, i) {
          final ext = _installed[i] as Map<String, dynamic>;
          final manifest = ext['manifest'] as Map<String, dynamic>? ?? {};
          final id = manifest['id'] as String? ?? '';
          final name = manifest['name'] as String? ?? id;
          final version = manifest['version'] as String? ?? '';
          final author = manifest['author'] as String? ?? '';
          final enabled = ext['enabled'] as bool? ?? true;
          final caps =
              (manifest['capabilities'] as List<dynamic>?)
                  ?.map((c) => c.toString())
                  .join(', ') ??
              '';
          final permissions =
              (manifest['permissions'] as List<dynamic>?)
                  ?.map((p) => p.toString())
                  .toList() ??
              [];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: enabled
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.grey[800],
                child: Icon(
                  Icons.extension,
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
              title: Text(name),
              subtitle: permissions.isEmpty
                  ? Text('$author · v$version · $caps')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$author · v$version · $caps'),
                        Text('Permissions: ${permissions.join(", ")}'),
                      ],
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: enabled,
                    onChanged: (v) => _toggleEnabled(id, v),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      switch (v) {
                        case 'configure':
                          _configure(ext);
                        case 'uninstall':
                          _uninstall(id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'configure',
                        child: Text('Configure'),
                      ),
                      PopupMenuItem(
                        value: 'uninstall',
                        child: Text('Uninstall'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<dynamic> get _filteredRegistry {
    return _registry.where((item) {
      final m = item as Map<String, dynamic>;
      final name = (m['name'] as String? ?? '').toLowerCase();
      final desc = (m['description'] as String? ?? '').toLowerCase();
      final category = (m['category'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      if (query.isNotEmpty && !name.contains(query) && !desc.contains(query)) {
        return false;
      }

      if (_selectedCategory != 'All' &&
          category != _selectedCategory.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildRegistryTab() {
    if (_loadingRegistry) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_registry.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_download, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nothing available right now'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loadRegistry,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final installedVersions = {
      for (final e in _installed)
        ((e as Map<String, dynamic>)['manifest'] as Map<String, dynamic>? ??
                        {})['id']
                    as String? ??
                '':
            ((e)['manifest'] as Map<String, dynamic>? ?? {})['version']
                as String? ??
            '',
    };

    final filtered = _filteredRegistry;

    return RefreshIndicator(
      onRefresh: _loadRegistry,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Find extensions...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final item = filtered[i] as Map<String, dynamic>;
              final id = item['id'] as String? ?? '';
              final name = item['name'] as String? ?? id;
              final desc = item['description'] as String? ?? '';
              final version = item['latestVersion'] as String? ?? '';
              final downloadURL = item['downloadURL'] as String? ?? '';
              final installedVersion = installedVersions[id];
              final installed = installedVersion != null;
              final hasUpdate =
                  installed &&
                  installedVersion != version &&
                  version.isNotEmpty;
              final permissions =
                  (item['permissions'] as List<dynamic>?)
                      ?.map((p) => p.toString())
                      .toList() ??
                  [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.extension)),
                  title: Text(name),
                  subtitle: Text(
                    '$desc${version.isNotEmpty ? '\nv$version' : ''}'
                    '${permissions.isNotEmpty ? '\nPermissions: ${permissions.join(", ")}' : ''}',
                  ),
                  isThreeLine: desc.isNotEmpty || permissions.isNotEmpty,
                  trailing: hasUpdate
                      ? FilledButton(
                          onPressed: downloadURL.isNotEmpty
                              ? () => _installExtension(id, downloadURL)
                              : null,
                          child: const Text('Update'),
                        )
                      : installed
                      ? const Chip(label: Text('Installed'))
                      : _installingIds.contains(id)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton(
                          onPressed: downloadURL.isNotEmpty
                              ? () => _installExtension(id, downloadURL)
                              : null,
                          child: const Text('Install'),
                        ),
                ),
              );
            }, childCount: filtered.length),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
              child: Row(
                children: [
                  Text(
                    'Sources',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSource,
                    tooltip: 'Add source',
                  ),
                ],
              ),
            ),
          ),
          if (_sources.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'No extra sources set up',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final url = _sources[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  leading: const Icon(Icons.source),
                  title: Text(url, style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeSource(url),
                  ),
                ),
              );
            }, childCount: _sources.length),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}
