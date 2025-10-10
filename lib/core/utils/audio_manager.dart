import 'package:just_audio/just_audio.dart';
import '../constants/game_constants.dart';

/// Manages audio playback for the game using just_audio
class AudioManager {
  AudioManager._();
  
  static final AudioManager instance = AudioManager._();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;
  bool _isInitialized = false;
  
  /// Initialize audio manager
  Future<void> init() async {
    try {
      _isInitialized = true;
    } catch (e) {
      // Silently fail if audio initialization fails
      _isInitialized = false;
    }
  }
  
  /// Set audio enabled/disabled
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// Check if audio is enabled
  bool get isEnabled => _isEnabled;
  
  /// Play token placement sound
  Future<void> playTokenPlace() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSound(GameConstants.soundTokenPlace);
  }
  
  /// Play win sound
  Future<void> playWin() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSound(GameConstants.soundWin);
  }
  
  /// Play lose sound
  Future<void> playLose() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSound(GameConstants.soundLose);
  }
  
  /// Play invalid move sound
  Future<void> playInvalid() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSound(GameConstants.soundInvalid);
  }
  
  /// Play timer tick sound
  Future<void> playTick() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSound(GameConstants.soundTick);
  }
  
  /// Play a sound from assets
  Future<void> _playSound(String path) async {
    try {
      // Stop any currently playing sound
      await _audioPlayer.stop();
      
      // Set asset and play (path should be relative to assets folder)
      await _audioPlayer.setAsset('assets/$path');
      await _audioPlayer.play();
      
      // Reset to beginning for next play
      await _audioPlayer.seek(Duration.zero);
    } catch (e) {
      // Silently fail if sound file doesn't exist or can't play
      // This allows development to continue without sound files
    }
  }
  
  /// Dispose audio player
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
