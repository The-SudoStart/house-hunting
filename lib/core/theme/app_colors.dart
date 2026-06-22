import 'package:flutter/material.dart';

/// Defines the color palette for the House Finder application.
///
/// All colors should be referenced through this class or the theme
/// to ensure visual consistency across the app.
abstract final class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF006D77);
  static const Color primaryLight = Color(0xFF83C5BE);
  static const Color primaryDark = Color(0xFF004C53);

  // Secondary palette
  static const Color secondary = Color(0xFFE29578);
  static const Color secondaryLight = Color(0xFFFFDDD2);
  static const Color secondaryDark = Color(0xFFB8705A);

  // Neutrals
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212529);
  static const Color onSurfaceVariant = Color(0xFF6C757D);
  static const Color outline = Color(0xFFDEE2E6);

  // Semantic
  static const Color error = Color(0xFFD62828);
  static const Color success = Color(0xFF2A9D8F);
  static const Color warning = Color(0xFFF4A261);
  static const Color info = Color(0xFF457B9D);

  // Dark theme variants
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFE9ECEF);
  static const Color darkOnSurfaceVariant = Color(0xFFADB5BD);
  static const Color darkOutline = Color(0xFF495057);
}
