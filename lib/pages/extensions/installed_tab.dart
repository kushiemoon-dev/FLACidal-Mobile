import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class InstalledTab extends StatelessWidget {
  const InstalledTab({
    super.key,
    required this.loading,
    required this.installed,
    required this.onRefresh,
    required this.onToggle,
    required this.onConfigure,
    required this.onUninstall,
  });

  final bool loading;
  final List<Map<String, dynamic>> installed;
  final Future<void> Function() onRefresh;
  final void Function(String id, bool enabled) onToggle;
  final void Function(Map<String, dynamic> ext) onConfigure;
  final void Function(String id) onUninstall;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (loading) return const Center(child: CircularProgressIndicator());
    if (installed.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.extension, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l.extNoneInstalled),
            const SizedBox(height: 8),
            Text(
              l.extNoneInstalledHint,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: installed.length,
        itemBuilder: (context, i) {
          final ext = installed[i];
          final manifest = ext['manifest'] as Map<String, dynamic>? ?? {};
          final id = manifest['id'] as String? ?? '';
          final name = manifest['name'] as String? ?? id;
          final version = manifest['version'] as String? ?? '';
          final author = manifest['author'] as String? ?? '';
          final enabled = ext['enabled'] as bool? ?? false;
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
                        Text(l.extPermissions(permissions.join(', '))),
                      ],
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(value: enabled, onChanged: (v) => onToggle(id, v)),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      switch (v) {
                        case 'configure':
                          onConfigure(ext);
                        case 'uninstall':
                          onUninstall(id);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'configure',
                        child: Text(l.extConfigure),
                      ),
                      PopupMenuItem(
                        value: 'uninstall',
                        child: Text(l.extUninstall),
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
}
