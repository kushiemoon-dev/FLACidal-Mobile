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
