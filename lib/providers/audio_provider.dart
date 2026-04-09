import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// State for the audio playback provider.
class AudioState {
  final bool isPlaying;
  final String? currentFile;
  final Duration position;
  final Duration duration;

  const AudioState({
    this.isPlaying = false,
    this.currentFile,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioState copyWith({
    bool? isPlaying,
    String? currentFile,
    Duration? position,
    Duration? duration,
    bool clearFile = false,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentFile: clearFile ? null : (currentFile ?? this.currentFile),
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Notifier wrapping just_audio's AudioPlayer with Riverpod.
class AudioNotifier extends Notifier<AudioState> {
  late final AudioPlayer _player;

  @override
  AudioState build() {
    _player = AudioPlayer();

    _player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final completed =
          playerState.processingState == ProcessingState.completed;
      if (completed) {
        state = state.copyWith(isPlaying: false, position: Duration.zero);
        _player.seek(Duration.zero);
        _player.pause();
      } else {
        state = state.copyWith(isPlaying: playing);
      }
    });

    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    ref.onDispose(() {
      _player.dispose();
    });

    return const AudioState();
  }

  /// Play a local file. Auto-stops if switching to a different file.
  Future<void> play(String filePath) async {
    if (state.currentFile != filePath) {
      await _player.setFilePath(filePath);
      state = state.copyWith(
        currentFile: filePath,
        position: Duration.zero,
      );
    }
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(
      isPlaying: false,
      clearFile: true,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
}

final audioProvider =
    NotifierProvider<AudioNotifier, AudioState>(AudioNotifier.new);
