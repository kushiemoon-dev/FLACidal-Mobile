import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Category keys match the lowercase `category` Core sends in registry entries.
const extensionCategories = [
  'all',
  'download',
  'metadata',
  'lyrics',
  'utility',
];

class BrowseTab extends StatefulWidget {
  const BrowseTab({
    super.key,
    required this.loading,
    required this.registry,
    required this.installedVersions,
    required this.installingIds,
    required this.sources,
    required this.onRefresh,
    required this.onInstall,
    required this.onAddSource,
    required this.onRemoveSource,
  });

  final bool loading;
  final List<Map<String, dynamic>> registry;
  final Map<String, String> installedVersions;
  final Set<String> installingIds;
  final List<String> sources;
  final Future<void> Function() onRefresh;
  final void Function(String id, String url) onInstall;
  final VoidCallback onAddSource;
  final void Function(String url) onRemoveSource;

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l, String key) => switch (key) {
    'download' => l.extCategoryDownload,
    'metadata' => l.extCategoryMetadata,
    'lyrics' => l.extCategoryLyrics,
    'utility' => l.extCategoryUtility,
    _ => l.extCategoryAll,
  };

  List<Map<String, dynamic>> get _filtered {
    final query = _query.toLowerCase();
    return widget.registry.where((m) {
      final name = (m['name'] as String? ?? '').toLowerCase();
      final desc = (m['description'] as String? ?? '').toLowerCase();
      final category = (m['category'] as String? ?? '').toLowerCase();
      if (query.isNotEmpty && !name.contains(query) && !desc.contains(query)) {
        return false;
      }
      return _category == 'all' || category == _category;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (widget.loading) return const Center(child: CircularProgressIndicator());

    final filtered = _filtered;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        slivers: [
          if (widget.registry.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_download,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(l.extNoneAvailable),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: widget.onRefresh,
                      child: Text(l.extRefresh),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l.extSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final cat in extensionCategories)
                      FilterChip(
                        label: Text(_categoryLabel(l, cat)),
                        selected: _category == cat,
                        onSelected: (_) => setState(() => _category = cat),
                      ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _entryCard(context, l, filtered[i]),
                childCount: filtered.length,
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
              child: Row(
                children: [
                  Text(
                    l.extSources,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: widget.onAddSource,
                    tooltip: l.extAddSource,
                  ),
                ],
              ),
            ),
          ),
          if (widget.sources.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  l.extNoExtraSources,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final url = widget.sources[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  leading: const Icon(Icons.source),
                  title: Text(url, style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => widget.onRemoveSource(url),
                  ),
                ),
              );
            }, childCount: widget.sources.length),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _entryCard(
    BuildContext context,
    AppLocalizations l,
    Map<String, dynamic> item,
  ) {
    final id = item['id'] as String? ?? '';
    final name = item['name'] as String? ?? id;
    final desc = item['description'] as String? ?? '';
    final version = item['latestVersion'] as String? ?? '';
    final downloadURL = item['downloadURL'] as String? ?? '';
    final installedVersion = widget.installedVersions[id];
    final installed = installedVersion != null;
    final hasUpdate =
        installed && installedVersion != version && version.isNotEmpty;
    final permissions =
        (item['permissions'] as List<dynamic>?)
            ?.map((p) => p.toString())
            .toList() ??
        [];
    final onInstall = downloadURL.isNotEmpty
        ? () => widget.onInstall(id, downloadURL)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.extension)),
        title: Text(name),
        subtitle: Text(
          '$desc${version.isNotEmpty ? '\nv$version' : ''}'
          '${permissions.isNotEmpty ? '\n${l.extPermissions(permissions.join(', '))}' : ''}',
        ),
        isThreeLine: desc.isNotEmpty || permissions.isNotEmpty,
        trailing: widget.installingIds.contains(id)
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : hasUpdate
            ? FilledButton(onPressed: onInstall, child: Text(l.extUpdate))
            : installed
            ? Chip(label: Text(l.extInstalledChip))
            : FilledButton(onPressed: onInstall, child: Text(l.extInstall)),
      ),
    );
  }
}
