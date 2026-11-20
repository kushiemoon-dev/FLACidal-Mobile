import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'core_transport.dart';
import 'exceptions.dart';

class FlacCore {
  static FlacCore? _instance;
  static FlacCore get instance => _instance ??= FlacCore._(FfiTransport());

  final CoreTransport _transport;
  bool _initialized = false;
  String _dataDir = '';
  String downloadDir = '';

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  final _pendingRPCs = <int, Completer<Map<String, dynamic>>>{};
  int _nextRequestId = 0;

  FlacCore._(this._transport);

  @visibleForTesting
  FlacCore.withTransport(CoreTransport transport) : _transport = transport;

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  Stream<Map<String, dynamic>> get downloadEvents =>
      _eventController.stream.where((e) => e['type'] == 'download-progress');

  bool get isInitialized => _initialized;
  String get dataDir => _dataDir;

  Future<void> init(String dataDir) async {
    if (_initialized) return;

    _transport.setEventHandler(_onEvent);

    final json = jsonDecode(_transport.init(dataDir)) as Map<String, dynamic>;
    _throwIfError(json);

    _dataDir = dataDir;
    _initialized = true;
  }

  Map<String, dynamic> callSync(String method, [Map<String, dynamic>? params]) {
    _ensureInitialized();
    return _parseResponse(_transport.call(_encode(method, params)));
  }

  /// Like [callSync] but returns the unwrapped `result` payload.
  dynamic callResult(String method, [Map<String, dynamic>? params]) =>
      callSync(method, params)['result'];

  /// Makes an async RPC call; it runs in a Go goroutine and the result arrives via callback.
  Future<Map<String, dynamic>> callAsync(
    String method, [
    Map<String, dynamic>? params,
  ]) {
    _ensureInitialized();

    final requestId = _nextRequestId++;
    final completer = Completer<Map<String, dynamic>>();
    _pendingRPCs[requestId] = completer;

    _transport.callAsync(_encode(method, params), requestId);

    return completer.future;
  }

  /// Like [callAsync] but returns the unwrapped `result` payload.
  Future<dynamic> callResultAsync(
    String method, [
    Map<String, dynamic>? params,
  ]) async => (await callAsync(method, params))['result'];

  void shutdown() {
    if (!_initialized) return;
    _transport.shutdown();
    _eventController.close();
    _initialized = false;
    if (identical(_instance, this)) _instance = null;
  }

  String _encode(String method, Map<String, dynamic>? params) =>
      jsonEncode({'method': method, 'params': ?params});

  Map<String, dynamic> getConfig() => callSync('getConfig');

  void saveConfig(Map<String, dynamic> config) =>
      callSync('saveConfig', config);

  Map<String, dynamic> fetchContent(String url) =>
      callSync('fetchContent', {'url': url});

  Map<String, dynamic> searchTidal(String query, {int limit = 20}) =>
      callSync('searchTidal', {'query': query, 'limit': limit});

  Map<String, dynamic> queueDownloads(
    List<Map<String, dynamic>> tracks,
    String outputDir,
  ) => callSync('queueDownloads', {'tracks': tracks, 'outputDir': outputDir});

  Map<String, dynamic> queueSingleWithQuality({
    required int trackId,
    required String outputDir,
    required String title,
    required String artist,
    String isrc = '',
    required String quality,
  }) => callSync('queueSingleWithQuality', {
    'trackId': trackId,
    'outputDir': outputDir,
    'title': title,
    'artist': artist,
    'isrc': isrc,
    'quality': quality,
  });

  Map<String, dynamic> getQueueStatus() => callSync('getQueueStatus');

  void pauseDownloads() => callSync('pauseDownloads');
  void resumeDownloads() => callSync('resumeDownloads');

  void cancelDownload(int trackId) =>
      callSync('cancelDownload', {'trackId': trackId});

  void _ensureInitialized() {
    if (!_initialized) {
      throw const FlacCoreException(
        code: 'NOT_INITIALIZED',
        message: 'init() must be called first',
      );
    }
  }

  void _onEvent(String jsonStr) {
    try {
      final event = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (event['type'] == 'rpc_response') {
        final requestId = event['requestId'] as int;
        final payload = event['payload'];
        final completer = _pendingRPCs.remove(requestId);
        if (completer != null) {
          try {
            final parsed = (payload is String)
                ? jsonDecode(payload) as Map<String, dynamic>
                : payload as Map<String, dynamic>;
            _throwIfError(parsed);
            completer.complete(parsed);
          } catch (e) {
            completer.completeError(e);
          }
        }
      } else {
        _eventController.add(event);
      }
    } catch (_) {}
  }

  Map<String, dynamic> _parseResponse(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _throwIfError(json);
    return json;
  }

  void _throwIfError(Map<String, dynamic> json) {
    if (json.containsKey('error') && json['error'] != null) {
      final err = json['error'] as Map<String, dynamic>;
      throw FlacCoreException(
        code: err['code'] as String,
        message: err['message'] as String,
      );
    }
  }
}
