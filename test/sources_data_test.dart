import 'package:flacidal_mobile/pages/sources/sources_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_core.dart';

final _available = [
  {
    'name': 'tidal',
    'displayName': 'Tidal',
    'available': true,
    'urlPattern': '',
  },
  {
    'name': 'qobuz',
    'displayName': 'Qobuz',
    'available': false,
    'urlPattern': '',
  },
  {
    'name': 'ext-x',
    'displayName': 'Cool Ext',
    'available': true,
    'urlPattern': '',
  },
];

void main() {
  test('parses the real Core shapes', () {
    final d = parseSources(
      available: _available,
      preferred: 'tidal',
      order: ['ext-x', 'tidal'],
      config: {'autoQualityFallback': true, 'qobuzAppId': '1'},
    );
    expect(d.sources.map((s) => s.available), [true, false, true]);
    expect(d.order, ['ext-x', 'tidal']);
    expect(d.preferred, 'tidal');
    expect(d.qualityFallback, isTrue);
    expect(d.config['qobuzAppId'], '1');
  });

  test('null or empty preferred source means none', () {
    for (final p in [null, '']) {
      final d = parseSources(
        available: _available,
        preferred: p,
        order: [],
        config: {},
      );
      expect(d.preferred, isNull);
    }
  });

  test('qualityFallback defaults to false when absent', () {
    final d = parseSources(
      available: [],
      preferred: null,
      order: [],
      config: {},
    );
    expect(d.qualityFallback, isFalse);
  });

  test('does not invent an order when Core sends none', () {
    expect(
      () =>
          parseSources(available: [], preferred: null, order: null, config: {}),
      throwsFormatException,
    );
  });

  test('rejects an unexpected sources payload', () {
    expect(
      () => parseSources(
        available: {'sources': []},
        preferred: null,
        order: [],
        config: {},
      ),
      throwsFormatException,
    );
  });

  group('labels', () {
    final d = parseSources(
      available: _available,
      preferred: null,
      order: [],
      config: {},
      extensions: [
        {
          'manifest': {'id': 'ext-y', 'name': 'Other Ext'},
        },
      ],
    );

    test('uses displayName', () => expect(d.labelFor('ext-x'), 'Cool Ext'));
    test('falls back to manifest name', () {
      expect(d.labelFor('ext-y'), 'Other Ext');
    });
    test('falls back to the raw id', () => expect(d.labelFor('zzz'), 'zzz'));
  });

  test(
    'loadSources reads through callResult and tolerates getExtensions failing',
    () async {
      final t = FakeTransport(
        responses: {
          'getAvailableSources': _available,
          'getPreferredSource': 'qobuz',
          'getSourceOrder': ['qobuz'],
          'getConfig': {'autoQualityFallback': false},
          'getExtensions': const FakeError('METHOD_ERROR', 'x'),
        },
      );
      final d = loadSources(await initializedCore(t));
      expect(d.preferred, 'qobuz');
      expect(d.labelFor('qobuz'), 'Qobuz');
    },
  );
}
