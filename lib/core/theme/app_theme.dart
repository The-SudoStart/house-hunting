import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Provides the global [ThemeData] for the House Finder application.
///
/// Use [AppTheme.lightTheme] and [AppTheme.darkTheme] to configure the
/// [MaterialApp.theme] and [MaterialApp.darkTheme] properties.
abstract final class AppTheme {
  static const double _buttonBorderRadius = 12.0;
  static const double _cardBorderRadius = 16.0;
  static const double _inputBorderRadius = 8.0;

  static final ThemeData lightTheme = _buildTheme(Brightness.light);
  static final ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: isDark ? AppColors.darkSurface : AppColors.surface,
      surfaceContainerHighest:
          isDark ? AppColors.darkSurface : AppColors.background,
      onSurface: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
      onSurfaceVariant:
          isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
      outline: isDark ? AppColors.darkOutline : AppColors.outline,
      error: AppColors.error,
      shadow: Colors.black.withValues(alpha: 0.1),
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
        ),
      ),
      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
        ),
      ),
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
        ),
      ),
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 2,
        selectedLabelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
      ),
      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelLarge,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        dividerColor: colorScheme.outline.withValues(alpha: 0.5),
      ),
      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        titleTextStyle: AppTypography.bodyLarge,
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
      ),
    );
  }
}
