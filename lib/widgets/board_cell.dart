import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import 'animated_token.dart';

/// Widget for displaying a single board cell with animations
class BoardCell extends StatefulWidget {
  final Cell cell;
  final double size;
  final bool isHighlighted;
  final VoidCallback? onTap;
  
  const BoardCell({
    super.key,
    required this.cell,
    required this.size,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppSizes.animationFast),
    );
    
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color cellColor;
    if (widget.cell.isBlack) {
      // All black cells are the same dark gray color (no checkerboard pattern)
      cellColor = AppColors.blackCellDark;
    } else if (widget.cell.isBlue || widget.cell.isRed) {
      // Show animated token
      return AnimatedToken(
        player: widget.cell.occupiedBy!,
        orientation: '', // Not used for display
        size: widget.size,
      );
    } else {
      cellColor = AppColors.regularCell(isDark);
    }
    
    return MouseRegion(
      onEnter: (_) {
        if (widget.cell.isAvailable) {
          setState(() => _isHovering = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: GestureDetector(
              onTap: widget.cell.isAvailable ? widget.onTap : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: AppSizes.animationFast),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(AppSizes.tokenRadius),
                  border: Border.all(
                    color: widget.isHighlighted 
                        ? AppColors.hintBorder 
                        : AppColors.boardBorder,
                    width: widget.isHighlighted ? 2 : AppSizes.cellBorderWidth,
                  ),
                  boxShadow: _isHovering && widget.cell.isAvailable
                      ? [
                          BoxShadow(
                            color: AppColors.blueToken.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: widget.isHighlighted
                    ? Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: AppSizes.animationNormal),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: widget.size * 0.3,
                                height: widget.size * 0.3,
                                decoration: BoxDecoration(
                                  color: AppColors.hintColor.withValues(alpha: 0.6 + (0.4 * value)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

