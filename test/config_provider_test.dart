import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flacidal_mobile/providers/config_provider.dart';

// Like widget_test.dart, this exercises ConfigNotifier, which calls into
// FlacCore (Go FFI) via flacCoreProvider. FlacCore.instance is a singleton
// with a private constructor (see lib/core/flac_core.dart) that can only be
// brought up by FlacCore.instance.init(dataDir) — done once in main.dart at
// app startup — so it can't be faked or overridden here without a real
// native library loaded. Run on a real device/emulator:
//   flutter test --device-id=<device>

void main() {
  test('ConfigNotifier round-trips the priority-endpoints keys', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final current = container.read(configProvider).value ?? {};
    final updated = Map<String, dynamic>.from(current)
      ..['tidalPriorityEndpoints'] = ['https://tidal.example.com']
      ..['qobuzPriorityEndpoints'] = ['https://qobuz.example.com']
      ..['amazonPriorityEndpoints'] = ['https://amazon.example.com'];

    container.read(configProvider.notifier).save(updated);

    final result = container.read(configProvider).value ?? {};
    expect(result['tidalPriorityEndpoints'], ['https://tidal.example.com']);
    expect(result['qobuzPriorityEndpoints'], ['https://qobuz.example.com']);
    expect(result['amazonPriorityEndpoints'], ['https://amazon.example.com']);
  });
}
