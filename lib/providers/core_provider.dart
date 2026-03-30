import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flac_core.dart';

/// Provides the singleton FlacCore instance.
final flacCoreProvider = Provider<FlacCore>((ref) {
  return FlacCore.instance;
});

/// Stream of all events from the Go core.
final coreEventsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final core = ref.watch(flacCoreProvider);
  return core.events;
});

/// Stream of download progress events.
final downloadEventsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final core = ref.watch(flacCoreProvider);
  return core.downloadEvents;
});

/// Download directory — synced with FlacCore.downloadDir.
final downloadDirProvider =
    NotifierProvider<DownloadDirNotifier, String>(DownloadDirNotifier.new);

class DownloadDirNotifier extends Notifier<String> {
  @override
  String build() => ref.read(flacCoreProvider).downloadDir;

  void set(String path) {
    ref.read(flacCoreProvider).downloadDir = path;
    state = path;
  }
}
