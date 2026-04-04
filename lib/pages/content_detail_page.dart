import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/exceptions.dart';
import '../core/flac_core.dart';
import '../providers/core_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/track_list_tile.dart';

/// Detail page for an album or playlist — shows cover, metadata, track list.
class ContentDetailPage extends ConsumerStatefulWidget {
  final String type; // "album" or "playlist"
  final String id;
  const ContentDetailPage({super.key, required this.type, required this.id});

  @override
  ConsumerState<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends ConsumerState<ContentDetailPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _content;
  Set<int> _selected = {};
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final core = ref.read(flacCoreProvider);
      final url = 'https://tidal.com/${widget.type}/${widget.id}';
      final result = core.fetchContent(url);
      final content = result['result'] as Map<String, dynamic>?;
      setState(() {
        _content = content;
        _loading = false;
        final tracks = _getTracks();
        _selected = Set.from(List.generate(tracks.length, (i) => i));
      });
      _extractDominantColor(content);
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

  Future<void> _extractDominantColor(Map<String, dynamic>? content) async {
    final coverUrl = content?['coverUrl']?.toString() ?? '';
    if (coverUrl.isEmpty) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(coverUrl),
        maximumColorCount: 16,
      );
      if (mounted) {
        setState(() {
          _dominantColor = palette.dominantColor?.color;
        });
      }
    } catch (_) {
      // Fallback handled in build — _dominantColor stays null
    }
  }

  List<dynamic> _getTracks() {
    if (_content == null) return [];
    return _content!['tracks'] as List<dynamic>? ?? [];
  }

  void _downloadSelected() {
    final tracks = _getTracks();
    if (tracks.isEmpty || _selected.isEmpty) return;
    final selected = _selected.map((i) => tracks[i] as Map<String, dynamic>).toList();
    final core = ref.read(flacCoreProvider);
    final source = _content?['source'] as String? ?? 'tidal';
    if (source == 'qobuz') {
      core.callSync('queueQobuzDownloads', {
        'tracks': selected,
        'outputDir': core.downloadDir,
      });
    } else {
      core.queueDownloads(selected, core.downloadDir);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Queued ${selected.length} tracks')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const SkeletonLoader(layout: SkeletonLayout.detailHeader)
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
      floatingActionButton: _content != null && _selected.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.lightImpact();
                _downloadSelected();
              },
              icon: const Icon(Icons.download),
              label: Text('Download ${_selected.length}'),
            )
          : null,
    );
  }

  Widget _buildContent() {
    final title = _content?['title'] ?? 'Unknown';
    final artist = _content?['creator'] ?? _content?['artist'] ?? '';
    final coverUrl = _content?['coverUrl'] ?? '';
    final tracks = _getTracks();
    final trackCount = _content?['trackCount'] ?? tracks.length;

    return CustomScrollView(
      slivers: [
        // Cover + info header
        GradientHeader(
          title: title.toString(),
          subtitle: '${artist.toString().isNotEmpty ? '${artist.toString()} · ' : ''}$trackCount tracks',
          coverUrl: coverUrl.toString().isNotEmpty ? coverUrl.toString() : null,
          dominantColor: _dominantColor,
          heroTag: 'content-cover-${widget.type}-${widget.id}',
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Open in Tidal',
              onPressed: () => launchUrl(
                Uri.parse('https://tidal.com/${widget.type}/${widget.id}'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text: 'https://tidal.com/${widget.type}/${widget.id}',
                ),
              ),
            ),
            IconButton(
              icon: Icon(_selected.length == tracks.length
                  ? Icons.deselect
                  : Icons.select_all),
              onPressed: () {
                setState(() {
                  if (_selected.length == tracks.length) {
                    _selected = {};
                  } else {
                    _selected = Set.from(List.generate(tracks.length, (i) => i));
                  }
                });
              },
            ),
          ],
        ),
        // Track list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final track = tracks[i] as Map<String, dynamic>;
              final trackTitle = track['title'] ?? track['Title'] ?? 'Unknown';
              final trackArtist = track['artist'] ?? track['Artist'] ?? '';
              final trackNum = track['trackNumber'] ?? track['TrackNumber'] ?? (i + 1);
              final duration = ((track['duration'] ?? track['Duration'] ?? 0) as num).toInt();
              final selected = _selected.contains(i);

              return TrackListTile(
                trackNumber: (trackNum as num).toInt(),
                title: trackTitle.toString(),
                artist: trackArtist.toString(),
                duration: duration,
                selected: selected,
                onTap: () {
                  setState(() {
                    _selected = Set.from(_selected);
                    if (selected) {
                      _selected.remove(i);
                    } else {
                      _selected.add(i);
                    }
                  });
                },
              );
            },
            childCount: tracks.length,
          ),
        ),
        // Bottom padding for FAB
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }
}
