import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flacidal_mobile/providers/queue_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/container.dart';
import 'support/fake_core.dart';

Map<String, dynamic> _progress(Map<String, dynamic> payload) => {
  'type': 'download-progress',
  'payload': payload,
};

void main() {
  group('queueStatusProvider', () {
    test('reads the queue status result', () async {
      final c = await containerWith(
        FakeTransport(
          responses: {
            'getQueueStatus': {'active': 1, 'queued': 2},
          },
        ),
      );
      expect(c.read(queueStatusProvider).value, {'active': 1, 'queued': 2});
    });

    test('Core failure becomes an error state', () async {
      final c = await containerWith(
        FakeTransport(
          responses: {'getQueueStatus': const FakeError('METHOD_ERROR', 'x')},
        ),
      );
      expect(c.read(queueStatusProvider), isA<AsyncError>());
    });

    test('a download event triggers a refresh', () async {
      var active = 0;
      final t = FakeTransport(
        responses: {
          'getQueueStatus': (_) => {'active': active},
        },
      );
      final c = await containerWith(t);
      c.listen(queueStatusProvider, (_, _) {});
      expect(c.read(queueStatusProvider).value, {'active': 0});

      active = 3;
      t.emitEvent(_progress({'trackId': 1}));
      await Future<void>.delayed(Duration.zero);
      expect(c.read(queueStatusProvider).value, {'active': 3});
    });
  });

  group('downloadTracksProvider', () {
    test('computes progress and keeps the raw payload', () async {
      final t = FakeTransport(responses: {'getQueueStatus': {}});
      final c = await containerWith(t);
      c.listen(downloadTracksProvider, (_, _) {});

      t.emitEvent(
        _progress({
          'trackId': 7,
          'bytesDownloaded': 50,
          'bytesTotal': 200,
          'speed': 10,
          'title': 'S',
        }),
      );
      await Future<void>.delayed(Duration.zero);

      final track = c.read(downloadTracksProvider)[7]!;
      expect(track['progress'], 0.25);
      expect(track['title'], 'S');
      expect(track['speed'], 10);
    });

    test('unknown total leaves progress unset', () async {
      final t = FakeTransport(responses: {'getQueueStatus': {}});
      final c = await containerWith(t);
      c.listen(downloadTracksProvider, (_, _) {});
      t.emitEvent(_progress({'trackId': 1, 'bytesDownloaded': 5}));
      await Future<void>.delayed(Duration.zero);
      expect(
        c.read(downloadTracksProvider)[1]!.containsKey('progress'),
        isFalse,
      );
    });

    test('merge is not mutating: earlier state objects stay intact', () async {
      final t = FakeTransport(responses: {'getQueueStatus': {}});
      final c = await containerWith(t);
      c.listen(downloadTracksProvider, (_, _) {});
      t.emitEvent(
        _progress({'trackId': 1, 'bytesDownloaded': 1, 'bytesTotal': 4}),
      );
      await Future<void>.delayed(Duration.zero);
      final before = c.read(downloadTracksProvider);

      t.emitEvent(
        _progress({'trackId': 2, 'bytesDownloaded': 2, 'bytesTotal': 4}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(before.keys, [1]);
      expect(c.read(downloadTracksProvider).keys, containsAll([1, 2]));
    });

    test(
      'events without a trackId are ignored and clear empties the map',
      () async {
        final t = FakeTransport(responses: {'getQueueStatus': {}});
        final c = await containerWith(t);
        c.listen(downloadTracksProvider, (_, _) {});
        t.emitEvent(_progress({'title': 'no id'}));
        await Future<void>.delayed(Duration.zero);
        expect(c.read(downloadTracksProvider), isEmpty);

        t.emitEvent(_progress({'trackId': 3}));
        await Future<void>.delayed(Duration.zero);
        expect(c.read(downloadTracksProvider), isNotEmpty);
        c.read(downloadTracksProvider.notifier).clear();
        expect(c.read(downloadTracksProvider), isEmpty);
      },
    );
  });
}
