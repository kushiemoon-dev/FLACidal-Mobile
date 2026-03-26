import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../providers/core_provider.dart';

/// Home page — paste a URL, fetch content, select tracks, download.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _urlController = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _content;
  Set<int> _selectedTracks = {};

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
      _fetchContent();
    }
  }

  Future<void> _fetchContent() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _content = null;
      _selectedTracks = {};
    });

    try {
      final core = ref.read(flacCoreProvider);
      final result = core.fetchContent(url);
      final content = result['result'] as Map<String, dynamic>?;
      setState(() {
        _content = content;
        _loading = false;
        // Select all tracks by default
        final tracks = _getTracks();
        _selectedTracks = Set.from(
          List.generate(tracks.length, (i) => i),
        );
      });
    } on FlacCoreException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<dynamic> _getTracks() {
    if (_content == null) return [];
    // Content can be a track, album, playlist, or artist
    if (_content!.containsKey('Tracks')) {
      return _content!['Tracks'] as List<dynamic>? ?? [];
    }
    // Single track
    if (_content!.containsKey('ID') && _content!.containsKey('Title')) {
      return [_content!];
    }
    return [];
  }

  Future<void> _downloadSelected() async {
    final tracks = _getTracks();
    if (tracks.isEmpty) return;

    final selectedTracks = _selectedTracks
        .map((i) => tracks[i] as Map<String, dynamic>)
        .toList();

    try {
      final core = ref.read(flacCoreProvider);
      core.queueDownloads(selectedTracks, '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Queued ${selectedTracks.length} tracks'),
            action: SnackBarAction(
              label: 'View Queue',
              onPressed: () => Navigator.of(context).pushNamed('/queue'),
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLACidal'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // URL Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'Paste Tidal or Qobuz URL...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.content_paste),
                        onPressed: _pasteFromClipboard,
                        tooltip: 'Paste from clipboard',
                      ),
                    ),
                    onSubmitted: (_) => _fetchContent(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _fetchContent,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Fetch'),
                ),
              ],
            ),
          ),

          // Error
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!)),
                    ],
                  ),
                ),
              ),
            ),

          // Content
          if (_content != null) ...[
            _buildContentHeader(),
            const Divider(),
            // Track list
            Expanded(child: _buildTrackList()),
          ] else if (!_loading && _error == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.music_note, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Paste a Tidal or Qobuz URL to get started'),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Download FAB
      floatingActionButton: _content != null && _selectedTracks.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _downloadSelected,
              icon: const Icon(Icons.download),
              label: Text('Download ${_selectedTracks.length}'),
            )
          : null,
    );
  }

  Widget _buildContentHeader() {
    final title = _content?['Title'] ?? _content?['Name'] ?? 'Unknown';
    final artist = _content?['Artist'] ?? _content?['Creator'] ?? '';
    final tracks = _getTracks();
    final coverUrl = _content?['CoverURL'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Cover art
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: coverUrl.isNotEmpty
                ? Image.network(coverUrl, width: 80, height: 80, fit: BoxFit.cover)
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Icon(Icons.album, size: 40),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (artist.toString().isNotEmpty)
                  Text(artist.toString(),
                      style: Theme.of(context).textTheme.bodyMedium),
                Text('${tracks.length} tracks',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          // Select all / none
          IconButton(
            icon: Icon(
              _selectedTracks.length == tracks.length
                  ? Icons.deselect
                  : Icons.select_all,
            ),
            onPressed: () {
              setState(() {
                if (_selectedTracks.length == tracks.length) {
                  _selectedTracks = {};
                } else {
                  _selectedTracks = Set.from(
                    List.generate(tracks.length, (i) => i),
                  );
                }
              });
            },
            tooltip: _selectedTracks.length == tracks.length
                ? 'Deselect all'
                : 'Select all',
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    final tracks = _getTracks();

    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index] as Map<String, dynamic>;
        final title = track['Title'] ?? 'Unknown';
        final artist = track['Artist'] ?? '';
        final trackNum = track['TrackNumber'] ?? (index + 1);
        final duration = track['Duration'] as int? ?? 0;
        final minutes = duration ~/ 60;
        final seconds = duration % 60;
        final selected = _selectedTracks.contains(index);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            foregroundColor: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            child: Text('$trackNum'),
          ),
          title: Text(title.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(artist.toString()),
          trailing: Text('$minutes:${seconds.toString().padLeft(2, '0')}'),
          selected: selected,
          onTap: () {
            setState(() {
              if (selected) {
                _selectedTracks = Set.from(_selectedTracks)..remove(index);
              } else {
                _selectedTracks = Set.from(_selectedTracks)..add(index);
              }
            });
          },
        );
      },
    );
  }
}
