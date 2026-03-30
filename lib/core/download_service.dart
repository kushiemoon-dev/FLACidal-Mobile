import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class DownloadService {
  static bool _initialized = false;

  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'flacidal_download',
        channelName: 'Downloads',
        channelDescription: 'FLACidal download progress',
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
    await FlutterForegroundTask.startService(
      notificationTitle: 'FLACidal',
      notificationText: 'Downloading $total tracks...',
    );
  }

  static Future<void> update({
    required int completed,
    required int total,
    String? currentTrack,
  }) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: currentTrack ?? 'FLACidal',
      notificationText: 'Downloaded $completed of $total tracks',
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
