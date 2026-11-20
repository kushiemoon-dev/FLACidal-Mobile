import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flacidal_mobile/providers/config_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/container.dart';
import 'support/fake_core.dart';

void main() {
  test('build reads the config result', () async {
    final container = await containerWith(
      FakeTransport(
        responses: {
          'getConfig': {'language': 'fr'},
        },
      ),
    );
    expect(container.read(configProvider).value, {'language': 'fr'});
  });

  test('build falls back to an empty map when result is null', () async {
    final container = await containerWith(
      FakeTransport(responses: {'getConfig': null}),
    );
    expect(container.read(configProvider).value, isEmpty);
  });

  test('build exposes the error when Core fails', () async {
    final container = await containerWith(
      FakeTransport(responses: {'getConfig': const FakeError('X', 'down')}),
    );
    expect(container.read(configProvider), isA<AsyncError>());
  });

  test('save sends the complete map and updates state', () async {
    final transport = FakeTransport(
      responses: {
        'getConfig': {'a': 1},
        'saveConfig': null,
      },
    );
    final container = await containerWith(transport);
    final updated = {
      'a': 1,
      'tidalPriorityEndpoints': ['https://tidal.example.com'],
    };

    container.read(configProvider.notifier).save(updated);

    final call = transport.calls.lastWhere((c) => c.method == 'saveConfig');
    expect(call.params, updated);
    expect(container.read(configProvider).value, updated);
  });
}
