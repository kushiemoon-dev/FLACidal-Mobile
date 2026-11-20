import 'package:flacidal_mobile/core/download_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('flutter_foreground_task/methods');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;
  late bool serviceRunning;

  setUp(() {
    calls = [];
    serviceRunning = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'isRunningService':
              return serviceRunning;
            case 'isIgnoringBatteryOptimizations':
              return true;
            default:
              return true;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('startUpdate starts the service when none is running', () async {
    expect(await DownloadService.startUpdate(text: 'x'), isTrue);
    expect(calls.map((c) => c.method), contains('startService'));
  });

  test('startUpdate leaves a running queue service alone', () async {
    serviceRunning = true;
    expect(await DownloadService.startUpdate(text: 'x'), isFalse);
    expect(calls.map((c) => c.method), isNot(contains('startService')));
  });

  test('stop and update progress reach the platform', () async {
    serviceRunning = true; // the plugin ignores update/stop otherwise
    await DownloadService.updateUpdateProgress(text: '40%');
    await DownloadService.stop();
    expect(
      calls.map((c) => c.method),
      containsAll(['updateService', 'stopService']),
    );
  });
}
