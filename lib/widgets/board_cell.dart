import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

/// Widget for displaying a single board cell
class BoardCell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color cellColor;
    if (cell.isBlack) {
      // Checkerboard pattern for black cells
      cellColor = (cell.row + cell.col) % 2 == 0 
          ? AppColors.blackCellDark 
          : AppColors.blackCellLight;
    } else if (cell.isBlue) {
      cellColor = AppColors.blueToken;
    } else if (cell.isRed) {
      cellColor = AppColors.redToken;
    } else {
      cellColor = AppColors.regularCell(isDark);
    }
    
    return GestureDetector(
      onTap: cell.isAvailable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(AppSizes.tokenRadius),
          border: Border.all(
            color: isHighlighted 
                ? AppColors.hintBorder 
                : AppColors.boardBorder,
            width: isHighlighted ? 2 : AppSizes.cellBorderWidth,
          ),
        ),
        child: isHighlighted
            ? Center(
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.hintColor,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

