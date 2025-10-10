import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/game_constants.dart';

/// Provider for managing app theme and global settings
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _showHints = true;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get showHints => _showHints;
  
  ThemeProvider() {
    _loadThemePreference();
    _loadHintsPreference();
  }
  
  /// Load theme preference from storage
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(GameConstants.keyTheme) ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Use default dark theme if error
      _themeMode = ThemeMode.dark;
    }
  }
  
  /// Load hints preference from storage
  Future<void> _loadHintsPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _showHints = prefs.getBool('show_hints') ?? true;
      notifyListeners();
    } catch (e) {
      // Use default true if error
      _showHints = true;
    }
  }
  
  /// Toggle between dark and light theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(GameConstants.keyTheme, _themeMode == ThemeMode.dark);
    } catch (e) {
      // Failed to save preference
    }
  }
  
  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(GameConstants.keyTheme, _themeMode == ThemeMode.dark);
    } catch (e) {
      // Failed to save preference
    }
  }
  
  /// Toggle hints setting
  Future<void> toggleHints() async {
    _showHints = !_showHints;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_hints', _showHints);
    } catch (e) {
      // Failed to save preference
    }
  }
}

