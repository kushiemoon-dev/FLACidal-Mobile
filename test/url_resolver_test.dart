import 'dart:async';
import 'dart:convert';

import 'package:flacidal_mobile/core/url_resolver.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _body({String? tidal, String? qobuz}) => {
  'entityUniqueId': 'E1',
  'entitiesByUniqueId': {
    'E1': {'title': 'Song', 'artistName': 'Band'},
  },
  'linksByPlatform': {
    if (tidal != null) 'tidal': {'url': tidal},
    if (qobuz != null) 'qobuz': {'url': qobuz},
  },
};

MockClient _client(int status, Object body) =>
    MockClient((_) async => http.Response(jsonEncode(body), status));

void main() {
  test('Tidal and Qobuz URLs need no resolution', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('{}', 200);
    });
    expect(
      await URLResolver.resolve('https://tidal.com/track/1', client: client),
      isNull,
    );
    expect(
      await URLResolver.resolve('https://www.QOBUZ.com/x', client: client),
      isNull,
    );
    expect(called, isFalse);
  });

  test('resolves a streaming link and prefers Tidal', () async {
    final r = await URLResolver.resolve(
      'https://open.spotify.com/track/9',
      client: _client(
        200,
        _body(tidal: 'https://tidal.com/track/1', qobuz: 'https://qobuz.com/2'),
      ),
    );
    expect(r, isNotNull);
    expect(r!.bestUrl, 'https://tidal.com/track/1');
    expect(r.title, 'Song');
    expect(r.artist, 'Band');
    expect(r.originalUrl, 'https://open.spotify.com/track/9');
  });

  test('falls back to Qobuz when Tidal is absent', () async {
    final r = await URLResolver.resolve(
      'https://x.test/a',
      client: _client(200, _body(qobuz: 'https://qobuz.com/2')),
    );
    expect(r!.bestUrl, 'https://qobuz.com/2');
  });

  test('200 without usable links gives null', () async {
    expect(
      await URLResolver.resolve(
        'https://x.test/a',
        client: _client(200, _body()),
      ),
      isNull,
    );
  });

  test('404 gives null', () async {
    expect(
      await URLResolver.resolve('https://x.test/a', client: _client(404, {})),
      isNull,
    );
  });

  test('invalid JSON gives null', () async {
    final client = MockClient((_) async => http.Response('<html>', 200));
    expect(
      await URLResolver.resolve('https://x.test/a', client: client),
      isNull,
    );
  });

  test('network failure gives null', () async {
    final client = MockClient((_) async => throw const FormatException('down'));
    expect(
      await URLResolver.resolve('https://x.test/a', client: client),
      isNull,
    );
  });

  test('timeout gives null', () async {
    final client = MockClient((_) => Completer<http.Response>().future);
    final result = await URLResolver.resolve(
      'https://x.test/a',
      client: client,
    ).timeout(const Duration(seconds: 15));
    expect(result, isNull);
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('ResolvedURL.bestUrl falls back to the original URL', () {
    const r = ResolvedURL(title: '', artist: '', originalUrl: 'o');
    expect(r.bestUrl, 'o');
  });
}
