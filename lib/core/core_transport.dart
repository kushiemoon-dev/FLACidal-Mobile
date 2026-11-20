import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'flac_ffi.dart';

/// String-level seam between [FlacCore] and the native Core library.
///
/// The FFI implementation owns every `Pointer<Char>`; callers only see Dart
/// strings, which lets tests substitute a fake without loading a native lib.
abstract interface class CoreTransport {
  /// Initialises Core and returns its raw JSON response.
  String init(String dataDir);

  /// Synchronous RPC: returns the raw JSON response.
  String call(String request);

  /// Asynchronous RPC: the answer arrives as an `rpc_response` event.
  void callAsync(String request, int id);

  /// Registers the handler receiving every raw JSON event emitted by Core.
  void setEventHandler(void Function(String json) handler);

  void shutdown();
}

class FfiTransport implements CoreTransport {
  FlacFFI? _ffi;
  NativeCallable<Void Function(Pointer<Char>)>? _callback;
  void Function(String json)? _handler;

  FlacFFI get _lib => _ffi ??= FlacFFI();

  @override
  String init(String dataDir) {
    final ptr = dataDir.toNativeUtf8().cast<Char>();
    final resultPtr = _lib.flacInit(ptr);
    calloc.free(ptr);
    return _takeString(resultPtr);
  }

  @override
  String call(String request) {
    final ptr = request.toNativeUtf8().cast<Char>();
    final resultPtr = _lib.flacCall(ptr);
    calloc.free(ptr);
    return _takeString(resultPtr);
  }

  @override
  void callAsync(String request, int id) {
    final ptr = request.toNativeUtf8().cast<Char>();
    _lib.flacCallAsync(ptr, id);
    calloc.free(ptr);
  }

  @override
  void setEventHandler(void Function(String json) handler) {
    _handler = handler;
    _callback ??= NativeCallable<Void Function(Pointer<Char>)>.listener(
      _onNativeEvent,
    );
    _lib.flacSetEventCallback(_callback!.nativeFunction);
  }

  @override
  void shutdown() {
    _lib.flacShutdown();
    _callback?.close();
    _callback = null;
  }

  void _onNativeEvent(Pointer<Char> jsonPtr) {
    // Native memory is freed once copied: same allocator as C.CString (malloc).
    final json = _takeString(jsonPtr);
    _handler?.call(json);
  }

  String _takeString(Pointer<Char> ptr) {
    final value = ptr.cast<Utf8>().toDartString();
    _lib.flacFree(ptr);
    return value;
  }
}
