import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'exceptions.dart';
import 'flac_ffi.dart';

class FlacCore {
  static FlacCore? _instance;
  static FlacCore get instance => _instance ??= FlacCore._();

  late final FlacFFI _ffi;
  bool _initialized = false;
  String _dataDir = '';
  String _downloadDir = '';

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  final _pendingRPCs = <int, Completer<Map<String, dynamic>>>{};
  int _nextRequestId = 0;

  late final NativeCallable<Void Function(Pointer<Char>)> _nativeCallback;

  FlacCore._();

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  Stream<Map<String, dynamic>> get downloadEvents =>
      _eventController.stream.where((e) => e['type'] == 'download-progress');

  bool get isInitialized => _initialized;
  String get dataDir => _dataDir;
  String get downloadDir => _downloadDir;
  set downloadDir(String dir) => _downloadDir = dir;

  Future<void> init(String dataDir) async {
    if (_initialized) return;

    _ffi = FlacFFI();

    // Wire up the event callback
    _nativeCallback = NativeCallable<Void Function(Pointer<Char>)>.listener(
      _onEvent,
    );
    _ffi.flacSetEventCallback(_nativeCallback.nativeFunction);

    // Bring up the core
    final dataDirPtr = dataDir.toNativeUtf8().cast<Char>();
    final resultPtr = _ffi.flacInit(dataDirPtr);
    calloc.free(dataDirPtr);

    final result = resultPtr.cast<Utf8>().toDartString();
    _ffi.flacFree(resultPtr);

    final json = jsonDecode(result) as Map<String, dynamic>;
    if (json.containsKey('error') && json['error'] != null) {
      final err = json['error'] as Map<String, dynamic>;
      throw FlacCoreException(
        code: err['code'] as String,
        message: err['message'] as String,
      );
    }

    _dataDir = dataDir;
    _initialized = true;
  }

  Map<String, dynamic> callSync(String method, [Map<String, dynamic>? params]) {
    _ensureInitialized();

    final request = jsonEncode({
      'method': method,
      if (params != null) 'params': params,
    });

    final requestPtr = request.toNativeUtf8().cast<Char>();
    final resultPtr = _ffi.flacCall(requestPtr);
    calloc.free(requestPtr);

    final result = resultPtr.cast<Utf8>().toDartString();
    _ffi.flacFree(resultPtr);

    return _parseResponse(result);
  }

  /// Makes an async RPC call; it runs in a Go goroutine and the result arrives via callback.
  Future<Map<String, dynamic>> callAsync(
    String method, [
    Map<String, dynamic>? params,
  ]) {
    _ensureInitialized();

    final requestId = _nextRequestId++;
    final completer = Completer<Map<String, dynamic>>();
    _pendingRPCs[requestId] = completer;

    final request = jsonEncode({
      'method': method,
      if (params != null) 'params': params,
    });

    final requestPtr = request.toNativeUtf8().cast<Char>();
    _ffi.flacCallAsync(requestPtr, requestId);
    calloc.free(requestPtr);

    return completer.future;
  }

  void shutdown() {
    if (!_initialized) return;
    _ffi.flacShutdown();
    _nativeCallback.close();
    _eventController.close();
    _initialized = false;
    _instance = null;
  }

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

  static void _onEvent(Pointer<Char> jsonPtr) {
    final jsonStr = jsonPtr.cast<Utf8>().toDartString();
    // Native memory is freed once copied: it uses the same allocator as C.CString (malloc).
    FlacCore.instance._ffi.flacFree(jsonPtr);

    try {
      final event = jsonDecode(jsonStr) as Map<String, dynamic>;
      final core = FlacCore.instance;

      if (event['type'] == 'rpc_response') {
        final requestId = event['requestId'] as int;
        final payload = event['payload'];
        final completer = core._pendingRPCs.remove(requestId);
        if (completer != null) {
          try {
            final parsed = (payload is String)
                ? jsonDecode(payload) as Map<String, dynamic>
                : payload as Map<String, dynamic>;
            if (parsed.containsKey('error') && parsed['error'] != null) {
              final err = parsed['error'] as Map<String, dynamic>;
              completer.completeError(
                FlacCoreException(
                  code: err['code'] as String,
                  message: err['message'] as String,
                ),
              );
            } else {
              completer.complete(parsed);
            }
          } catch (e) {
            completer.completeError(e);
          }
        }
      } else {
        core._eventController.add(event);
      }
    } catch (_) {}
  }

  Map<String, dynamic> _parseResponse(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (json.containsKey('error') && json['error'] != null) {
      final err = json['error'] as Map<String, dynamic>;
      throw FlacCoreException(
        code: err['code'] as String,
        message: err['message'] as String,
      );
    }
    return json;
  }
}
