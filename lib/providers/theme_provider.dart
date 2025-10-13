import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/performance_monitor.dart';

/// Provider for managing app theme and global settings
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _showHints = true;
  bool _isLoaded = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get showHints => _showHints;
  
  ThemeProvider() {
    PerformanceMonitor.instance.log('🎨 ThemeProvider created');
    _loadPreferences();
  }
  
  /// Load all preferences from storage (SINGLE SharedPreferences call)
  Future<void> _loadPreferences() async {
    if (_isLoaded) return;
    
    'ThemeProvider.loadPreferences'.startTracking();
    
    try {
      // Single SharedPreferences.getInstance() call with TIMEOUT
      'SharedPreferences.getInstance'.startTracking();
      
      // Add 2 second timeout - if SharedPreferences takes longer, use defaults
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          PerformanceMonitor.instance.log('⚠️  SharedPreferences timeout! Using defaults');
          throw TimeoutException('SharedPreferences too slow');
        },
      );
      
      'SharedPreferences.getInstance'.endTracking();
      
      final isDark = prefs.getBool(GameConstants.keyTheme) ?? true;
      final hints = prefs.getBool('show_hints') ?? true;
      
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _showHints = hints;
      _isLoaded = true;
      
      'ThemeProvider.loadPreferences'.endTracking({'theme': isDark ? 'dark' : 'light'});
      notifyListeners();
    } catch (e) {
      // Use defaults if error or timeout
      PerformanceMonitor.instance.logError('ThemeProvider.loadPreferences', e);
      _themeMode = ThemeMode.dark;
      _showHints = true;
      _isLoaded = true;
      'ThemeProvider.loadPreferences'.endTracking({'error': true});
      notifyListeners();
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

