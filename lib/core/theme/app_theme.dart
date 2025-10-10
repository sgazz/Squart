import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// App theme configuration for Squart game
class AppTheme {
  AppTheme._();

  // ========== Dark Theme (Primary) ==========
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.blueToken,
        secondary: AppColors.redToken,
        surface: AppColors.darkGlassBackground,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: Colors.transparent,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: AppSizes.iconM,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: AppColors.darkGlassBackground,
        elevation: AppSizes.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: const BorderSide(
            color: AppColors.darkGlassBorder,
            width: AppSizes.glassBorderWidth,
          ),
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueToken,
          foregroundColor: AppColors.textPrimary,
          elevation: AppSizes.elevationLow,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueToken,
          textStyle: const TextStyle(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blueToken,
          side: const BorderSide(color: AppColors.blueToken),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppSizes.textTitle,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppSizes.textXXL,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppSizes.textL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: AppSizes.textM,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.textM,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.textS,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: AppSizes.textXS,
          color: AppColors.textSecondary,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppSizes.iconM,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkGlassBorder,
        thickness: 1,
        space: AppSizes.spaceM,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.blueToken;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.blueToken.withValues(alpha: 0.5);
          }
          return AppColors.darkGlassBackground;
        }),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkGradientStart,
        elevation: AppSizes.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: const BorderSide(
            color: AppColors.darkGlassBorder,
            width: AppSizes.glassBorderWidth,
          ),
        ),
      ),
    );
  }
  
  // ========== Light Theme ==========
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.blueToken,
        secondary: AppColors.redToken,
        surface: AppColors.lightGlassBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: Colors.transparent,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: Colors.black87,
          size: AppSizes.iconM,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: AppColors.lightGlassBackground,
        elevation: AppSizes.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: const BorderSide(
            color: AppColors.lightGlassBorder,
            width: AppSizes.glassBorderWidth,
          ),
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueToken,
          foregroundColor: Colors.white,
          elevation: AppSizes.elevationLow,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueToken,
          textStyle: const TextStyle(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blueToken,
          side: const BorderSide(color: AppColors.blueToken),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppSizes.textTitle,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: AppSizes.textXXL,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displaySmall: TextStyle(
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineLarge: TextStyle(
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: AppSizes.textL,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: AppSizes.textM,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.textM,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.textS,
          color: Colors.black54,
        ),
        bodySmall: TextStyle(
          fontSize: AppSizes.textXS,
          color: Colors.black54,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.black87,
        size: AppSizes.iconM,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGlassBorder,
        thickness: 1,
        space: AppSizes.spaceM,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.blueToken;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.blueToken.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightGradientStart,
        elevation: AppSizes.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: const BorderSide(
            color: AppColors.lightGlassBorder,
            width: AppSizes.glassBorderWidth,
          ),
        ),
      ),
    );
  }
}

