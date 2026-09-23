import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class DownloadService {
  static bool _initialized = false;

  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'flacidal_download',
        channelName: 'Downloads',
        channelDescription: 'Progress updates for FLACidal downloads',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
      ),
    );
    _initialized = true;
  }

  static Future<void> start({required int total}) async {
    if (!_initialized) await init();

    // A long-lived TCP connection is needed by Soulseek for the entire session,
    // so we request exemption from Doze/battery-optimization killing it. This is a
    // cheap no-op when already granted; it depends on REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
    // being declared in AndroidManifest.xml.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    await FlutterForegroundTask.startService(
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: 'FLACidal',
      notificationText: 'Grabbing $total tracks...',
    );
  }

  static Future<void> update({
    required int completed,
    required int total,
    String? currentTrack,
  }) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: currentTrack ?? 'FLACidal',
      notificationText: '$completed of $total tracks downloaded',
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }

  /// Starts the foreground service for an update download, unless the
  /// track queue already owns it. Returns true if this call started the
  /// service (the caller must stop it when the update finishes), false if
  /// it was already running and must be left alone: stopping it here would
  /// kill the queue's own foreground protection out from under it.
  static Future<bool> startUpdate() async {
    if (!_initialized) await init();

    if (await FlutterForegroundTask.isRunningService) return false;

    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    await FlutterForegroundTask.startService(
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: 'FLACidal',
      notificationText: 'Downloading update...',
    );
    return true;
  }

  static Future<void> updateUpdateProgress(int percent) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: 'FLACidal',
      notificationText: 'Downloading update: $percent%',
    );
  }
}
