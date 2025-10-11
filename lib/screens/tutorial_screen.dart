import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../models/tutorial_slide.dart';
import '../core/constants/app_colors.dart';

/// Tutorial screen with interactive slides showing how to play
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Check if running on desktop or web (platforms that benefit from buttons)
  bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          backgroundColor: Colors.transparent,
          title: const Text('How to Play'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
        children: [
          // Page View
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: TutorialData.slides.length,
              itemBuilder: (context, index) {
                final slide = TutorialData.slides[index];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: slide.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Visual example for each slide
                        _buildVisualExample(index),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Navigation Controls - conditional based on platform
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isDesktopOrWeb ? _buildDesktopNavigation() : _buildMobileNavigation(),
          ),
        ],
        ),
      ),
    );
  }
  
  // Desktop/Web navigation with buttons
  Widget _buildDesktopNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        SizedBox(
          width: 100,
          child: _currentPage > 0
              ? TextButton.icon(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                )
              : null,
        ),
        
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            TutorialData.slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == _currentPage ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? TutorialData.slides[_currentPage].color
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        // Next/Done Button
        SizedBox(
          width: 100,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_currentPage < TutorialData.slides.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(
              _currentPage == TutorialData.slides.length - 1
                  ? Icons.check
                  : Icons.arrow_forward,
            ),
            label: Text(
              _currentPage == TutorialData.slides.length - 1
                  ? 'Done'
                  : 'Next',
            ),
          ),
        ),
      ],
    );
  }
  
  // Mobile navigation with just page indicator (swipe to navigate)
  Widget _buildMobileNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        TutorialData.slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? TutorialData.slides[_currentPage].color
                : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
  
  Widget _buildVisualExample(int slideIndex) {
    switch (slideIndex) {
      case 0:
        return _buildWelcomeExample();
      case 1:
        return _buildBluePlayerExample();
      case 2:
        return _buildRedPlayerExample();
      case 3:
        return _buildWinConditionExample();
      default:
        return const SizedBox.shrink();
    }
  }
  
  // Slide 1: Welcome - Show empty board
  Widget _buildWelcomeExample() {
    return Column(
      children: [
        Text(
          'This is how boards look at the start of each game',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildMiniBoard(
          size: 5,
          tokens: {},
          blackCells: {'1,2', '2,1', '3,3'},
        ),
        const SizedBox(height: 12),
        Text(
          'Black cells cannot be used.\nPlayers take turns placing tokens!',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Slide 2: Blue Player - Show horizontal tokens
  Widget _buildBluePlayerExample() {
    return Column(
      children: [
        Text(
          'Blue Horizontal Tokens (2 cells wide)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blueToken,
          ),
        ),
        const SizedBox(height: 16),
        _buildMiniBoard(
          size: 5,
          tokens: {
            '0,0': {'color': AppColors.blueToken, 'isHorizontal': true},
            '0,1': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,2': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,3': {'color': AppColors.blueToken, 'isHorizontal': true},
            '4,1': {'color': AppColors.blueToken, 'isHorizontal': true},
            '4,2': {'color': AppColors.blueToken, 'isHorizontal': true},
          },
          blackCells: {'1,2', '2,1', '3,3'},
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.blueToken,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.blueToken,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Takes 2 cells horizontally'),
          ],
        ),
      ],
    );
  }
  
  // Slide 3: Red Player - Show vertical tokens
  Widget _buildRedPlayerExample() {
    return Column(
      children: [
        Text(
          'Red Vertical Tokens (2 cells tall)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.redToken,
          ),
        ),
        const SizedBox(height: 16),
        _buildMiniBoard(
          size: 5,
          tokens: {
            '0,0': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,0': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,3': {'color': AppColors.redToken, 'isHorizontal': false},
            '2,3': {'color': AppColors.redToken, 'isHorizontal': false},
            '2,4': {'color': AppColors.redToken, 'isHorizontal': false},
            '3,4': {'color': AppColors.redToken, 'isHorizontal': false},
          },
          blackCells: {'1,2', '2,1', '3,3'},
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.redToken,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.redToken,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Text('Takes 2 cells vertically'),
          ],
        ),
      ],
    );
  }
  
  // Slide 4: Win Condition - Show full board
  Widget _buildWinConditionExample() {
    return Column(
      children: [
        Text(
          'Game in Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber[700],
          ),
        ),
        const SizedBox(height: 16),
        _buildMiniBoard(
          size: 5,
          tokens: {
            // Blue horizontal tokens
            '0,0': {'color': AppColors.blueToken, 'isHorizontal': true},
            '0,1': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,2': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,3': {'color': AppColors.blueToken, 'isHorizontal': true},
            '4,2': {'color': AppColors.blueToken, 'isHorizontal': true},
            '4,3': {'color': AppColors.blueToken, 'isHorizontal': true},
            // Red vertical tokens
            '0,3': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,3': {'color': AppColors.redToken, 'isHorizontal': false},
            '0,4': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,4': {'color': AppColors.redToken, 'isHorizontal': false},
            '3,0': {'color': AppColors.redToken, 'isHorizontal': false},
            '4,0': {'color': AppColors.redToken, 'isHorizontal': false},
          },
          blackCells: {'1,2', '2,1', '3,3'},
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Win Condition',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'The player who makes the last\nvalid move wins the game!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Helper method to build mini game board
  Widget _buildMiniBoard({
    required int size,
    required Map<String, Map<String, dynamic>> tokens,
    Set<String> blackCells = const {},
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 200,
        height: 200,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: size * size,
          itemBuilder: (context, index) {
            final row = index ~/ size;
            final col = index % size;
            final key = '$row,$col';
            final tokenData = tokens[key];
            final isBlack = blackCells.contains(key);
            
            // Determine cell color
            Color cellColor;
            if (isBlack) {
              cellColor = AppColors.blackCellDark;
            } else if (tokenData != null) {
              cellColor = tokenData['color'] as Color;
            } else {
              cellColor = Colors.white;
            }
            
            return Container(
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              ),
              child: null,
            );
          },
        ),
      ),
    );
  }
}

