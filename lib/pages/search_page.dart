import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/exceptions.dart';
import '../providers/core_provider.dart';
import '../widgets/cover_art_tile.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/track_list_tile.dart';

enum _SearchService { all, tidal, qobuz, deezer }

enum _SortMode { relevance, dateDesc, az, za }

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;
  Timer? _debounce;
  bool _loading = false;
  String? _error;
  _SearchService _service = _SearchService.all;
  bool _songsOnly = false;
  _SortMode _sortMode = _SortMode.relevance;
  List<dynamic> _tracks = [];
  List<dynamic> _albums = [];
  List<dynamic> _artists = [];
  List<Map<String, dynamic>> _deezerResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) _search();
    });
  }

  Future<void> _searchDeezer(String query) async {
    if (query.isEmpty) return;
    try {
      final core = ref.read(flacCoreProvider);
      final result = await core.callAsync('searchDeezer', {'query': query});
      final list = result['result'];
      if (list is List) {
        setState(() {
          _deezerResults = list.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    if (_service == _SearchService.deezer) {
      await _searchDeezer(query);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final core = ref.read(flacCoreProvider);
      final params = {'query': query, 'limit': 30};

      final searchTidal = _service != _SearchService.qobuz;
      final searchQobuz = _service != _SearchService.tidal;

      List<dynamic> tracks = [];
      List<dynamic> albums = [];
      List<dynamic> artists = [];

      if (searchTidal) {
        final futures = <Future<Map<String, dynamic>>>[
          core.callAsync('searchTidal', params),
          if (!_songsOnly) core.callAsync('searchTidalAlbums', params),
          if (!_songsOnly) core.callAsync('searchTidalArtists', params),
        ];
        final results = await Future.wait(futures);
        tracks = results[0]['result'] as List<dynamic>? ?? [];
        if (!_songsOnly && results.length > 2) {
          albums = results[1]['result'] as List<dynamic>? ?? [];
          artists = results[2]['result'] as List<dynamic>? ?? [];
        }
      }

      if (searchQobuz) {
        try {
          final futures = <Future<Map<String, dynamic>>>[
            core.callAsync('searchQobuz', params),
            if (!_songsOnly) core.callAsync('searchQobuzAlbums', params),
            if (!_songsOnly) core.callAsync('searchQobuzArtists', params),
          ];
          final results = await Future.wait(futures);
          final qobuzTracks = results[0]['result'] as List<dynamic>? ?? [];
          tracks = [...tracks, ...qobuzTracks];
          if (!_songsOnly && results.length > 2) {
            albums = [
              ...albums,
              ...(results[1]['result'] as List<dynamic>? ?? []),
            ];
            artists = [
              ...artists,
              ...(results[2]['result'] as List<dynamic>? ?? []),
            ];
          }
        } on FlacCoreException {
          // Qobuz isn't configured, so quietly skip it unless "all" is being searched
          if (_service == _SearchService.qobuz) rethrow;
        }
      }

      setState(() {
        _tracks = tracks;
        _albums = _songsOnly ? [] : albums;
        _artists = _songsOnly ? [] : artists;
        _loading = false;
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

  void _applySorting() {
    if (_sortMode == _SortMode.relevance) return; // Leave the order as-is
    int Function(dynamic, dynamic) comparator;
    switch (_sortMode) {
      case _SortMode.az:
        comparator = (a, b) {
          final aTitle = ((a as Map)['title'] ?? (a)['Title'] ?? '')
              .toString()
              .toLowerCase();
          final bTitle = ((b as Map)['title'] ?? (b)['Title'] ?? '')
              .toString()
              .toLowerCase();
          return aTitle.compareTo(bTitle);
        };
      case _SortMode.za:
        comparator = (a, b) {
          final aTitle = ((a as Map)['title'] ?? (a)['Title'] ?? '')
              .toString()
              .toLowerCase();
          final bTitle = ((b as Map)['title'] ?? (b)['Title'] ?? '')
              .toString()
              .toLowerCase();
          return bTitle.compareTo(aTitle);
        };
      case _SortMode.dateDesc:
        comparator = (a, b) {
          final aDate = ((a as Map)['releaseDate'] ?? (a)['ReleaseDate'] ?? '')
              .toString();
          final bDate = ((b as Map)['releaseDate'] ?? (b)['ReleaseDate'] ?? '')
              .toString();
          return bDate.compareTo(aDate);
        };
      case _SortMode.relevance:
        return;
    }
    setState(() {
      _tracks.sort(comparator);
      _albums.sort(comparator);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hintService = switch (_service) {
      _SearchService.all => '',
      _SearchService.tidal => 'Tidal',
      _SearchService.qobuz => 'Qobuz',
      _SearchService.deezer => 'Deezer',
    };
    final hintText =
        'Search${hintService.isNotEmpty ? ' $hintService' : ''}...';

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _tracks = [];
                        _albums = [];
                        _artists = [];
                      });
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _search(),
          autofocus: true,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_hasResults ? 96 : 48),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._SearchService.values.map((s) {
                        final label = switch (s) {
                          _SearchService.all => 'All',
                          _SearchService.tidal => 'Tidal',
                          _SearchService.qobuz => 'Qobuz',
                          _SearchService.deezer => 'Deezer',
                        };
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _service == s,
                            onSelected: (_) {
                              setState(() => _service = s);
                              if (_searchController.text.trim().isNotEmpty)
                                _search();
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Songs only'),
                        selected: _songsOnly,
                        onSelected: (v) {
                          setState(() => _songsOnly = v);
                          if (_searchController.text.trim().isNotEmpty)
                            _search();
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      if (_hasResults) ...[
                        const SizedBox(width: 8),
                        PopupMenuButton<_SortMode>(
                          onSelected: (v) {
                            setState(() {
                              _sortMode = v;
                              _applySorting();
                            });
                          },
                          itemBuilder: (_) => const [
                            CheckedPopupMenuItem(
                              value: _SortMode.relevance,
                              child: Text('Relevance'),
                            ),
                            CheckedPopupMenuItem(
                              value: _SortMode.dateDesc,
                              child: Text('Date'),
                            ),
                            CheckedPopupMenuItem(
                              value: _SortMode.az,
                              child: Text('A-Z'),
                            ),
                            CheckedPopupMenuItem(
                              value: _SortMode.za,
                              child: Text('Z-A'),
                            ),
                          ],
                          child: Chip(
                            avatar: const Icon(Icons.sort, size: 16),
                            label: Text(switch (_sortMode) {
                              _SortMode.relevance => 'Relevance',
                              _SortMode.dateDesc => 'Date',
                              _SortMode.az => 'A-Z',
                              _SortMode.za => 'Z-A',
                            }),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_hasResults)
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Tracks (${_tracks.length})'),
                    Tab(text: 'Albums (${_albums.length})'),
                    Tab(text: 'Artists (${_artists.length})'),
                    Tab(text: 'Deezer (${_deezerResults.length})'),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  bool get _hasResults =>
      _tracks.isNotEmpty ||
      _albums.isNotEmpty ||
      _artists.isNotEmpty ||
      _deezerResults.isNotEmpty;

  Widget _buildBody() {
    if (_loading)
      return const SkeletonLoader(layout: SkeletonLayout.searchResults);

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(_error!),
          ],
        ),
      );
    }

    if (!_hasResults) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Look up tracks, albums, or artists'),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _TrackResults(tracks: _tracks, ref: ref),
        _AlbumResults(albums: _albums),
        _ArtistResults(artists: _artists),
        _DeezerResults(results: _deezerResults, ref: ref),
      ],
    );
  }
}

class _TrackResults extends StatelessWidget {
  final List<dynamic> tracks;
  final WidgetRef ref;
  const _TrackResults({required this.tracks, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, i) {
        final t = tracks[i] as Map<String, dynamic>;
        final title = t['title'] ?? t['Title'] ?? 'Unknown';
        final artist = t['artist'] ?? t['Artist'] ?? '';
        final duration = ((t['duration'] ?? t['Duration'] ?? 0) as num).toInt();

        return TrackListTile(
          trackNumber: i + 1,
          title: title.toString(),
          artist: artist.toString(),
          duration: duration,
          onDownload: () {
            final core = ref.read(flacCoreProvider);
            if (t['source'] == 'qobuz') {
              core.callSync('queueQobuzDownloads', {
                'tracks': [t],
                'outputDir': core.downloadDir,
              });
            } else {
              core.queueDownloads([t], core.downloadDir);
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$title queued')));
          },
        );
      },
    );
  }
}

class _AlbumResults extends StatelessWidget {
  final List<dynamic> albums;
  const _AlbumResults({required this.albums});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, i) {
        final a = albums[i] as Map<String, dynamic>;
        final title = a['title'] ?? a['Title'] ?? 'Unknown';
        final artist = a['artist'] ?? a['Artist'] ?? '';
        final tracks = a['numberOfTracks'] ?? a['trackCount'] ?? 0;
        final year = a['releaseDate']?.toString().split('-').first ?? '';
        final coverUrl = a['coverUrl'] ?? a['CoverURL'] ?? '';

        final id = a['id'] ?? a['ID'];
        final heroTag = id != null ? 'content-cover-album-$id' : null;

        return ListTile(
          leading: CoverArtTile(
            imageUrl: coverUrl.toString().isNotEmpty
                ? coverUrl.toString()
                : null,
            size: 48,
            borderRadius: 4,
            heroTag: heroTag,
          ),
          title: Text(
            title.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '$artist${year.isNotEmpty ? ' · $year' : ''} · $tracks tracks',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (id != null) {
              context.push('/content/album/$id');
            }
          },
        );
      },
    );
  }
}

class _ArtistResults extends StatelessWidget {
  final List<dynamic> artists;
  const _ArtistResults({required this.artists});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, i) {
        final a = artists[i] as Map<String, dynamic>;
        final name = a['name'] ?? a['Name'] ?? 'Unknown';

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(name.toString()),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}

class _DeezerResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final WidgetRef ref;
  const _DeezerResults({required this.results, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Search Deezer to find results from anywhere'),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final t = results[i];
        final title = t['title'] ?? t['Title'] ?? 'Unknown';
        final artist = t['artist'] ?? t['Artist'] ?? '';
        final duration = ((t['duration'] ?? t['Duration'] ?? 0) as num).toInt();
        final coverUrl = t['coverUrl'] ?? t['CoverURL'] ?? '';
        final id = t['id'] ?? t['ID'];

        return ListTile(
          leading: coverUrl.toString().isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    coverUrl.toString(),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.music_note, size: 48),
                  ),
                )
              : const Icon(Icons.music_note, size: 48),
          title: Text(
            title.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${artist.toString()}${duration > 0 ? ' · ${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}' : ''}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.download),
            onPressed: id == null
                ? null
                : () {
                    final url = 'https://www.deezer.com/track/$id';
                    final core = ref.read(flacCoreProvider);
                    final content = core.callSync('fetchContent', {'url': url});
                    final tracks =
                        (content['result']?['tracks'] as List?)
                            ?.cast<Map<String, dynamic>>() ??
                        [content['result'] as Map<String, dynamic>? ?? t];
                    core.callSync('queueDownloads', {
                      'tracks': tracks,
                      'outputDir': core.downloadDir,
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$title queued')));
                  },
          ),
        );
      },
    );
  }
}
