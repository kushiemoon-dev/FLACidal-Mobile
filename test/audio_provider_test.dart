import 'package:flacidal_mobile/providers/audio_provider.dart';
import 'package:flutter_test/flutter_test.dart';

// AudioNotifier wraps just_audio's AudioPlayer, which talks to platform
// channels that a host `flutter test` run does not provide. Only the pure
// state object is covered here; the notifier needs a device (documented as
// an accepted gap in the 1.0 plan).
void main() {
  test('defaults to idle', () {
    const s = AudioState();
    expect(s.isPlaying, isFalse);
    expect(s.currentFile, isNull);
    expect(s.position, Duration.zero);
    expect(s.duration, Duration.zero);
  });

  test('copyWith changes only the given fields', () {
    const s = AudioState(currentFile: 'a.flac', duration: Duration(seconds: 9));
    final next = s.copyWith(
      isPlaying: true,
      position: const Duration(seconds: 2),
    );
    expect(next.isPlaying, isTrue);
    expect(next.position, const Duration(seconds: 2));
    expect(next.currentFile, 'a.flac');
    expect(next.duration, const Duration(seconds: 9));
    expect(s.isPlaying, isFalse); // original untouched
  });

  test('clearFile drops the current file even when one is passed', () {
    const s = AudioState(currentFile: 'a.flac');
    expect(s.copyWith(clearFile: true).currentFile, isNull);
    expect(
      s.copyWith(currentFile: 'b.flac', clearFile: true).currentFile,
      isNull,
    );
    expect(s.copyWith(currentFile: 'b.flac').currentFile, 'b.flac');
  });
}
