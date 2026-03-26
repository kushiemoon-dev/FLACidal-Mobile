import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';
import '../providers/queue_provider.dart';

/// Download queue with real-time progress.
class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueStatus = ref.watch(queueStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          // Retry all failed
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
      body: queueStatus.when(
        data: (status) => _buildQueueContent(context, ref, status),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      // Pause/Resume FAB
      floatingActionButton: queueStatus.whenOrNull(
        data: (status) {
          final paused = status['paused'] as bool? ?? false;
          final active = status['active'] as int? ?? 0;
          final queued = status['queued'] as int? ?? 0;
          if (active == 0 && queued == 0) return null;

          return FloatingActionButton(
            onPressed: () {
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

  Widget _buildQueueContent(
      BuildContext context, WidgetRef ref, Map<String, dynamic> status) {
    final active = status['active'] as int? ?? 0;
    final queued = status['queued'] as int? ?? 0;
    final failed = status['failed'] as int? ?? 0;
    final paused = status['paused'] as bool? ?? false;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(
                label: 'Active',
                value: '$active',
                color: theme.colorScheme.primary,
              ),
              _StatChip(
                label: 'Queued',
                value: '$queued',
                color: theme.colorScheme.secondary,
              ),
              _StatChip(
                label: 'Failed',
                value: '$failed',
                color: theme.colorScheme.error,
              ),
              if (paused)
                Chip(
                  label: const Text('PAUSED'),
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Download events stream
        Expanded(
          child: _DownloadEventsList(ref: ref),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

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

class _DownloadEventsList extends StatelessWidget {
  final WidgetRef ref;
  const _DownloadEventsList({required this.ref});

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(downloadEventsProvider);

    return events.when(
      data: (event) {
        final payload = event['payload'] as Map<String, dynamic>? ?? {};
        final trackId = payload['trackId'];
        final status = payload['status'] ?? 'unknown';
        final result = payload['result'] as Map<String, dynamic>?;
        final title = result?['Title'] ?? 'Track $trackId';
        final artist = result?['Artist'] ?? '';

        return ListView(
          children: [
            _DownloadTile(
              title: title.toString(),
              artist: artist.toString(),
              status: status.toString(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_done, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active downloads'),
          ],
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final String title;
  final String artist;
  final String status;

  const _DownloadTile({
    required this.title,
    required this.artist,
    required this.status,
  });

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (status) {
      'downloading' => cs.primary,
      'complete' => Colors.green,
      'failed' => cs.error,
      'cancelled' => Colors.orange,
      _ => Colors.grey,
    };
  }

  IconData _statusIcon() {
    return switch (status) {
      'downloading' => Icons.downloading,
      'complete' => Icons.check_circle,
      'failed' => Icons.error,
      'cancelled' => Icons.cancel,
      'queued' => Icons.hourglass_empty,
      _ => Icons.help,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_statusIcon(), color: _statusColor(context)),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(artist),
      trailing: Chip(
        label: Text(status),
        backgroundColor: _statusColor(context).withValues(alpha: 0.2),
      ),
    );
  }
}
