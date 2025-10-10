import 'package:audioplayers/audioplayers.dart';
import '../constants/game_constants.dart';

/// Manages audio playback for the game
class AudioManager {
  AudioManager._();
  
  static final AudioManager instance = AudioManager._();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;
  
  /// Initialize audio manager
  Future<void> init() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }
  
  /// Set audio enabled/disabled
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// Check if audio is enabled
  bool get isEnabled => _isEnabled;
  
  /// Play token placement sound
  Future<void> playTokenPlace() async {
    if (!_isEnabled) return;
    await _playSound(GameConstants.soundTokenPlace);
  }
  
  /// Play win sound
  Future<void> playWin() async {
    if (!_isEnabled) return;
    await _playSound(GameConstants.soundWin);
  }
  
  /// Play lose sound
  Future<void> playLose() async {
    if (!_isEnabled) return;
    await _playSound(GameConstants.soundLose);
  }
  
  /// Play invalid move sound
  Future<void> playInvalid() async {
    if (!_isEnabled) return;
    await _playSound(GameConstants.soundInvalid);
  }
  
  /// Play timer tick sound
  Future<void> playTick() async {
    if (!_isEnabled) return;
    await _playSound(GameConstants.soundTick);
  }
  
  /// Play a sound from assets
  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (e) {
      // Silently fail if sound file doesn't exist
      // This allows development to continue without sound files
    }
  }
  
  /// Dispose audio player
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

