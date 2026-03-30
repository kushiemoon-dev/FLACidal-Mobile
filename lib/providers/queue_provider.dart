import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_provider.dart';

/// Provides the current download queue status (counts).
final queueStatusProvider =
    NotifierProvider<QueueStatusNotifier, AsyncValue<Map<String, dynamic>>>(
        QueueStatusNotifier.new);

class QueueStatusNotifier extends Notifier<AsyncValue<Map<String, dynamic>>> {
  @override
  AsyncValue<Map<String, dynamic>> build() {
    ref.listen(downloadEventsProvider, (_, _) => refresh());
    return _fetch();
  }

  void refresh() {
    state = _fetch();
  }

  AsyncValue<Map<String, dynamic>> _fetch() {
    try {
      final core = ref.read(flacCoreProvider);
      final status = core.getQueueStatus();
      return AsyncValue.data(status['result'] as Map<String, dynamic>? ?? {});
    } catch (e, st) {
      return AsyncValue.error(e, st);
    }
  }
}

/// Track state accumulated from download events. Key = trackId.
typedef TrackStates = Map<int, Map<String, dynamic>>;

/// Accumulates all download events by trackId so the full list is visible.
final downloadTracksProvider =
    NotifierProvider<DownloadTracksNotifier, TrackStates>(
        DownloadTracksNotifier.new);

class DownloadTracksNotifier extends Notifier<TrackStates> {
  @override
  TrackStates build() {
    ref.listen(downloadEventsProvider, (_, next) {
      next.whenData((event) => _handleEvent(event));
    });
    return {};
  }

  void _handleEvent(Map<String, dynamic> event) {
    final payload = event['payload'] as Map<String, dynamic>? ?? {};
    final trackId = payload['trackId'];
    if (trackId == null) return;
    final id = (trackId as num).toInt();

    // Compute fractional progress from byte-level fields when available
    final bytesDownloaded = (payload['bytesDownloaded'] as num?)?.toInt() ?? 0;
    final bytesTotal = (payload['bytesTotal'] as num?)?.toInt() ?? 0;
    final speed = (payload['speed'] as num?)?.toInt() ?? 0;

    final merged = Map<String, dynamic>.from(payload);
    if (bytesTotal > 0) {
      merged['progress'] = bytesDownloaded / bytesTotal;
    }
    merged['bytesDownloaded'] = bytesDownloaded;
    merged['bytesTotal'] = bytesTotal;
    merged['speed'] = speed;

    final current = Map<int, Map<String, dynamic>>.from(state);
    current[id] = merged;
    state = current;
  }

  void clear() => state = {};
}
