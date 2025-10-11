import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import '../core/constants/game_constants.dart';

/// Service for saving and loading game state
class StorageService {
  static const String _keySavedGame = 'saved_game';
  static const String _keyHasSavedGame = 'has_saved_game';
  
  /// Save current game state
  Future<bool> saveGame(GameState gameState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameJson = jsonEncode(gameState.toJson());
      
      await prefs.setString(_keySavedGame, gameJson);
      await prefs.setBool(_keyHasSavedGame, true);
      
      return true;
    } catch (e) {
      debugPrint('Error saving game: $e');
      return false;
    }
  }
  
  /// Load saved game state
  Future<GameState?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameJson = prefs.getString(_keySavedGame);
      
      if (gameJson == null) {
        return null;
      }
      
      final gameMap = jsonDecode(gameJson) as Map<String, dynamic>;
      return GameState.fromJson(gameMap);
    } catch (e) {
      debugPrint('Error loading game: $e');
      return null;
    }
  }
  
  /// Check if there is a saved game
  Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSavedGame) ?? false;
    } catch (e) {
      debugPrint('Error checking saved game: $e');
      return false;
    }
  }
  
  /// Delete saved game
  Future<bool> deleteSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySavedGame);
      await prefs.setBool(_keyHasSavedGame, false);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting saved game: $e');
      return false;
    }
  }
  
  /// Auto-save game (called on pause or app close)
  Future<bool> autoSaveGame(GameState gameState) async {
    // Only save if game is in progress (not finished)
    if (gameState.gameStatus == GameConstants.stateFinished) {
      return false;
    }
    
    return await saveGame(gameState);
  }
}

