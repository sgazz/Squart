// import 'package:audioplayers/audioplayers.dart'; // Temporarily disabled for Android compat
// import '../constants/game_constants.dart'; // Temporarily unused

/// Manages audio playback for the game
/// NOTE: Audioplayers temporarily disabled for Android compatibility
class AudioManager {
  AudioManager._();
  
  static final AudioManager instance = AudioManager._();
  
  // final AudioPlayer _audioPlayer = AudioPlayer(); // Disabled
  bool _isEnabled = true;
  
  /// Initialize audio manager
  Future<void> init() async {
    // await _audioPlayer.setReleaseMode(ReleaseMode.stop); // Disabled
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
    // await _playSound(GameConstants.soundTokenPlace); // Disabled
  }
  
  /// Play win sound
  Future<void> playWin() async {
    if (!_isEnabled) return;
    // await _playSound(GameConstants.soundWin); // Disabled
  }
  
  /// Play lose sound
  Future<void> playLose() async {
    if (!_isEnabled) return;
    // await _playSound(GameConstants.soundLose); // Disabled
  }
  
  /// Play invalid move sound
  Future<void> playInvalid() async {
    if (!_isEnabled) return;
    // await _playSound(GameConstants.soundInvalid); // Disabled
  }
  
  /// Play timer tick sound
  Future<void> playTick() async {
    if (!_isEnabled) return;
    // await _playSound(GameConstants.soundTick); // Disabled
  }
  
  /// Play a sound from assets
  // Future<void> _playSound(String path) async {
  //   try {
  //     await _audioPlayer.stop();
  //     await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
  //   } catch (e) {
  //     // Silently fail if sound file doesn't exist
  //     // This allows development to continue without sound files
  //   }
  // }
  
  /// Dispose audio player
  Future<void> dispose() async {
    // await _audioPlayer.dispose(); // Disabled
  }
}

