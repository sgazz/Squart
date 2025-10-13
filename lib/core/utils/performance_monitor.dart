import 'dart:io';
import 'package:flutter/foundation.dart';

/// Performance monitor za tracking startup i runtime performance
class PerformanceMonitor {
  PerformanceMonitor._();
  
  static final PerformanceMonitor instance = PerformanceMonitor._();
  
  final Map<String, DateTime> _startTimes = {};
  final Map<String, Duration> _durations = {};
  final List<String> _logs = [];
  
  DateTime? _appStartTime;
  int _initialMemory = 0;
  
  /// Inicijalizuj monitoring
  void init() {
    _appStartTime = DateTime.now();
    _initialMemory = _getCurrentMemory();
    log('🚀 App Started', {'memory': '${_formatMemory(_initialMemory)}'});
  }
  
  /// Loguj event sa optional metadata
  void log(String message, [Map<String, dynamic>? metadata]) {
    final timestamp = DateTime.now();
    final elapsed = _appStartTime != null 
        ? timestamp.difference(_appStartTime!).inMilliseconds 
        : 0;
    
    String metaStr = '';
    if (metadata != null && metadata.isNotEmpty) {
      final parts = metadata.entries.map((e) => '${e.key}=${e.value}').join(', ');
      metaStr = ' $parts';
    }
    
    final logMessage = '[+${elapsed}ms] $message$metaStr';
    _logs.add(logMessage);
    
    if (kDebugMode) {
      debugPrint('📊 $logMessage');
    }
  }
  
  /// Start tracking operacije
  void startTracking(String operation) {
    _startTimes[operation] = DateTime.now();
    log('⏱️  START: $operation');
  }
  
  /// End tracking operacije
  void endTracking(String operation, [Map<String, dynamic>? metadata]) {
    if (!_startTimes.containsKey(operation)) {
      log('⚠️  END without START: $operation');
      return;
    }
    
    final start = _startTimes[operation]!;
    final duration = DateTime.now().difference(start);
    _durations[operation] = duration;
    
    final meta = metadata ?? {};
    meta['duration'] = '${duration.inMilliseconds}ms';
    
    log('✅ END: $operation', meta);
    _startTimes.remove(operation);
  }
  
  /// Loguj memory snapshot
  void logMemory(String label) {
    final current = _getCurrentMemory();
    final delta = current - _initialMemory;
    
    log('💾 MEMORY: $label', {
      'current': _formatMemory(current),
      'delta': _formatMemory(delta),
    });
  }
  
  /// Loguj widget lifecycle
  void logLifecycle(String widget, String event) {
    log('🔄 LIFECYCLE: $widget.$event');
  }
  
  /// Loguj error
  void logError(String operation, Object error) {
    log('❌ ERROR: $operation', {'error': error.toString()});
  }
  
  /// Get memory summary
  Map<String, dynamic> getMemorySummary() {
    final current = _getCurrentMemory();
    return {
      'initial': _formatMemory(_initialMemory),
      'current': _formatMemory(current),
      'delta': _formatMemory(current - _initialMemory),
    };
  }
  
  /// Get duration summary
  Map<String, String> getDurationSummary() {
    return _durations.map((key, value) => 
      MapEntry(key, '${value.inMilliseconds}ms')
    );
  }
  
  /// Print complete report
  void printReport() {
    if (!kDebugMode) return;
    
    debugPrint('\n' + '═' * 70);
    debugPrint('📊 PERFORMANCE REPORT');
    debugPrint('═' * 70);
    
    // Timing summary
    if (_durations.isNotEmpty) {
      debugPrint('\n⏱️  TIMING SUMMARY:');
      _durations.forEach((operation, duration) {
        debugPrint('  • $operation: ${duration.inMilliseconds}ms');
      });
    }
    
    // Memory summary
    debugPrint('\n💾 MEMORY SUMMARY:');
    final memSummary = getMemorySummary();
    memSummary.forEach((key, value) {
      debugPrint('  • $key: ${value}');
    });
    
    // All logs
    debugPrint('\n📝 DETAILED LOG:');
    for (final log in _logs) {
      debugPrint('  ${log}');
    }
    
    debugPrint('\n' + '═' * 70 + '\n');
  }
  
  /// Clear all data
  void clear() {
    _startTimes.clear();
    _durations.clear();
    _logs.clear();
    _appStartTime = null;
    _initialMemory = 0;
  }
  
  /// Get current process memory in bytes (iOS/Android)
  int _getCurrentMemory() {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        // Ovo je aproximacija - za tačnije merenje treba native kod
        return ProcessInfo.currentRss;
      }
    } catch (e) {
      // Fallback
    }
    return 0;
  }
  
  /// Format memory u human-readable format
  String _formatMemory(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Extension za easy tracking
extension PerformanceTracker on String {
  void startTracking() => PerformanceMonitor.instance.startTracking(this);
  void endTracking([Map<String, dynamic>? meta]) => 
      PerformanceMonitor.instance.endTracking(this, meta);
}

