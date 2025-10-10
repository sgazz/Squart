import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../models/tutorial_slide.dart';
import '../widgets/glass_container.dart';

/// Tutorial screen with interactive slides
class TutorialScreen extends StatefulWidget {
  final bool showSkipButton;
  
  const TutorialScreen({
    super.key,
    this.showSkipButton = true,
  });

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
  
  void _nextPage() {
    if (_currentPage < TutorialData.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _finishTutorial() {
    Navigator.of(context).pop();
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
          title: const Text('How to Play'),
          leading: widget.showSkipButton
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _finishTutorial,
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
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
                    return _buildSlide(
                      context,
                      TutorialData.slides[index],
                      index,
                    );
                  },
                ),
              ),
              
              // Navigation Controls
              Padding(
                padding: const EdgeInsets.all(AppSizes.spaceL),
                child: Column(
                  children: [
                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        TutorialData.slides.length,
                        (index) => _buildPageIndicator(index),
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.spaceL),
                    
                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Button
                        if (_currentPage > 0)
                          TextButton.icon(
                            onPressed: _previousPage,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                          )
                        else
                          const SizedBox(width: 100),
                        
                        // Next/Finish Button
                        ElevatedButton.icon(
                          onPressed: _nextPage,
                          icon: Icon(
                            _currentPage == TutorialData.slides.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            _currentPage == TutorialData.slides.length - 1
                                ? 'Got it!'
                                : 'Next',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.spaceL,
                              vertical: AppSizes.spaceM,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSlide(BuildContext context, TutorialSlide slide, int index) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSizes.spaceXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: slide.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                slide.icon,
                size: 64,
                color: slide.color,
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            
            const SizedBox(height: AppSizes.spaceXL),
            
            // Title
            Text(
              slide.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: slide.color,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            const SizedBox(height: AppSizes.spaceL),
            
            // Description
            Text(
              slide.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),
            
            // Interactive Example (only on last slide)
            if (slide.hasInteractiveExample) ...[ 
              const SizedBox(height: AppSizes.spaceXL),
              _buildInteractiveExample(context),
            ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? TutorialData.slides[_currentPage].color
            : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  Widget _buildInteractiveExample(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      child: Column(
        children: [
          Text(
            'Interactive Example',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),
          
          // Simple 3x3 example board
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final row = index ~/ 3;
                  final col = index % 3;
                  
                  // Example pattern: show some tokens
                  Color? tokenColor;
                  IconData? tokenIcon;
                  
                  if (row == 0 && col == 1) {
                    // Blue horizontal token
                    tokenColor = AppColors.blueToken;
                    tokenIcon = Icons.horizontal_rule;
                  } else if (row == 1 && col == 0) {
                    // Red vertical token
                    tokenColor = AppColors.redToken;
                    tokenIcon = Icons.more_vert;
                  } else if (row == 1 && col == 1) {
                    // Black cell (blocked)
                    tokenColor = AppColors.blackCellDark;
                  }
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: tokenColor ?? AppColors.regularCellDark,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: tokenIcon != null
                        ? Icon(tokenIcon, color: Colors.white, size: 20)
                        : null,
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: AppSizes.spaceM),
          
          Text(
            'Tap cells to place tokens and block your opponent!',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 400.ms);
  }
}

