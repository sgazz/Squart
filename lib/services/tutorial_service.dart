import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing tutorial state
class TutorialService {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyTutorialCompleted = 'tutorial_completed';
  
  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }
  
  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }
  
  /// Check if tutorial has been completed
  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTutorialCompleted) ?? false;
  }
  
  /// Mark tutorial as completed
  Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialCompleted, true);
  }
  
  /// Reset tutorial state (for testing)
  Future<void> resetTutorialState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, true);
    await prefs.setBool(_keyTutorialCompleted, false);
  }
  
  /// Check if tutorial should be shown
  Future<bool> shouldShowTutorial() async {
    final isFirst = await isFirstLaunch();
    final isCompleted = await isTutorialCompleted();
    return isFirst && !isCompleted;
  }
}

