import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../widgets/glass_container.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';

/// Settings screen for game preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameProvider = context.watch<GameProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(isDark),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Theme Section
                GlassContainer(
                  padding: const EdgeInsets.all(AppSizes.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: AppColors.blueToken,
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          Text(
                            'Appearance',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceM),
                      _buildSettingRow(
                        context,
                        'Dark Mode',
                        'Use dark theme',
                        Switch(
                          value: isDark,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spaceM),
                
                // Game Settings - Увек прикажи Hints toggle
                GlassContainer(
                  padding: const EdgeInsets.all(AppSizes.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.videogame_asset,
                            color: AppColors.blueToken,
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          Text(
                            'Game Settings',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceM),
                      _buildSettingRow(
                        context,
                        'Show Hints',
                        'Highlight valid moves',
                        Switch(
                          value: context.watch<ThemeProvider>().showHints,
                          onChanged: (value) {
                            context.read<ThemeProvider>().toggleHints();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spaceM),
                
                // Audio Settings
                GlassContainer(
                  padding: const EdgeInsets.all(AppSizes.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.volume_up,
                            color: AppColors.blueToken,
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          Text(
                            'Audio & Haptics',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceM),
                      _buildSettingRow(
                        context,
                        'Sound Effects',
                        'Play audio feedback',
                        Switch(
                          value: gameProvider.gameState?.settings.soundEnabled ?? true,
                          onChanged: (value) {
                            gameProvider.updateSettings(soundEnabled: value);
                          },
                        ),
                      ),
                      const Divider(height: AppSizes.spaceL),
                      _buildSettingRow(
                        context,
                        'Vibration',
                        'Haptic feedback',
                        Switch(
                          value: gameProvider.gameState?.settings.vibrationEnabled ?? true,
                          onChanged: (value) {
                            gameProvider.updateSettings(vibrationEnabled: value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spaceM),
                
                // About Section
                GlassContainer(
                  padding: const EdgeInsets.all(AppSizes.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.blueToken,
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          Text(
                            'About',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceM),
                      Text(
                        'Squart',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceXS),
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      Text(
                        'A logic game for two players inspired by Domineering.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingRow(
    BuildContext context,
    String title,
    String subtitle,
    Widget trailing,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

