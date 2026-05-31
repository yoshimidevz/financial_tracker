import 'package:flutter/material.dart';

// ── Clean Blue & White Palette ────────────────────────────────────────────────
class AppColors {
  // Primaries
  static const Color blue900 = Color(0xFF0A2540);   // deep navy
  static const Color blue700 = Color(0xFF1A56DB);   // brand blue
  static const Color blue500 = Color(0xFF3B82F6);   // mid blue
  static const Color blue200 = Color(0xFFBFDBFE);   // light blue tint
  static const Color blue50  = Color(0xFFEFF6FF);   // near-white blue tint

  // Neutrals
  static const Color white   = Color(0xFFFFFFFF);
  static const Color grey50  = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey800 = Color(0xFF1E293B);

  // Semantic (keep minimal — blue-scale as much as possible)
  static const Color income  = Color(0xFF1A56DB);   // blue for income
  static const Color expense = Color(0xFF64748B);   // slate for expense
  static const Color positive = Color(0xFF22C55E);  // balance positive
  static const Color negative = Color(0xFFEF4444);  // balance negative
}

// ── Light Theme ───────────────────────────────────────────────────────────────
final ThemeData appLightTheme = _buildTheme(Brightness.light);
final ThemeData appDarkTheme  = _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final ColorScheme colorScheme = ColorScheme(
    brightness: brightness,
    primary:          AppColors.blue700,
    onPrimary:        AppColors.white,
    primaryContainer: AppColors.blue50,
    onPrimaryContainer: AppColors.blue900,
    secondary:        AppColors.expense,
    onSecondary:      AppColors.white,
    secondaryContainer: AppColors.grey100,
    onSecondaryContainer: AppColors.grey800,
    tertiary:         AppColors.grey400,
    onTertiary:       AppColors.white,
    error:            AppColors.negative,
    onError:          AppColors.white,
    surface:          isDark ? AppColors.grey800 : AppColors.white,
    onSurface:        isDark ? AppColors.grey100 : AppColors.grey800,
    surfaceContainerHighest: isDark ? const Color(0xFF2A3A50) : AppColors.grey100,
    outline:          isDark ? const Color(0xFF3A5070) : AppColors.grey200,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark ? AppColors.grey800 : AppColors.grey50,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? AppColors.grey800 : AppColors.white,
      foregroundColor: isDark ? AppColors.white : AppColors.grey800,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Geist',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: isDark ? AppColors.white : AppColors.grey800,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1E2D40) : AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue700,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue700,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? const Color(0xFF2A3A50) : AppColors.grey100,
      selectedColor: AppColors.blue700,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),

    // Tabs
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.blue700,
      unselectedLabelColor: AppColors.grey400,
      indicatorColor: AppColors.blue700,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E2D40) : AppColors.grey50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blue700, width: 1.5),
      ),
      labelStyle: TextStyle(color: isDark ? AppColors.grey400 : AppColors.grey600, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Text
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: isDark ? AppColors.white : AppColors.grey800, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: isDark ? AppColors.white : AppColors.grey800, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleLarge: TextStyle(color: isDark ? AppColors.white : AppColors.grey800, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium: TextStyle(color: isDark ? AppColors.white : AppColors.grey800, fontWeight: FontWeight.w600, fontSize: 15),
      titleSmall: TextStyle(color: isDark ? AppColors.grey100 : AppColors.grey800, fontWeight: FontWeight.w600, fontSize: 13),
      bodyLarge: TextStyle(color: isDark ? AppColors.grey200 : AppColors.grey600, fontSize: 15),
      bodyMedium: TextStyle(color: isDark ? AppColors.grey400 : AppColors.grey600, fontSize: 13),
      bodySmall: TextStyle(color: isDark ? AppColors.grey400 : AppColors.grey400, fontSize: 11),
      labelLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: isDark ? AppColors.grey400 : AppColors.grey600, fontSize: 11, fontWeight: FontWeight.w500),
    ),

    dividerTheme: DividerThemeData(
      color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200,
      thickness: 1,
      space: 1,
    ),
  );
}