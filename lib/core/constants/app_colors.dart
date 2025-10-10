import 'package:flutter/material.dart';

/// App color palette for Squart game with Glassmorph design
class AppColors {
  AppColors._();

  // ========== Dark Theme (Primary) ==========
  
  // Background Gradients
  static const darkGradientStart = Color(0xFF1A1B3D); // Dark blue
  static const darkGradientEnd = Color(0xFF2D1B4E); // Purple
  
  // Glass Container
  static const darkGlassBackground = Color(0x1AFFFFFF); // white.withOpacity(0.1)
  static const darkGlassBorder = Color(0x33FFFFFF); // white.withOpacity(0.2)
  
  // ========== Light Theme ==========
  
  // Background Gradients
  static const lightGradientStart = Color(0xFFE3F2FD); // Light blue
  static const lightGradientEnd = Color(0xFFF3E5F5); // Lavender
  
  // Glass Container
  static const lightGlassBackground = Color(0xB3FFFFFF); // white.withOpacity(0.7)
  static const lightGlassBorder = Color(0x66FFFFFF); // white.withOpacity(0.4)
  
  // ========== Game Tokens ==========
  
  // Blue Player (Horizontal)
  static const blueToken = Color(0xFF4A90E2); // iOS system blue
  static const blueTokenLight = Color(0xFF64B5F6);
  static const blueTokenDark = Color(0xFF2196F3);
  
  // Red Player (Vertical)
  static const redToken = Color(0xFFE94B4B); // iOS system red
  static const redTokenLight = Color(0xFFEF5350);
  static const redTokenDark = Color(0xFFD32F2F);
  
  // ========== Board Colors ==========
  
  // Black Cells (Checkerboard pattern)
  static const blackCellDark = Color(0xFF424242); // Dark gray
  static const blackCellLight = Color(0xFF757575); // Light gray
  
  // Regular Cells
  static const regularCellDark = Color(0xFF37474F);
  static const regularCellLight = Color(0xFFFFFFFF);
  
  // Board Border
  static const boardBorder = Color(0x33FFFFFF);
  
  // ========== UI Elements ==========
  
  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF);
  static const textDisabled = Color(0x61FFFFFF);
  
  // Success/Error
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFFA726);
  
  // Timer Warning (last 10 seconds)
  static const timerWarning = Color(0xFFFF6B6B);
  
  // Hints (valid move indicators)
  static const hintColor = Color(0xFF81C784);
  static const hintBorder = Color(0xFF66BB6A);
  
  // ========== Shadow ==========
  
  static const shadowColor = Color(0x40000000); // black.withOpacity(0.25)
  
  // ========== Helper Methods ==========
  
  /// Returns gradient for background based on theme
  static LinearGradient backgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [darkGradientStart, darkGradientEnd]
          : [lightGradientStart, lightGradientEnd],
    );
  }
  
  /// Returns glass background color based on theme
  static Color glassBackground(bool isDark) {
    return isDark ? darkGlassBackground : lightGlassBackground;
  }
  
  /// Returns glass border color based on theme
  static Color glassBorder(bool isDark) {
    return isDark ? darkGlassBorder : lightGlassBorder;
  }
  
  /// Returns regular cell color based on theme
  static Color regularCell(bool isDark) {
    return isDark ? regularCellDark : regularCellLight;
  }
}

