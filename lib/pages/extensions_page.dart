import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

/// Extensions page — browse, install, configure extensions.
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
  bool _loadingInstalled = true;
  bool _loadingRegistry = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInstalled();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      final result = core.callSync('getExtensionRegistry', {'url': ''});
      setState(() {
        _registry = result['result'] as List<dynamic>? ?? [];
        _loadingRegistry = false;
      });
    } catch (e) {
      setState(() {
        _loadingRegistry = false;
        _registry = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load registry: $e')),
        );
      }
    }
  }

  Future<void> _installExtension(String url) async {
    try {
      final core = ref.read(flacCoreProvider);
      core.callSync('installExtension', {'url': url});
      _loadInstalled();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Extension installed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Install failed: $e')),
        );
      }
    }
  }

  Future<void> _uninstall(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uninstall Extension'),
        content: Text('Remove extension "$id"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Uninstall')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        ref.read(flacCoreProvider).callSync('uninstallExtension', {'id': id});
        _loadInstalled();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleEnabled(String id, bool enabled) async {
    try {
      ref.read(flacCoreProvider)
          .callSync('enableExtension', {'id': id, 'enabled': enabled});
      _loadInstalled();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
        const SnackBar(content: Text('No configuration needed')),
      );
      return;
    }

    final controllers = <String, TextEditingController>{};
    for (final field in authFields) {
      final f = field as Map<String, dynamic>;
      final key = f['key'] as String? ?? '';
      controllers[key] = TextEditingController(
          text: currentAuth[key]?.toString() ?? '');
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
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (saved == true) {
      final data = <String, String>{};
      for (final entry in controllers.entries) {
        data[entry.key] = entry.value.text;
      }
      try {
        ref.read(flacCoreProvider)
            .callSync('setExtensionAuth', {'id': id, 'data': data});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuration saved')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    for (final c in controllers.values) {
      c.dispose();
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
        children: [
          _buildInstalledTab(),
          _buildRegistryTab(),
        ],
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
            Text('No extensions installed'),
            SizedBox(height: 8),
            Text('Browse the registry to find extensions',
                style: TextStyle(color: Colors.grey)),
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
          final caps = (manifest['capabilities'] as List<dynamic>?)
                  ?.map((c) => c.toString())
                  .join(', ') ??
              '';

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
              subtitle: Text('$author · v$version · $caps'),
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
                          value: 'configure', child: Text('Configure')),
                      PopupMenuItem(
                          value: 'uninstall', child: Text('Uninstall')),
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
            const Text('No extensions available'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loadRegistry,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final installedIds =
        _installed.map((e) {
          final m = (e as Map<String, dynamic>)['manifest'] as Map<String, dynamic>? ?? {};
          return m['id'] as String? ?? '';
        }).toSet();

    return RefreshIndicator(
      onRefresh: _loadRegistry,
      child: ListView.builder(
        itemCount: _registry.length,
        itemBuilder: (context, i) {
          final item = _registry[i] as Map<String, dynamic>;
          final id = item['id'] as String? ?? '';
          final name = item['name'] as String? ?? id;
          final desc = item['description'] as String? ?? '';
          final version = item['latestVersion'] as String? ?? '';
          final downloadURL = item['downloadURL'] as String? ?? '';
          final installed = installedIds.contains(id);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.extension)),
              title: Text(name),
              subtitle: Text(
                  '$desc${version.isNotEmpty ? '\nv$version' : ''}'),
              isThreeLine: desc.isNotEmpty,
              trailing: installed
                  ? const Chip(label: Text('Installed'))
                  : FilledButton(
                      onPressed: downloadURL.isNotEmpty
                          ? () => _installExtension(downloadURL)
                          : null,
                      child: const Text('Install'),
                    ),
            ),
          );
        },
      ),
    );
  }
}
