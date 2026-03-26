import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_provider.dart';

/// Provides the current config from Go core.
final configProvider =
    NotifierProvider<ConfigNotifier, AsyncValue<Map<String, dynamic>>>(
        ConfigNotifier.new);

class ConfigNotifier extends Notifier<AsyncValue<Map<String, dynamic>>> {
  @override
  AsyncValue<Map<String, dynamic>> build() {
    try {
      final core = ref.read(flacCoreProvider);
      final config = core.getConfig();
      return AsyncValue.data(config['result'] as Map<String, dynamic>? ?? {});
    } catch (e, st) {
      return AsyncValue.error(e, st);
    }
  }

  void save(Map<String, dynamic> config) {
    final core = ref.read(flacCoreProvider);
    core.saveConfig(config);
    state = AsyncValue.data(config);
  }
}
