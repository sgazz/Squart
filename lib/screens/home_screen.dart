import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/game_constants.dart';
import '../widgets/glass_container.dart';
import '../models/game_settings.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

/// Home screen with game setup options
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _boardSize = GameConstants.defaultBoardSize;
  int _timePerPlayer = GameConstants.timerUnlimited;
  String _gameMode = GameConstants.modePlayerVsPlayer;
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(isDark),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.spaceXXL),
                
                // Game Title
                Text(
                  'SQUART',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                
                const SizedBox(height: AppSizes.spaceS),
                
                Text(
                  'Logic game for two players',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                const SizedBox(height: AppSizes.spaceXXL),
                
                // Game Setup
                GlassContainer(
                  padding: const EdgeInsets.all(AppSizes.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'New Game',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      
                      const SizedBox(height: AppSizes.spaceL),
                      
                      // Board Size
                      Text(
                        'Board Size: $_boardSize × $_boardSize',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      Slider(
                        value: _boardSize.toDouble(),
                        min: GameConstants.minBoardSize.toDouble(),
                        max: GameConstants.maxBoardSize.toDouble(),
                        divisions: GameConstants.maxBoardSize - GameConstants.minBoardSize,
                        label: '$_boardSize × $_boardSize',
                        activeColor: AppColors.blueToken,
                        onChanged: (value) {
                          setState(() {
                            _boardSize = value.toInt();
                          });
                        },
                      ),
                      
                      const SizedBox(height: AppSizes.spaceM),
                      const Divider(),
                      const SizedBox(height: AppSizes.spaceM),
                      
                      // Timer
                      Text(
                        'Timer per player',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      Wrap(
                        spacing: AppSizes.spaceS,
                        runSpacing: AppSizes.spaceS,
                        children: GameConstants.timerOptions.map((time) {
                          final isSelected = _timePerPlayer == time;
                          return ChoiceChip(
                            label: Text(GameConstants.getTimerLabel(time)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _timePerPlayer = time;
                                });
                              }
                            },
                            selectedColor: AppColors.blueToken,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: AppSizes.spaceM),
                      const Divider(),
                      const SizedBox(height: AppSizes.spaceM),
                      
                      // Game Mode
                      Text(
                        'Game Mode',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: GameConstants.modePlayerVsPlayer,
                            label: Text('Player vs Player'),
                            icon: Icon(Icons.people),
                          ),
                          ButtonSegment(
                            value: GameConstants.modePlayerVsAI,
                            label: Text('Player vs AI'),
                            icon: Icon(Icons.computer),
                          ),
                        ],
                        selected: {_gameMode},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _gameMode = newSelection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.blueToken;
                            }
                            return null;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return null;
                          }),
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.spaceXL),
                      
                      // Start Game Button
                      ElevatedButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Game'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceM),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spaceL),
                
                // How to Play
                GlassContainer(
                  padding: const EdgeInsets.all(AppSizes.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: AppSizes.iconM),
                          const SizedBox(width: AppSizes.spaceS),
                          Text(
                            'How to Play',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceM),
                      _buildHowToPlayItem(
                        Icons.square,
                        'Blue player places horizontal tokens (2 cells wide)',
                        AppColors.blueToken,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      _buildHowToPlayItem(
                        Icons.square,
                        'Red player places vertical tokens (2 cells tall)',
                        AppColors.redToken,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      _buildHowToPlayItem(
                        Icons.block,
                        'Black cells cannot be used',
                        Colors.grey,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      _buildHowToPlayItem(
                        Icons.emoji_events,
                        'Win by making the last valid move',
                        AppColors.success,
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
  
  Widget _buildHowToPlayItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppSizes.iconS),
        const SizedBox(width: AppSizes.spaceS),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
  
  void _startGame() {
    final settings = GameSettings(
      boardSize: _boardSize,
      timePerPlayer: _timePerPlayer,
      gameMode: _gameMode,
      aiDifficulty: _gameMode == GameConstants.modePlayerVsAI 
          ? GameConstants.aiEasy 
          : null,
    );
    
    // Start game in provider
    context.read<GameProvider>().startNewGame(settings);
    
    // Navigate to game screen with fade transition
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: AppSizes.animationSlow),
      ),
    );
  }
}

