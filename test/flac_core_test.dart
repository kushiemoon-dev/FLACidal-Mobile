import 'package:flacidal_mobile/core/exceptions.dart';
import 'package:flacidal_mobile/core/flac_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_core.dart';

void main() {
  late FakeTransport transport;
  late FlacCore core;

  setUp(() async {
    transport = FakeTransport();
    core = await initializedCore(transport);
  });

  group('callResult', () {
    test('unwraps map, list, string and null results', () {
      transport.responses.addAll({
        'map': {'a': 1},
        'list': [1, 2],
        'str': 'x',
        'nul': null,
      });
      expect(core.callResult('map'), {'a': 1});
      expect(core.callResult('list'), [1, 2]);
      expect(core.callResult('str'), 'x');
      expect(core.callResult('nul'), isNull);
    });

    test('sends params in the request', () {
      transport.responses['m'] = true;
      core.callResult('m', {'k': 'v'});
      expect(transport.calls.single.params, {'k': 'v'});
    });

    test('error envelope throws FlacCoreException', () {
      transport.responses['bad'] = const FakeError('METHOD_ERROR', 'boom');
      expect(
        () => core.callResult('bad'),
        throwsA(
          isA<FlacCoreException>()
              .having((e) => e.code, 'code', 'METHOD_ERROR')
              .having((e) => e.message, 'message', 'boom'),
        ),
      );
    });

    test('non JSON response throws', () {
      transport.rawCallResponse = 'not json';
      expect(() => core.callResult('m'), throwsFormatException);
    });
  });

  group('init', () {
    test('NOT_INITIALIZED before init', () {
      final fresh = FlacCore.withTransport(FakeTransport());
      expect(
        () => fresh.callSync('m'),
        throwsA(
          isA<FlacCoreException>().having(
            (e) => e.code,
            'code',
            'NOT_INITIALIZED',
          ),
        ),
      );
    });

    test('init error is surfaced and leaves core uninitialised', () async {
      final t = FakeTransport()
        ..initResponse = '{"error":{"code":"INIT","message":"nope"}}';
      final fresh = FlacCore.withTransport(t);
      await expectLater(fresh.init('/d'), throwsA(isA<FlacCoreException>()));
      expect(fresh.isInitialized, isFalse);
    });
  });

  group('callAsync', () {
    test('completes on rpc_response with a string payload', () async {
      final future = core.callResultAsync('slow');
      final id = transport.asyncCalls.single.id;
      transport.emitEvent({
        'type': 'rpc_response',
        'requestId': id,
        'payload': '{"result":{"ok":true}}',
      });
      expect(await future, {'ok': true});
    });

    test('completes on rpc_response with a map payload', () async {
      final future = core.callAsync('slow');
      transport.emitEvent({
        'type': 'rpc_response',
        'requestId': transport.asyncCalls.single.id,
        'payload': {'result': 5},
      });
      expect((await future)['result'], 5);
    });

    test('error payload completes with FlacCoreException', () async {
      final future = core.callAsync('slow');
      transport.emitEvent({
        'type': 'rpc_response',
        'requestId': transport.asyncCalls.single.id,
        'payload': {
          'error': {'code': 'E', 'message': 'm'},
        },
      });
      await expectLater(future, throwsA(isA<FlacCoreException>()));
    });
  });

  group('events', () {
    test('non rpc events reach the stream', () async {
      final next = core.downloadEvents.first;
      transport.emitEvent({'type': 'download-progress', 'trackId': 1});
      expect((await next)['trackId'], 1);
    });

    test('malformed event is ignored', () {
      expect(() => transport.emit('garbage'), returnsNormally);
    });
  });

  test('shutdown stops the transport', () {
    core.shutdown();
    expect(transport.shutdownCalled, isTrue);
    expect(core.isInitialized, isFalse);
  });
}
