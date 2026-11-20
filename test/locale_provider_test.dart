import 'dart:ui';

import 'package:flacidal_mobile/providers/locale_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/container.dart';
import 'support/fake_core.dart';

void main() {
  Future<(FakeTransport, dynamic)> setup(Object? language) async {
    final t = FakeTransport(
      responses: {
        'getConfig': {'a': 1, 'language': ?language},
        'saveConfig': null,
      },
    );
    return (t, await containerWith(t));
  }

  test('null when language is absent or empty', () async {
    expect((await setup(null)).$2.read(localeProvider), isNull);
    expect((await setup('')).$2.read(localeProvider), isNull);
  });

  test('unknown code falls back to device locale', () async {
    expect((await setup('xx')).$2.read(localeProvider), isNull);
  });

  test('reads a supported code', () async {
    expect((await setup('de')).$2.read(localeProvider), const Locale('de'));
  });

  test('set saves the full config with the new language', () async {
    final (t, container) = await setup('fr');
    container.read(localeProvider.notifier).set('de');
    final sent = t.calls.lastWhere((c) => c.method == 'saveConfig').params;
    expect(sent, {'a': 1, 'language': 'de'});
    expect(container.read(localeProvider), const Locale('de'));
  });

  test('set empty string selects Auto', () async {
    final (t, container) = await setup('fr');
    container.read(localeProvider.notifier).set('');
    expect(container.read(localeProvider), isNull);
    expect(
      t.calls.lastWhere((c) => c.method == 'saveConfig').params!['language'],
      '',
    );
  });
}
