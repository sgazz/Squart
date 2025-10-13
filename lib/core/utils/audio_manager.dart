import 'package:just_audio/just_audio.dart';
import '../constants/game_constants.dart';

/// Manages audio playback for the game using just_audio
/// Uses multiple pre-loaded audio players for efficient memory usage
class AudioManager {
  AudioManager._();
  
  static final AudioManager instance = AudioManager._();
  
  // Separate audio players for each sound to avoid memory issues
  late final AudioPlayer _tokenPlacePlayer;
  late final AudioPlayer _winPlayer;
  late final AudioPlayer _losePlayer;
  late final AudioPlayer _invalidPlayer;
  late final AudioPlayer _tickPlayer;
  
  bool _isEnabled = true;
  bool _isInitialized = false;
  
  /// Initialize audio manager - preload all sounds once
  Future<void> init() async {
    try {
      // Initialize all audio players
      _tokenPlacePlayer = AudioPlayer();
      _winPlayer = AudioPlayer();
      _losePlayer = AudioPlayer();
      _invalidPlayer = AudioPlayer();
      _tickPlayer = AudioPlayer();
      
      // Preload all audio assets once to avoid repeated loading
      await Future.wait([
        _tokenPlacePlayer.setAsset('assets/${GameConstants.soundTokenPlace}'),
        _winPlayer.setAsset('assets/${GameConstants.soundWin}'),
        _losePlayer.setAsset('assets/${GameConstants.soundLose}'),
        _invalidPlayer.setAsset('assets/${GameConstants.soundInvalid}'),
        _tickPlayer.setAsset('assets/${GameConstants.soundTick}'),
      ]);
      
      // Set audio players to loop mode off and low latency mode
      await Future.wait([
        _tokenPlacePlayer.setLoopMode(LoopMode.off),
        _winPlayer.setLoopMode(LoopMode.off),
        _losePlayer.setLoopMode(LoopMode.off),
        _invalidPlayer.setLoopMode(LoopMode.off),
        _tickPlayer.setLoopMode(LoopMode.off),
      ]);
      
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
    await _playSoundFromPlayer(_tokenPlacePlayer);
  }
  
  /// Play win sound
  Future<void> playWin() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSoundFromPlayer(_winPlayer);
  }
  
  /// Play lose sound
  Future<void> playLose() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSoundFromPlayer(_losePlayer);
  }
  
  /// Play invalid move sound
  Future<void> playInvalid() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSoundFromPlayer(_invalidPlayer);
  }
  
  /// Play timer tick sound
  Future<void> playTick() async {
    if (!_isEnabled || !_isInitialized) return;
    await _playSoundFromPlayer(_tickPlayer);
  }
  
  /// Play a sound from pre-loaded audio player
  /// Uses fire-and-forget approach to avoid blocking
  Future<void> _playSoundFromPlayer(AudioPlayer player) async {
    try {
      // Seek to beginning and play (no need to reload asset)
      // Use unawaited to avoid blocking - audio playback is fire-and-forget
      player.seek(Duration.zero).then((_) => player.play());
    } catch (e) {
      // Silently fail if sound can't play
    }
  }
  
  /// Dispose all audio players
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    await Future.wait([
      _tokenPlacePlayer.dispose(),
      _winPlayer.dispose(),
      _losePlayer.dispose(),
      _invalidPlayer.dispose(),
      _tickPlayer.dispose(),
    ]);
    
    _isInitialized = false;
  }
}
