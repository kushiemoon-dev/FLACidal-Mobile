import 'dart:convert';

import 'package:flacidal_mobile/core/core_transport.dart';
import 'package:flacidal_mobile/core/flac_core.dart';

/// In-memory [CoreTransport]: maps an RPC method to a canned JSON response.
class FakeTransport implements CoreTransport {
  FakeTransport({Map<String, Object?>? responses})
    : responses = {...?responses};

  /// method -> value placed under `result`, or a `Function(params)` returning
  /// it, or a [FakeError] to produce an `error` envelope.
  final Map<String, Object?> responses;
  final List<({String method, Map<String, dynamic>? params})> calls = [];
  final List<({String request, int id})> asyncCalls = [];
  String initResponse = '{"result":null}';
  String? rawCallResponse;
  void Function(String json)? _handler;
  bool shutdownCalled = false;

  @override
  String init(String dataDir) => initResponse;

  @override
  String call(String request) {
    if (rawCallResponse != null) return rawCallResponse!;
    return _respond(request);
  }

  String _respond(String request) {
    final decoded = jsonDecode(request) as Map<String, dynamic>;
    final method = decoded['method'] as String;
    final params = decoded['params'] as Map<String, dynamic>?;
    calls.add((method: method, params: params));

    final entry = responses[method];
    final value = entry is Function ? entry(params) : entry;
    if (value is FakeError) {
      return jsonEncode({
        'error': {'code': value.code, 'message': value.message},
      });
    }
    return jsonEncode({'result': value});
  }

  /// When true, async calls are answered through an `rpc_response` event
  /// built from [responses], like the real bridge does.
  bool autoAsync = false;

  @override
  void callAsync(String request, int id) {
    asyncCalls.add((request: request, id: id));
    if (!autoAsync) return;
    final payload = _respond(request);
    Future.microtask(
      () => emitEvent({
        'type': 'rpc_response',
        'requestId': id,
        'payload': payload,
      }),
    );
  }

  @override
  void setEventHandler(void Function(String json) handler) =>
      _handler = handler;

  @override
  void shutdown() => shutdownCalled = true;

  /// Simulates an event pushed by Core.
  void emit(String json) => _handler?.call(json);

  void emitEvent(Map<String, dynamic> event) => emit(jsonEncode(event));
}

class FakeError {
  const FakeError(this.code, this.message);
  final String code;
  final String message;
}

Future<FlacCore> initializedCore(FakeTransport transport) async {
  final core = FlacCore.withTransport(transport);
  await core.init('/data');
  return core;
}
