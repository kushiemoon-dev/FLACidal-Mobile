import 'dart:ffi';
import 'dart:io';

// Function signatures for native bindings (Char is used to match Go's *C.char)
typedef FlacInitNative = Pointer<Char> Function(Pointer<Char>);
typedef FlacInitDart = Pointer<Char> Function(Pointer<Char>);

typedef FlacCallNative = Pointer<Char> Function(Pointer<Char>);
typedef FlacCallDart = Pointer<Char> Function(Pointer<Char>);

typedef FlacCallAsyncNative = Void Function(Pointer<Char>, Int32);
typedef FlacCallAsyncDart = void Function(Pointer<Char>, int);

typedef EventCallbackNative = Void Function(Pointer<Char>);
typedef FlacSetEventCallbackNative =
    Void Function(Pointer<NativeFunction<EventCallbackNative>>);
typedef FlacSetEventCallbackDart =
    void Function(Pointer<NativeFunction<EventCallbackNative>>);

typedef FlacFreeNative = Void Function(Pointer<Char>);
typedef FlacFreeDart = void Function(Pointer<Char>);

typedef FlacShutdownNative = Void Function();
typedef FlacShutdownDart = void Function();

class FlacFFI {
  late final DynamicLibrary _lib;

  late final FlacInitDart flacInit;
  late final FlacCallDart flacCall;
  late final FlacCallAsyncDart flacCallAsync;
  late final FlacSetEventCallbackDart flacSetEventCallback;
  late final FlacFreeDart flacFree;
  late final FlacShutdownDart flacShutdown;

  FlacFFI() {
    _lib = _loadLibrary();

    flacInit = _lib.lookupFunction<FlacInitNative, FlacInitDart>('FlacInit');
    flacCall = _lib.lookupFunction<FlacCallNative, FlacCallDart>('FlacCall');
    flacCallAsync = _lib
        .lookupFunction<FlacCallAsyncNative, FlacCallAsyncDart>(
          'FlacCallAsync',
        );
    flacSetEventCallback = _lib
        .lookupFunction<FlacSetEventCallbackNative, FlacSetEventCallbackDart>(
          'FlacSetEventCallback',
        );
    flacFree = _lib.lookupFunction<FlacFreeNative, FlacFreeDart>('FlacFree');
    flacShutdown = _lib.lookupFunction<FlacShutdownNative, FlacShutdownDart>(
      'FlacShutdown',
    );
  }

  static DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libflacidal.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process(); // linked statically
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libflacidal.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libflacidal.dylib');
    }
    throw UnsupportedError('Unsupported platform');
  }
}
