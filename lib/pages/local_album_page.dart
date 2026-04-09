import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flac_core.dart';
import '../providers/core_provider.dart';

/// Displays files grouped by album, with disc grouping and track ordering.
class LocalAlbumPage extends ConsumerStatefulWidget {
  final String albumName;
  final List<Map<String, dynamic>> tracks;

  const LocalAlbumPage({
    super.key,
    required this.albumName,
    required this.tracks,
  });

  @override
  ConsumerState<LocalAlbumPage> createState() => _LocalAlbumPageState();
}

class _LocalAlbumPageState extends ConsumerState<LocalAlbumPage> {
  Set<int> _selected = {};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
  }

  String? _findCoverArt() {
    for (final track in widget.tracks) {
      final path = (track['path'] ?? '').toString();
      if (path.isEmpty) continue;
      // Check companion .jpg
      final jpgPath = '${path.replaceAll(RegExp(r'\.flac$'), '')}.jpg';
      if (File(jpgPath).existsSync()) return jpgPath;
      // Check cover.jpg in directory
      final dirCover = '${File(path).parent.path}/cover.jpg';
      if (File(dirCover).existsSync()) return dirCover;
    }
    return null;
  }

  /// Group tracks by disc number, sorted by track number within each disc.
  Map<int, List<Map<String, dynamic>>> _groupByDisc() {
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final track in widget.tracks) {
      final disc = (track['discNumber'] as num?)?.toInt() ?? 1;
      grouped.putIfAbsent(disc, () => []).add(track);
    }
    // Sort tracks within each disc by track number
    for (final tracks in grouped.values) {
      tracks.sort((a, b) {
        final aNum = (a['trackNumber'] as num?)?.toInt() ?? 0;
        final bNum = (b['trackNumber'] as num?)?.toInt() ?? 0;
        return aNum.compareTo(bNum);
      });
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      _selected = Set.from(_selected);
      if (_selected.contains(index)) {
        _selected.remove(index);
        if (_selected.isEmpty) _selectionMode = false;
      } else {
        _selected.add(index);
      }
    });
  }

  void _enterSelectionMode(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectionMode = true;
      _selected = {index};
    });
  }

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Files'),
        content: Text('Delete ${_selected.length} selected file(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final core = ref.read(flacCoreProvider);
    for (final idx in _selected) {
      final path = widget.tracks[idx]['path'] ?? '';
      if (path.toString().isNotEmpty) {
        try {
          core.callSync('deleteFile', {'path': path});
        } catch (_) {}
      }
    }
    setState(() {
      _selectionMode = false;
      _selected = {};
    });
    if (mounted) Navigator.pop(context, true); // Signal refresh
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final coverPath = _findCoverArt();
    final discGroups = _groupByDisc();
    final multiDisc = discGroups.length > 1;

    // Compute artist from first track
    final artist = widget.tracks.isNotEmpty
        ? (widget.tracks.first['artist'] ?? '').toString()
        : '';

    // Quality info from first track
    final quality = widget.tracks.isNotEmpty
        ? (widget.tracks.first['quality'] ?? '').toString()
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode
            ? '${_selected.length} selected'
            : widget.albumName),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  _selected = Set.from(
                    List.generate(widget.tracks.length, (i) => i),
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selected.isNotEmpty ? _deleteSelected : null,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectionMode = false;
                  _selected = {};
                });
              },
            ),
          ],
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Album header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: coverPath != null
                          ? Image.file(File(coverPath), fit: BoxFit.cover)
                          : Container(
                              color: cs.surfaceContainerHighest,
                              child: const Icon(Icons.album, size: 48),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.albumName,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (artist.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            artist,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${widget.tracks.length} tracks${quality.isNotEmpty ? ' · $quality' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Track list grouped by disc
          ...discGroups.entries.expand((entry) {
            final discNum = entry.key;
            final tracks = entry.value;

            return [
              if (multiDisc)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      'Disc $discNum',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final track = tracks[i];
                    final globalIndex = widget.tracks.indexOf(track);
                    final title = (track['title'] ?? track['name'] ?? 'Unknown').toString();
                    final trackNum = (track['trackNumber'] as num?)?.toInt() ?? (i + 1);
                    final trackArtist = (track['artist'] ?? '').toString();
                    final isSelected = _selected.contains(globalIndex);

                    return Material(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      child: InkWell(
                        onTap: _selectionMode
                            ? () => _toggleSelection(globalIndex)
                            : null,
                        onLongPress: !_selectionMode
                            ? () => _enterSelectionMode(globalIndex)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '$trackNum',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (trackArtist.isNotEmpty)
                                      Text(
                                        trackArtist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: cs.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_selectionMode)
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleSelection(globalIndex),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: tracks.length,
                ),
              ),
            ];
          }),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}
