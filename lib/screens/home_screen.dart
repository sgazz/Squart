import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/game_constants.dart';
import '../widgets/glass_container.dart';
import '../models/game_settings.dart';
import '../models/ai_difficulty.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../services/tutorial_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

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
  AIDifficulty _aiDifficulty = AIDifficulty.medium;
  String _startingPlayer = GameConstants.playerBlue;
  final TutorialService _tutorialService = TutorialService();
  bool _hasSavedGame = false;
  
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _checkSavedGame();
  }
  
  Future<void> _checkSavedGame() async {
    final hasSaved = await context.read<GameProvider>().hasSavedGame();
    if (mounted) {
      setState(() {
        _hasSavedGame = hasSaved;
      });
    }
  }
  
  Future<void> _checkFirstLaunch() async {
    final shouldShow = await _tutorialService.shouldShowTutorial();
    if (shouldShow && mounted) {
      // Show tutorial after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showTutorial();
        }
      });
    }
  }
  
  void _showTutorial() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TutorialScreen(),
      ),
    ).then((_) {
      // Mark tutorial as completed when user closes it
      _tutorialService.markTutorialCompleted();
      _tutorialService.markFirstLaunchComplete();
    });
  }
  
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
              icon: const Icon(Icons.help_outline),
              tooltip: 'How to Play',
              onPressed: _showTutorial,
            ),
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
                      Builder(
                        builder: (context) {
                          // Calculate max board size based on screen width
                          final screenWidth = MediaQuery.of(context).size.width;
                          final maxSize = GameConstants.getMaxBoardSizeForScreen(screenWidth);
                          
                          // Clamp current board size to max
                          if (_boardSize > maxSize) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _boardSize = maxSize;
                              });
                            });
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Board Size: $_boardSize × $_boardSize',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: AppSizes.spaceS),
                              Slider(
                                value: _boardSize.toDouble(),
                                min: GameConstants.minBoardSize.toDouble(),
                                max: maxSize.toDouble(),
                                divisions: maxSize - GameConstants.minBoardSize,
                                label: '$_boardSize × $_boardSize',
                                activeColor: AppColors.blueToken,
                                onChanged: (value) {
                                  setState(() {
                                    _boardSize = value.toInt();
                                  });
                                },
                              ),
                            ],
                          );
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
                      
                      // Starting Player
                      Text(
                        'Starting Player',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment<String>(
                            value: GameConstants.playerBlue,
                            label: const Text('Blue'),
                            icon: const Icon(Icons.square),
                          ),
                          ButtonSegment<String>(
                            value: GameConstants.playerRed,
                            label: const Text('Red'),
                            icon: const Icon(Icons.square),
                          ),
                        ],
                        selected: {_startingPlayer},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _startingPlayer = newSelection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return _startingPlayer == GameConstants.playerBlue
                                    ? AppColors.blueToken
                                    : AppColors.redToken;
                              }
                              return Colors.transparent;
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return AppColors.textSecondary;
                            },
                          ),
                        ),
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
                      
                      // AI Difficulty (only show if PvE mode)
                      if (_gameMode == GameConstants.modePlayerVsAI) ...[
                        const SizedBox(height: AppSizes.spaceM),
                        const Divider(),
                        const SizedBox(height: AppSizes.spaceM),
                        
                        Text(
                          'AI Difficulty',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSizes.spaceS),
                        Wrap(
                          spacing: AppSizes.spaceS,
                          runSpacing: AppSizes.spaceS,
                          children: AIDifficulty.values.map((difficulty) {
                            final isSelected = _aiDifficulty == difficulty;
                            return ChoiceChip(
                              label: Text(difficulty.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _aiDifficulty = difficulty;
                                  });
                                }
                              },
                              selectedColor: AppColors.redToken,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSizes.spaceS),
                        Text(
                          _aiDifficulty.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: AppSizes.spaceXL),
                      
                      // Continue Game Button (if saved game exists)
                      if (_hasSavedGame) ...[
                        ElevatedButton.icon(
                          onPressed: _continueGame,
                          icon: const Icon(Icons.play_circle_filled),
                          label: const Text('Continue Game'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceM),
                            backgroundColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spaceM),
                      ],
                      
                      // Start Game Button
                      ElevatedButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_gameMode == GameConstants.modePlayerVsAI 
                          ? 'Play vs AI' 
                          : 'Start Game'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceM),
                        ),
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
  
  void _continueGame() async {
    // Load saved game
    final success = await context.read<GameProvider>().loadSavedGame();
    
    if (!success) {
      // Show error if load failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load saved game'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    // Navigate to game screen
    if (mounted) {
      _navigateToGameScreen();
    }
  }
  
  void _startGame() async {
    // Get showHints and gameProvider before any async gaps
    final showHints = context.read<ThemeProvider>().showHints;
    final gameProvider = context.read<GameProvider>();
    
    // Check if there's a saved game
    if (_hasSavedGame) {
      // Show warning dialog
      final shouldOverwrite = await _showOverwriteDialog();
      if (shouldOverwrite != true) {
        return; // User cancelled
      }
    }
    
    final settings = GameSettings(
      boardSize: _boardSize,
      timePerPlayer: _timePerPlayer,
      gameMode: _gameMode,
      aiDifficulty: _gameMode == GameConstants.modePlayerVsAI 
          ? _aiDifficulty 
          : null,
      startingPlayer: _startingPlayer,
      showHints: showHints,
    );
    
    // Start new game (with overwrite if needed)
    await gameProvider.startNewGameWithOverwrite(settings);
    
    // Update saved game status
    if (mounted) {
      setState(() {
        _hasSavedGame = false;
      });
      
      // Navigate to game screen
      _navigateToGameScreen();
    }
  }
  
  Future<bool?> _showOverwriteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overwrite Saved Game?'),
        content: const Text(
          'You have a saved game in progress. Starting a new game will delete the saved game. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToGameScreen() {
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
    ).then((_) {
      // Refresh saved game status when returning from game
      _checkSavedGame();
    });
  }
}

