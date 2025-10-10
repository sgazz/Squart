import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/audio_manager.dart';
import 'core/utils/haptic_manager.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize managers
  await AudioManager.instance.init();
  await HapticManager.instance.init();
  
  runApp(const SquartApp());
}

class SquartApp extends StatelessWidget {
  const SquartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Squart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark theme
        home: const HomeScreen(),
      ),
    );
  }
}
