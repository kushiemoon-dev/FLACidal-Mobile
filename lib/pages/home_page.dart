import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/exceptions.dart';
import '../core/url_resolver.dart';
import '../providers/core_provider.dart';
import '../providers/shared_url_provider.dart';
import '../widgets/cover_art_tile.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/track_list_tile.dart';
import '../l10n/app_localizations.dart';
import '../widgets/error_text.dart';
import '../core/core_errors.dart';

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
  void initState() {
    super.initState();
    // Look for a shared URL once the first frame has rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sharedUrl = ref.read(sharedUrlProvider);
      if (sharedUrl != null && sharedUrl.isNotEmpty) {
        _urlController.text = sharedUrl;
        ref.read(sharedUrlProvider.notifier).clear();
        _fetchContent();
      }
    });
  }

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
    var url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _content = null;
      _selectedTracks = {};
    });

    try {
      // URLs that aren't native (Tidal/Qobuz/Deezer/Bandcamp) get resolved through Odesli
      final lower = url.toLowerCase();
      final isNativeUrl =
          lower.contains('tidal.com') ||
          lower.contains('qobuz.com') ||
          lower.contains('deezer.com') ||
          lower.contains('bandcamp.com');
      if (!isNativeUrl) {
        final resolved = await URLResolver.resolve(url);
        if (resolved != null) {
          url = resolved.bestUrl;
          _urlController.text = url;
        } else {
          setState(() {
            _error = AppLocalizations.of(context).homeResolveFailed;
            _loading = false;
          });
          return;
        }
      }

      final core = ref.read(flacCoreProvider);
      final result = core.fetchContent(url);
      final content = result['result'] as Map<String, dynamic>?;
      setState(() {
        _content = content;
        _loading = false;
        final tracks = _getTracks();
        _selectedTracks = Set.from(List.generate(tracks.length, (i) => i));
      });
    } on FlacCoreException catch (e) {
      setState(() {
        _error = describeCoreError(AppLocalizations.of(context), e);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = describeCoreError(AppLocalizations.of(context), e);
        _loading = false;
      });
    }
  }

  List<dynamic> _getTracks() {
    if (_content == null) return [];
    // The content might be a track, album, playlist, or artist
    if (_content!.containsKey('tracks')) {
      return _content!['tracks'] as List<dynamic>? ?? [];
    }
    if (_content!.containsKey('id') && _content!.containsKey('title')) {
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
      final source = _content?['source'] as String? ?? 'tidal';
      if (source == 'qobuz') {
        core.callSync('queueQobuzDownloads', {
          'tracks': selectedTracks,
          'outputDir': core.downloadDir,
        });
      } else {
        core.queueDownloads(selectedTracks, core.downloadDir);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).tracksQueued(selectedTracks.length)),
            action: SnackBarAction(
              label: AppLocalizations.of(context).viewQueue,
              onPressed: () => context.go('/queue'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(genericErrorText(context, e))));
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
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: AppLocalizations.of(context).homeImportCsv,
            onPressed: () => context.push('/csv-import'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).homeUrlHint,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.content_paste),
                        onPressed: _pasteFromClipboard,
                        tooltip: AppLocalizations.of(context).homePasteTooltip,
                      ),
                    ),
                    onSubmitted: (_) => _fetchContent(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          _fetchContent();
                        },
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context).homeFetch),
                ),
              ],
            ),
          ),

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

          if (_loading)
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SkeletonLoader(layout: SkeletonLayout.detailHeader),
                    SkeletonLoader(layout: SkeletonLayout.trackList),
                  ],
                ),
              ),
            )
          else if (_content != null) ...[
            _buildContentHeader(),
            const Divider(),
            Expanded(child: _buildTrackList()),
          ] else if (_error == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context).homeGetStarted),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _content != null && _selectedTracks.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.lightImpact();
                _downloadSelected();
              },
              icon: const Icon(Icons.download),
              label: Text(AppLocalizations.of(context).downloadCount(_selectedTracks.length)),
            )
          : null,
    );
  }

  Widget _buildContentHeader() {
    final title = _content?['title'] ?? _content?['name'] ?? 'Unknown';
    final artist = _content?['artist'] ?? _content?['creator'] ?? '';
    final tracks = _getTracks();
    final coverUrl = _content?['coverUrl'] ?? _content?['coverURL'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CoverArtTile(
            imageUrl: coverUrl.isNotEmpty ? coverUrl : null,
            size: 80,
            borderRadius: 8,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (artist.toString().isNotEmpty)
                  Text(
                    artist.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                Text(
                  AppLocalizations.of(context).tracksCount(tracks.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
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
                ? AppLocalizations.of(context).deselectAll
                : AppLocalizations.of(context).selectAll,
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
        final title = track['title'] ?? track['Title'] ?? 'Unknown';
        final artist = track['artist'] ?? track['Artist'] ?? '';
        final trackNum =
            track['trackNumber'] ?? track['TrackNumber'] ?? (index + 1);
        final duration = ((track['duration'] ?? track['Duration'] ?? 0) as num)
            .toInt();
        final selected = _selectedTracks.contains(index);

        return TrackListTile(
          trackNumber: (trackNum as num).toInt(),
          title: title.toString(),
          artist: artist.toString(),
          duration: duration,
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
