import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flacidal_mobile/providers/config_provider.dart';

// Like widget_test.dart, this exercises ConfigNotifier, which calls into
// FlacCore (Go FFI) via flacCoreProvider. FlacCore.instance is a singleton
// with a private constructor (see lib/core/flac_core.dart) that can only be
// brought up by FlacCore.instance.init(dataDir) — done once in main.dart at
// app startup — so it can't be faked or overridden here without a real
// native library loaded.
//
// Confirmed unrunnable as a plain `flutter test` unit test, not just
// unverified: ConfigNotifier.save() (config_provider.dart) has no try/catch
// around core.saveConfig(), and FlacCore._ensureInitialized() throws
// FlacCoreException(NOT_INITIALIZED) whenever init() hasn't run — which it
// hasn't here. init() itself needs (a) path_provider's
// getApplicationDocumentsDirectory(), a platform-channel plugin that needs a
// running app context (main.dart:29-31), and (b) flac_ffi.dart's
// DynamicLibrary.open('libflacidal.so')/DynamicLibrary.process(), a native
// library only resolvable from inside an installed app bundle on a real
// device/emulator (Android/iOS) — not from a bare host `flutter test`
// process. Wiring both up is real integration-test infrastructure work,
// out of scope for this task. Skipped rather than faked or silently left
// red — see task-11-report.md for details.

void main() {
  test(
    'ConfigNotifier round-trips the priority-endpoints keys',
    () {
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
      expect(result['amazonPriorityEndpoints'], [
        'https://amazon.example.com',
      ]);
    },
    skip:
        'requires FlacCore native init (Go FFI shared library + '
        'path_provider platform channel) — only available inside a real '
        'app bundle on a device/emulator via integration_test, not a plain '
        '`flutter test` unit-test process. See lib/main.dart:29-31 for the '
        'only real init() call site.',
  );
}
