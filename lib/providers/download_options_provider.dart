import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_provider.dart';

/// Download options synced with Go backend.
final downloadOptionsProvider =
    NotifierProvider<DownloadOptionsNotifier, Map<String, dynamic>>(
        DownloadOptionsNotifier.new);

class DownloadOptionsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('getDownloadOptions');
      return result['result'] as Map<String, dynamic>? ?? _defaults;
    } catch (_) {
      return _defaults;
    }
  }

  static const _defaults = {
    'Quality': 'HI_RES',
    'OrganizeFolders': false,
    'EmbedCover': true,
  };

  void update(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(state);
    updated[key] = value;
    state = updated;
    // Push to Go backend
    try {
      ref.read(flacCoreProvider).callSync('setDownloadOptions', updated);
    } catch (_) {}
  }
}
