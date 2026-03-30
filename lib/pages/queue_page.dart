import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';
import '../providers/queue_provider.dart';
import '../widgets/circular_download_indicator.dart';

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueStatus = ref.watch(queueStatusProvider);
    final tracks = ref.watch(downloadTracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Retry failed',
            onPressed: () {
              final core = ref.read(flacCoreProvider);
              core.callSync('retryAllFailed');
              ref.read(queueStatusProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          queueStatus.when(
            data: (status) => _StatsBar(status: status),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(height: 1),
          // Track list
          Expanded(child: _TrackList(tracks: tracks)),
        ],
      ),
      floatingActionButton: queueStatus.whenOrNull(
        data: (status) {
          final paused = status['paused'] as bool? ?? false;
          final active = (status['active'] as num?)?.toInt() ?? 0;
          final queued = (status['queued'] as num?)?.toInt() ?? 0;
          if (active == 0 && queued == 0) return null;
          return FloatingActionButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              final core = ref.read(flacCoreProvider);
              if (paused) {
                core.resumeDownloads();
              } else {
                core.pauseDownloads();
              }
              ref.read(queueStatusProvider.notifier).refresh();
            },
            child: Icon(paused ? Icons.play_arrow : Icons.pause),
          );
        },
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final Map<String, dynamic> status;
  const _StatsBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final active = (status['active'] as num?)?.toInt() ?? 0;
    final queued = (status['queued'] as num?)?.toInt() ?? 0;
    final failed = (status['failed'] as num?)?.toInt() ?? 0;
    final paused = status['paused'] as bool? ?? false;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Active', value: '$active', color: cs.primary),
          _Stat(label: 'Queued', value: '$queued', color: cs.secondary),
          _Stat(label: 'Failed', value: '$failed', color: cs.error),
          if (paused)
            Chip(
              label: const Text('PAUSED'),
              backgroundColor: cs.tertiaryContainer,
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: color, fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TrackList extends StatelessWidget {
  final TrackStates tracks;
  const _TrackList({required this.tracks});

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_done, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active downloads'),
          ],
        ),
      );
    }

    final entries = tracks.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final payload = entries[i].value;
        final result = payload['result'] as Map<String, dynamic>?;
        final status = payload['status'] as String? ?? 'queued';
        final progress = (payload['progress'] as num?)?.toDouble() ?? 0.0;
        final title = result?['title'] as String? ??
            result?['Title'] as String? ??
            'Track ${entries[i].key}';
        final artist = result?['artist'] as String? ??
            result?['Artist'] as String? ??
            '';
        final errorMsg = result?['error'] as String? ?? '';
        final bytesDownloaded =
            (payload['bytesDownloaded'] as num?)?.toInt() ?? 0;
        final bytesTotal = (payload['bytesTotal'] as num?)?.toInt() ?? 0;
        final speed = (payload['speed'] as num?)?.toInt() ?? 0;

        return _TrackTile(
          title: title,
          artist: artist,
          status: status,
          progress: progress,
          errorMsg: errorMsg,
          bytesDownloaded: bytesDownloaded,
          bytesTotal: bytesTotal,
          speed: speed,
        );
      },
    );
  }
}

class _TrackTile extends StatelessWidget {
  final String title;
  final String artist;
  final String status;
  final double progress;
  final String errorMsg;
  final int bytesDownloaded;
  final int bytesTotal;
  final int speed;
  const _TrackTile({
    required this.title,
    required this.artist,
    required this.status,
    this.progress = 0.0,
    this.errorMsg = '',
    this.bytesDownloaded = 0,
    this.bytesTotal = 0,
    this.speed = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget? subtitle;
    if (errorMsg.isNotEmpty) {
      subtitle = Text(errorMsg,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Theme.of(context).colorScheme.error, fontSize: 11));
    } else if (status == 'downloading' && speed > 0 && bytesTotal > 0) {
      final remaining = bytesTotal - bytesDownloaded;
      subtitle = Text(
        '${_formatSpeed(speed)} — ${_formatBytes(remaining)} left',
        style: Theme.of(context).textTheme.bodySmall,
      );
    } else if (artist.isNotEmpty) {
      subtitle = Text(artist);
    }

    return ListTile(
      leading: CircularDownloadIndicator(
        progress: progress,
        status: status,
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle,
    );
  }

  static String _formatSpeed(int bytesPerSec) {
    if (bytesPerSec >= 1024 * 1024) {
      return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    if (bytesPerSec >= 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(0)} KB/s';
    }
    return '$bytesPerSec B/s';
  }

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }
}
