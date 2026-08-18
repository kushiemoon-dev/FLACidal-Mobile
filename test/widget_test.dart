import 'package:flutter_test/flutter_test.dart';

// A real device or emulator is required for full integration tests, since
// platform plugins are involved (permission_handler, path_provider, receive_sharing_intent).
// Run with: flutter test --device-id=<device>

void main() {
  test('baseline check — unit tests run', () {
    expect(1 + 1, 2);
  });
}
