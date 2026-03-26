import 'dart:ffi';
import 'dart:io';

// Native function type signatures (use Char to match Go's *C.char)
typedef _FlacInitNative = Pointer<Char> Function(Pointer<Char>);
typedef _FlacInitDart = Pointer<Char> Function(Pointer<Char>);

typedef _FlacCallNative = Pointer<Char> Function(Pointer<Char>);
typedef _FlacCallDart = Pointer<Char> Function(Pointer<Char>);

typedef _FlacCallAsyncNative = Void Function(Pointer<Char>, Int32);
typedef _FlacCallAsyncDart = void Function(Pointer<Char>, int);

typedef _EventCallbackNative = Void Function(Pointer<Char>);
typedef _FlacSetEventCallbackNative = Void Function(
    Pointer<NativeFunction<_EventCallbackNative>>);
typedef _FlacSetEventCallbackDart = void Function(
    Pointer<NativeFunction<_EventCallbackNative>>);

typedef _FlacFreeNative = Void Function(Pointer<Char>);
typedef _FlacFreeDart = void Function(Pointer<Char>);

typedef _FlacShutdownNative = Void Function();
typedef _FlacShutdownDart = void Function();

/// Raw FFI bindings to the Go shared library (libflacidal.so / libflacidal.dylib).
class FlacFFI {
  late final DynamicLibrary _lib;

  late final _FlacInitDart flacInit;
  late final _FlacCallDart flacCall;
  late final _FlacCallAsyncDart flacCallAsync;
  late final _FlacSetEventCallbackDart flacSetEventCallback;
  late final _FlacFreeDart flacFree;
  late final _FlacShutdownDart flacShutdown;

  FlacFFI() {
    _lib = _loadLibrary();

    flacInit = _lib.lookupFunction<_FlacInitNative, _FlacInitDart>('FlacInit');
    flacCall = _lib.lookupFunction<_FlacCallNative, _FlacCallDart>('FlacCall');
    flacCallAsync = _lib
        .lookupFunction<_FlacCallAsyncNative, _FlacCallAsyncDart>('FlacCallAsync');
    flacSetEventCallback = _lib.lookupFunction<_FlacSetEventCallbackNative,
        _FlacSetEventCallbackDart>('FlacSetEventCallback');
    flacFree = _lib.lookupFunction<_FlacFreeNative, _FlacFreeDart>('FlacFree');
    flacShutdown = _lib
        .lookupFunction<_FlacShutdownNative, _FlacShutdownDart>('FlacShutdown');
  }

  static DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libflacidal.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process(); // statically linked
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libflacidal.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libflacidal.dylib');
    }
    throw UnsupportedError('Platform not supported');
  }
}
