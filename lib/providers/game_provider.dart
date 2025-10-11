import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/game_settings.dart';
import '../services/game_logic_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../core/utils/audio_manager.dart';
import '../core/utils/haptic_manager.dart';
import '../core/constants/game_constants.dart';

/// Provider for managing game state
class GameProvider with ChangeNotifier {
  final GameLogicService _gameLogic = GameLogicService();
  final AIService _aiService = AIService();
  final StorageService _storageService = StorageService();
  GameState? _gameState;
  Timer? _timer;
  bool _isAIThinking = false;
  
  GameState? get gameState => _gameState;
  bool get hasGame => _gameState != null;
  bool get isGameActive => _gameState?.isPlaying ?? false;
  bool get isAIThinking => _isAIThinking;
  bool get isPlayerVsAI => _gameState?.settings.isPlayerVsAI ?? false;
  bool get isAITurn => isPlayerVsAI && _gameState?.isRedsTurn == true;
  
  /// Start a new game with given settings
  void startNewGame(GameSettings settings) {
    // Cancel existing timer
    _timer?.cancel();
    _isAIThinking = false;
    
    // Create new game
    _gameState = _gameLogic.createNewGame(settings);
    
    // Apply settings to managers
    AudioManager.instance.setEnabled(settings.soundEnabled);
    HapticManager.instance.setEnabled(settings.vibrationEnabled);
    
    // Start timer if enabled
    if (settings.hasTimer) {
      _startTimer();
    }
    
    notifyListeners();
    
    // If AI is first player (Red), make AI move
    // Note: In our game, Blue always goes first (horizontal)
    // So AI will be Red (vertical) and will move second
  }
  
  /// Make a move at given position
  Future<void> makeMove(int row, int col) async {
    if (_gameState == null || _gameState!.isFinished || _isAIThinking) return;
    
    // In PvE mode, only allow player (Blue) to make moves
    if (isPlayerVsAI && _gameState!.isRedsTurn) {
      return; // It's AI's turn, player can't move
    }
    
    try {
      // Validate and place token
      if (_gameLogic.isValidMove(_gameState!, row, col)) {
        _gameState = _gameLogic.placeToken(_gameState!, row, col);
        
        // Play sound and haptic feedback
        await AudioManager.instance.playTokenPlace();
        await HapticManager.instance.light();
        
        // Check if game ended
        if (_gameState!.isFinished) {
          _timer?.cancel();
          
          // Play win/lose sound based on winner
          if (_gameState!.winner != null) {
            final isPlayerWin = _gameState!.winner == GameConstants.playerBlue;
            if (isPlayerWin) {
              await AudioManager.instance.playWin();
              await HapticManager.instance.success();
            } else {
              await AudioManager.instance.playLose();
              await HapticManager.instance.heavy();
            }
          }
        }
        
        notifyListeners();
        
        // If it's AI's turn now, trigger AI move
        if (isAITurn && !_gameState!.isFinished) {
          await _makeAIMove();
        }
      } else {
        // Invalid move
        await AudioManager.instance.playInvalid();
        await HapticManager.instance.error();
      }
    } catch (e) {
      debugPrint('Error making move: $e');
      await AudioManager.instance.playInvalid();
      await HapticManager.instance.error();
    }
  }
  
  /// Make AI move
  Future<void> _makeAIMove() async {
    if (_gameState == null || _gameState!.isFinished || !isAITurn) return;
    if (_gameState!.settings.aiDifficulty == null) return;
    
    _isAIThinking = true;
    notifyListeners();
    
    try {
      // Calculate AI move
      final aiMove = await _aiService.calculateMove(
        _gameState!,
        _gameState!.settings.aiDifficulty!,
      );
      
      // Make the move
      _gameState = _gameLogic.placeToken(_gameState!, aiMove.row, aiMove.col);
      
      // Play sound and haptic feedback
      await AudioManager.instance.playTokenPlace();
      await HapticManager.instance.light();
      
      // Check if game ended
      if (_gameState!.isFinished) {
        _timer?.cancel();
        
        // Play win/lose sound based on winner
        if (_gameState!.winner != null) {
          final isPlayerWin = _gameState!.winner == GameConstants.playerBlue;
          if (isPlayerWin) {
            await AudioManager.instance.playWin();
            await HapticManager.instance.success();
          } else {
            await AudioManager.instance.playLose();
            await HapticManager.instance.heavy();
          }
        }
      }
    } catch (e) {
      debugPrint('Error making AI move: $e');
    } finally {
      _isAIThinking = false;
      notifyListeners();
    }
  }
  
  /// Get valid moves for current player
  List<(int, int)> getValidMoves() {
    if (_gameState == null) return [];
    return _gameLogic.getValidMoves(_gameState!);
  }
  
  /// Check if move is valid
  bool isValidMove(int row, int col) {
    if (_gameState == null) return false;
    return _gameLogic.isValidMove(_gameState!, row, col);
  }
  
  /// Pause game
  void pauseGame() {
    if (_gameState == null || _gameState!.isFinished) return;
    
    _gameState = _gameLogic.pauseGame(_gameState!);
    _timer?.cancel();
    
    // Auto-save when pausing
    autoSaveGame();
    
    notifyListeners();
  }
  
  /// Resume game
  void resumeGame() {
    if (_gameState == null || _gameState!.isFinished) return;
    
    _gameState = _gameLogic.resumeGame(_gameState!);
    
    // Restart timer if enabled
    if (_gameState!.settings.hasTimer) {
      _startTimer();
    }
    
    notifyListeners();
  }
  
  /// Start timer for game
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == null || !_gameState!.isPlaying) {
        timer.cancel();
        return;
      }
      
      // Update timer
      _gameState = _gameLogic.updateTimer(_gameState!);
      
      // Check for timeout
      _gameState = _gameLogic.checkTimeout(_gameState!);
      
      // Play tick sound when time is running out
      if (_gameState!.currentPlayerTimeRemaining <= GameConstants.timerWarningThreshold &&
          _gameState!.currentPlayerTimeRemaining > 0) {
        AudioManager.instance.playTick();
      }
      
      // Check if game ended due to timeout
      if (_gameState!.isFinished) {
        timer.cancel();
        AudioManager.instance.playLose();
        HapticManager.instance.heavy();
      }
      
      notifyListeners();
    });
  }
  
  /// End current game
  void endGame() {
    _timer?.cancel();
    _gameState = null;
    notifyListeners();
  }
  
  /// Update settings (sound, vibration, hints)
  void updateSettings({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showHints,
  }) {
    if (_gameState == null) return;
    
    final newSettings = _gameState!.settings.copyWith(
      soundEnabled: soundEnabled ?? _gameState!.settings.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? _gameState!.settings.vibrationEnabled,
      showHints: showHints ?? _gameState!.settings.showHints,
    );
    
    _gameState = _gameState!.copyWith(settings: newSettings);
    
    // Apply to managers
    AudioManager.instance.setEnabled(newSettings.soundEnabled);
    HapticManager.instance.setEnabled(newSettings.vibrationEnabled);
    
    notifyListeners();
  }
  
  /// Get black cells percentage
  double getBlackCellsPercentage() {
    if (_gameState == null) return 0.0;
    return _gameLogic.getBlackCellsPercentage(_gameState!.board);
  }
  
  // ==================== SAVE/LOAD FUNCTIONALITY ====================
  
  /// Check if there is a saved game
  Future<bool> hasSavedGame() async {
    return await _storageService.hasSavedGame();
  }
  
  /// Load saved game and continue playing
  Future<bool> loadSavedGame() async {
    final savedState = await _storageService.loadGame();
    
    if (savedState == null) {
      return false;
    }
    
    // Cancel existing timer
    _timer?.cancel();
    _isAIThinking = false;
    
    // Load saved state
    _gameState = savedState;
    
    // Apply settings to managers
    AudioManager.instance.setEnabled(savedState.settings.soundEnabled);
    HapticManager.instance.setEnabled(savedState.settings.vibrationEnabled);
    
    // Resume timer if game is playing and has timer
    if (savedState.isPlaying && savedState.settings.hasTimer) {
      _startTimer();
    }
    
    notifyListeners();
    return true;
  }
  
  /// Save current game
  Future<bool> saveCurrentGame() async {
    if (_gameState == null) {
      return false;
    }
    
    return await _storageService.saveGame(_gameState!);
  }
  
  /// Auto-save game (called on pause or app lifecycle changes)
  Future<void> autoSaveGame() async {
    if (_gameState != null) {
      await _storageService.autoSaveGame(_gameState!);
    }
  }
  
  /// Delete saved game
  Future<bool> deleteSavedGame() async {
    return await _storageService.deleteSavedGame();
  }
  
  /// Start new game and optionally delete saved game
  Future<void> startNewGameWithOverwrite(GameSettings settings) async {
    // Delete any existing saved game
    await deleteSavedGame();
    
    // Start new game
    startNewGame(settings);
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

