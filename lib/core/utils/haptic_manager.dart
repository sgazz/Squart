import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Manages haptic feedback for the game
class HapticManager {
  HapticManager._();
  
  static final HapticManager instance = HapticManager._();
  
  bool _isEnabled = true;
  bool? _hasVibrator;
  
  /// Initialize haptic manager
  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
  }
  
  /// Set haptic feedback enabled/disabled
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// Check if haptic feedback is enabled
  bool get isEnabled => _isEnabled;
  
  /// Light haptic feedback (for token placement)
  Future<void> light() async {
    if (!_isEnabled) return;
    
    if (_hasVibrator == true) {
      await Vibration.vibrate(duration: 50);
    } else {
      await HapticFeedback.lightImpact();
    }
  }
  
  /// Medium haptic feedback (for UI interactions)
  Future<void> medium() async {
    if (!_isEnabled) return;
    
    if (_hasVibrator == true) {
      await Vibration.vibrate(duration: 100);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }
  
  /// Heavy haptic feedback (for game end)
  Future<void> heavy() async {
    if (!_isEnabled) return;
    
    if (_hasVibrator == true) {
      await Vibration.vibrate(duration: 200);
    } else {
      await HapticFeedback.heavyImpact();
    }
  }
  
  /// Error haptic feedback (for invalid moves)
  Future<void> error() async {
    if (!_isEnabled) return;
    
    if (_hasVibrator == true) {
      await Vibration.vibrate(pattern: [0, 50, 50, 50]);
    } else {
      await HapticFeedback.vibrate();
    }
  }
  
  /// Success haptic feedback (for winning)
  Future<void> success() async {
    if (!_isEnabled) return;
    
    if (_hasVibrator == true) {
      await Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 200]);
    } else {
      await HapticFeedback.heavyImpact();
    }
  }
}

