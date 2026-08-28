import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flac_core.dart';

final flacCoreProvider = Provider<FlacCore>((ref) {
  return FlacCore.instance;
});

final coreEventsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final core = ref.watch(flacCoreProvider);
  return core.events;
});

final downloadEventsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final core = ref.watch(flacCoreProvider);
  return core.downloadEvents;
});

// Mirrors FlacCore.downloadDir, which main.dart also writes to directly at
// startup, keep both in sync manually: there's no automatic binding.
final downloadDirProvider = NotifierProvider<DownloadDirNotifier, String>(
  DownloadDirNotifier.new,
);

class DownloadDirNotifier extends Notifier<String> {
  @override
  String build() => ref.read(flacCoreProvider).downloadDir;

  void set(String path) {
    ref.read(flacCoreProvider).downloadDir = path;
    state = path;
  }
}
