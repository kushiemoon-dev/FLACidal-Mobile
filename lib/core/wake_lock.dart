import 'package:wakelock_plus/wakelock_plus.dart';

class WakeLockManager {
  static bool _active = false;

  static Future<void> acquire() async {
    if (!_active) {
      await WakelockPlus.enable();
      _active = true;
    }
  }

  static Future<void> release() async {
    if (_active) {
      await WakelockPlus.disable();
      _active = false;
    }
  }
}
