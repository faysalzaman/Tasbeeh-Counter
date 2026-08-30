import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _countPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Set release mode to stop after playing
      await _countPlayer.setReleaseMode(ReleaseMode.stop);
      await _completionPlayer.setReleaseMode(ReleaseMode.stop);

      // Set low latency for counting sound
      await _countPlayer.setPlayerMode(PlayerMode.lowLatency);
      _initialized = true;
    } catch (e) {
      // Audio initialization failed - app should still work
      _initialized = false;
    }
  }

  Future<void> playCountSound() async {
    if (!_initialized) return;
    try {
      // Use system click sound to avoid missing asset issues.
      // If a custom click asset is added later, swap this back to AssetSource.
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail - sound is optional
    }
  }

  Future<void> playCompletionSound() async {
    if (!_initialized) return;
    try {
      await _completionPlayer.play(
        AssetSource('sounds/completion_sound_effect.mp3'),
        volume: 0.5,
      );
    } catch (e) {
      // Silently fail - sound is optional
    }
  }

  Future<void> dispose() async {
    await _countPlayer.dispose();
    await _completionPlayer.dispose();
  }
}
