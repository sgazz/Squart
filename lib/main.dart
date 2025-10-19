import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/audio_manager.dart';
import 'core/utils/haptic_manager.dart';
import 'core/utils/performance_monitor.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // Start performance monitoring FIRST
  PerformanceMonitor.instance.init();
  PerformanceMonitor.instance.log('🎯 main() started');
  
  'WidgetsFlutterBinding'.startTracking();
  WidgetsFlutterBinding.ensureInitialized();
  'WidgetsFlutterBinding'.endTracking();
  
  // Initialize haptic manager (instant)
  'HapticManager.init'.startTracking();
  await HapticManager.instance.init();
  'HapticManager.init'.endTracking();
  
  // TEMPORARILY DISABLED: Audio loading takes 6s on iOS!
  // TODO: Re-enable after fixing performance issue
  // 'AudioManager.init'.startTracking();
  // AudioManager.instance.init().then((_) {
  //   'AudioManager.init'.endTracking();
  // }).catchError((error) {
  //   PerformanceMonitor.instance.logError('AudioManager.init', error);
  //   debugPrint('Audio initialization failed: $error');
  // });
  PerformanceMonitor.instance.log('⚠️  Audio DISABLED (performance issue)');
  
  PerformanceMonitor.instance.log('🚀 Launching app...');
  PerformanceMonitor.instance.logMemory('Before runApp');
  
  runApp(const SquartApp());
}

class SquartApp extends StatefulWidget {
  const SquartApp({super.key});

  @override
  State<SquartApp> createState() => _SquartAppState();
}

class _SquartAppState extends State<SquartApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    PerformanceMonitor.instance.logLifecycle('SquartApp', 'initState');
    WidgetsBinding.instance.addObserver(this);
    
    // Log first frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceMonitor.instance.log('🎨 First frame rendered');
      PerformanceMonitor.instance.logMemory('After first frame');
      PerformanceMonitor.instance.printReport();
    });
  }

  @override
  void dispose() {
    PerformanceMonitor.instance.logLifecycle('SquartApp', 'dispose');
    WidgetsBinding.instance.removeObserver(this);
    // Dispose audio manager when app is closed
    'AudioManager.dispose'.startTracking();
    AudioManager.instance.dispose();
    'AudioManager.dispose'.endTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    PerformanceMonitor.instance.log('🔄 Lifecycle: ${state.name}');
    PerformanceMonitor.instance.logMemory('Lifecycle: ${state.name}');
    
    // Manage app lifecycle (background/foreground)
    if (state == AppLifecycleState.paused) {
      // App is going to background - pause audio if needed
      PerformanceMonitor.instance.log('⏸️  App paused');
      _handlePause();
    } else if (state == AppLifecycleState.resumed) {
      // App is resuming from background
      PerformanceMonitor.instance.log('▶️  App resumed');
      PerformanceMonitor.instance.logMemory('After resume');
      _handleResume();
    } else if (state == AppLifecycleState.detached) {
      // App is being killed - cleanup NOW
      PerformanceMonitor.instance.log('💀 App detached - cleanup');
      _handleDetached();
    }
  }
  
  /// Handle app pause - save state
  void _handlePause() {
    try {
      PerformanceMonitor.instance.log('💾 Saving state on pause...');
      // Auto-save game state if needed
      // (already handled in game_provider)
    } catch (e) {
      PerformanceMonitor.instance.logError('handlePause', e);
    }
  }
  
  /// Handle app resume - restore state
  void _handleResume() {
    try {
      PerformanceMonitor.instance.log('♻️  Restoring state on resume...');
      // Nothing to restore currently
    } catch (e) {
      PerformanceMonitor.instance.logError('handleResume', e);
    }
  }
  
  /// Handle app detached - final cleanup
  void _handleDetached() {
    try {
      PerformanceMonitor.instance.log('🧹 Final cleanup on detach...');
      
      // Force dispose audio if initialized
      // (even though it's disabled, cleanup any partial state)
      AudioManager.instance.dispose().catchError((e) {
        debugPrint('Audio dispose error (expected): $e');
      });
      
      PerformanceMonitor.instance.log('✅ Cleanup complete');
    } catch (e) {
      PerformanceMonitor.instance.logError('handleDetached', e);
      debugPrint('Detached cleanup error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MultiplayerProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Squart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
