import 'package:just_audio/just_audio.dart';
import '../constants/game_constants.dart';
import 'performance_monitor.dart';

/// Manages audio playback for the game using just_audio
/// Uses multiple pre-loaded audio players for efficient memory usage
class AudioManager {
  AudioManager._();
  
  static final AudioManager instance = AudioManager._();
  
  // Separate audio players for each sound to avoid memory issues
  // Nullable because they may not be initialized if audio is disabled
  AudioPlayer? _tokenPlacePlayer;
  AudioPlayer? _winPlayer;
  AudioPlayer? _losePlayer;
  AudioPlayer? _invalidPlayer;
  AudioPlayer? _tickPlayer;
  
  bool _isEnabled = true;
  bool _isInitialized = false;
  
  /// Initialize audio manager - preload all sounds once
  Future<void> init() async {
    PerformanceMonitor.instance.log('🔊 AudioManager.init started');
    'AudioManager.createPlayers'.startTracking();
    
    try {
      // Initialize all audio players
      _tokenPlacePlayer = AudioPlayer();
      _winPlayer = AudioPlayer();
      _losePlayer = AudioPlayer();
      _invalidPlayer = AudioPlayer();
      _tickPlayer = AudioPlayer();
      'AudioManager.createPlayers'.endTracking();
      
      // Preload all audio assets once to avoid repeated loading
      'AudioManager.loadAssets'.startTracking();
      await Future.wait([
        _tokenPlacePlayer!.setAsset('assets/${GameConstants.soundTokenPlace}'),
        _winPlayer!.setAsset('assets/${GameConstants.soundWin}'),
        _losePlayer!.setAsset('assets/${GameConstants.soundLose}'),
        _invalidPlayer!.setAsset('assets/${GameConstants.soundInvalid}'),
        _tickPlayer!.setAsset('assets/${GameConstants.soundTick}'),
      ]);
      'AudioManager.loadAssets'.endTracking();
      
      _isInitialized = true;
      PerformanceMonitor.instance.log('✅ AudioManager initialized');
      PerformanceMonitor.instance.logMemory('After AudioManager init');
      
      // Set audio players to loop mode off (non-blocking, can happen after init)
      _tokenPlacePlayer!.setLoopMode(LoopMode.off);
      _winPlayer!.setLoopMode(LoopMode.off);
      _losePlayer!.setLoopMode(LoopMode.off);
      _invalidPlayer!.setLoopMode(LoopMode.off);
      _tickPlayer!.setLoopMode(LoopMode.off);
    } catch (e) {
      // Silently fail if audio initialization fails
      PerformanceMonitor.instance.logError('AudioManager.init', e);
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
  Future<void> _playSoundFromPlayer(AudioPlayer? player) async {
    if (player == null) return; // Not initialized
    
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
    if (!_isInitialized) {
      PerformanceMonitor.instance.log('🔊 AudioManager not initialized, skip dispose');
      return;
    }
    
    PerformanceMonitor.instance.log('🔊 AudioManager disposing...');
    'AudioManager.disposePlayers'.startTracking();
    
    // Only dispose if players were created
    final disposals = <Future>[];
    if (_tokenPlacePlayer != null) disposals.add(_tokenPlacePlayer!.dispose());
    if (_winPlayer != null) disposals.add(_winPlayer!.dispose());
    if (_losePlayer != null) disposals.add(_losePlayer!.dispose());
    if (_invalidPlayer != null) disposals.add(_invalidPlayer!.dispose());
    if (_tickPlayer != null) disposals.add(_tickPlayer!.dispose());
    
    if (disposals.isNotEmpty) {
      await Future.wait(disposals);
    }
    
    _isInitialized = false;
    'AudioManager.disposePlayers'.endTracking();
    PerformanceMonitor.instance.log('✅ AudioManager disposed');
    PerformanceMonitor.instance.logMemory('After AudioManager dispose');
  }
}
