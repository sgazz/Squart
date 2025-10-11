import 'package:flutter/material.dart';
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
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                        Icon(
                          slide.icon,
                          size: 64,
                          color: slide.color,
                        ),
                        const SizedBox(height: 24),
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
          
          // Navigation
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                SizedBox(
                  width: 80,
                  child: _currentPage > 0
                      ? TextButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: const Text('Back'),
                        )
                      : null,
                ),
                
                // Page Indicator
                Text('${_currentPage + 1} / ${TutorialData.slides.length}'),
                
                // Next/Finish Button
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
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
                    child: Text(
                      _currentPage == TutorialData.slides.length - 1
                          ? 'Done'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          'Empty 4×4 Board',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildMiniBoard(
          size: 4,
          tokens: {},
        ),
        const SizedBox(height: 12),
        Text(
          'Players take turns placing tokens\nuntil one runs out of moves!',
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
          size: 4,
          tokens: {
            '0,0': {'color': AppColors.blueToken, 'isHorizontal': true},
            '0,1': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,1': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,2': {'color': AppColors.blueToken, 'isHorizontal': true},
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.blueToken,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.horizontal_rule, color: Colors.white, size: 16),
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
          size: 4,
          tokens: {
            '0,1': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,1': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,3': {'color': AppColors.redToken, 'isHorizontal': false},
            '2,3': {'color': AppColors.redToken, 'isHorizontal': false},
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.redToken,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
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
          size: 4,
          tokens: {
            // Blue horizontal tokens
            '0,0': {'color': AppColors.blueToken, 'isHorizontal': true},
            '0,1': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,0': {'color': AppColors.blueToken, 'isHorizontal': true},
            '2,1': {'color': AppColors.blueToken, 'isHorizontal': true},
            // Red vertical tokens
            '0,2': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,2': {'color': AppColors.redToken, 'isHorizontal': false},
            '1,3': {'color': AppColors.redToken, 'isHorizontal': false},
            '2,3': {'color': AppColors.redToken, 'isHorizontal': false},
          },
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
            
            return Container(
              decoration: BoxDecoration(
                color: tokenData != null 
                    ? tokenData['color'] as Color
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              ),
              child: tokenData != null
                  ? Icon(
                      tokenData['isHorizontal'] as bool
                          ? Icons.horizontal_rule
                          : Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}

