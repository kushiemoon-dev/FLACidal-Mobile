import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';
import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';

class LyricsPage extends ConsumerStatefulWidget {
  final String? filePath;

  /// Track title, used only when filePath isn't given.
  final String? title;

  /// Artist name, used only when filePath isn't given.
  final String? artist;

  /// Track duration in seconds, used only when filePath isn't given.
  final int? duration;

  const LyricsPage({
    super.key,
    this.filePath,
    this.title,
    this.artist,
    this.duration,
  });

  @override
  ConsumerState<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loading = false;
  bool _embedding = false;
  String? _error;

  String _plainLyrics = '';
  String _syncedLyrics = '';
  String _trackName = '';
  String _artistName = '';
  String _source = '';
  bool _instrumental = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLyrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLyrics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final core = ref.read(flacCoreProvider);
      final Map<String, dynamic> result;

      if (widget.filePath != null && widget.filePath!.isNotEmpty) {
        result = core.callSync('fetchLyricsForFile', {'path': widget.filePath});
      } else if (widget.title != null && widget.artist != null) {
        result = core.callSync('fetchLyrics', {
          'title': widget.title,
          'artist': widget.artist,
          if (widget.duration != null) 'duration': widget.duration,
        });
      } else {
        setState(() {
          _error = AppLocalizations.of(context).lyricsMissingInput;
          _loading = false;
        });
        return;
      }

      final data = result['result'] as Map<String, dynamic>? ?? result;
      setState(() {
        _plainLyrics = (data['plainLyrics'] ?? data['plain'] ?? '').toString();
        _syncedLyrics = (data['syncedLyrics'] ?? data['synced'] ?? '')
            .toString();
        _trackName = (data['trackName'] ?? '').toString();
        _artistName = (data['artistName'] ?? '').toString();
        _source = (data['source'] ?? '').toString();
        _instrumental = data['instrumental'] == true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = describeCoreError(AppLocalizations.of(context), e);
        _loading = false;
      });
    }
  }

  Future<void> _embedLyrics() async {
    if (widget.filePath == null || widget.filePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).lyricsNoFilePath)),
      );
      return;
    }

    if (_plainLyrics.isEmpty && _syncedLyrics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).lyricsNothingToEmbed)),
      );
      return;
    }

    setState(() => _embedding = true);

    try {
      final core = ref.read(flacCoreProvider);
      core.callSync('embedLyrics', {
        'path': widget.filePath,
        'plain': _plainLyrics,
        'synced': _syncedLyrics,
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).lyricsEmbedded)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).lyricsEmbedFailed(describeCoreError(AppLocalizations.of(context), e)))),
        );
      }
    } finally {
      if (mounted) setState(() => _embedding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayTitle = _trackName.isNotEmpty
        ? _trackName
        : (widget.title ?? AppLocalizations.of(context).lyricsTitle);
    final displayArtist = _artistName.isNotEmpty
        ? _artistName
        : (widget.artist ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayTitle,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (displayArtist.isNotEmpty)
              Text(
                displayArtist,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if (_source.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                label: Text(
                  _source.toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (_instrumental)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                avatar: const Icon(Icons.music_note, size: 14),
                label: Text(
                  AppLocalizations.of(context).lyricsInstrumental,
                  style: const TextStyle(fontSize: 10),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (widget.filePath != null && widget.filePath!.isNotEmpty)
            _embedding
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_alt),
                    tooltip: AppLocalizations.of(context).lyricsEmbedTooltip,
                    onPressed: (_plainLyrics.isEmpty && _syncedLyrics.isEmpty)
                        ? null
                        : _embedLyrics,
                  ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context).lyricsTabSynced),
            Tab(text: AppLocalizations.of(context).lyricsTabPlain),
          ],
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetchLyrics,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_plainLyrics.isEmpty && _syncedLyrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _instrumental ? Icons.music_note : Icons.lyrics,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _instrumental
                  ? AppLocalizations.of(context).lyricsLooksInstrumental
                  : AppLocalizations.of(context).lyricsNotFound,
            ),
            const SizedBox(height: 24),
            if (!_instrumental)
              FilledButton.icon(
                onPressed: _fetchLyrics,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).retry),
              ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildSyncedTab(theme), _buildPlainTab(theme)],
    );
  }

  Widget _buildSyncedTab(ThemeData theme) {
    if (_syncedLyrics.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).lyricsNoSynced,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final lines = _parseSyncedLyrics(_syncedLyrics);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  line.timestamp,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Expanded(
                child: Text(line.text, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlainTab(ThemeData theme) {
    if (_plainLyrics.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).lyricsNoPlain,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _plainLyrics,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
      ),
    );
  }

  /// Parses LRC-format synced lyrics into timestamp/text pairs.
  List<_SyncedLine> _parseSyncedLyrics(String raw) {
    final lines = <_SyncedLine>[];
    for (final line in raw.split('\n')) {
      final match = RegExp(
        r'^\[(\d{2}:\d{2}\.\d{2,3})\]\s?(.*)$',
      ).firstMatch(line);
      if (match != null) {
        lines.add(
          _SyncedLine(timestamp: match.group(1)!, text: match.group(2)!),
        );
      } else if (line.trim().isNotEmpty) {
        lines.add(_SyncedLine(timestamp: '', text: line.trim()));
      }
    }
    return lines;
  }
}

class _SyncedLine {
  final String timestamp;
  final String text;

  const _SyncedLine({required this.timestamp, required this.text});
}
