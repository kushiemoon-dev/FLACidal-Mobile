import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_provider.dart';

/// Provides the current download queue status.
final queueStatusProvider =
    NotifierProvider<QueueStatusNotifier, AsyncValue<Map<String, dynamic>>>(
        QueueStatusNotifier.new);

class QueueStatusNotifier extends Notifier<AsyncValue<Map<String, dynamic>>> {
  @override
  AsyncValue<Map<String, dynamic>> build() {
    // Listen to download events to auto-refresh
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
