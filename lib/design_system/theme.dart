import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens/colors.dart';
import 'tokens/typography.dart';
import 'tokens/spacing.dart';

class AppThemePremium {
  AppThemePremium._();

  static SystemUiOverlayStyle systemOverlay(bool isDark) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      textTheme: _textTheme(isDark),
      appBarTheme: _appBarTheme(isDark),
      cardTheme: _cardTheme(isDark),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(isDark, colorScheme),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(isDark),
      bottomNavigationBarTheme: _bottomNavTheme(isDark),
      navigationBarTheme: _navBarTheme(isDark),
      chipTheme: _chipTheme(isDark, colorScheme),
      floatingActionButtonTheme: _fabTheme(colorScheme),
      dividerTheme: _dividerTheme(isDark),
      dialogTheme: _dialogTheme(isDark),
      snackBarTheme: _snackBarTheme(isDark),
      drawerTheme: _drawerTheme(isDark),
      bottomSheetTheme: _bottomSheetTheme(isDark),
      tabBarTheme: _tabBarTheme(isDark, colorScheme),
      progressIndicatorTheme: _progressTheme(colorScheme),
    );

    return theme;
  }

  static ColorScheme get _darkColorScheme => ColorScheme.dark(
        primary: const Color(0xFF4895EF),
        secondary: const Color(0xFF7B61FF),
        tertiary: const Color(0xFF06D6A0),
        surface: AppColors.darkSurface,
        error: AppColors.accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textOnDark,
        onError: Colors.white,
        brightness: Brightness.dark,
      );

  static ColorScheme get _lightColorScheme => ColorScheme.light(
        primary: const Color(0xFF4895EF),
        secondary: const Color(0xFF7B61FF),
        tertiary: const Color(0xFF06D6A0),
        surface: AppColors.lightBackground,
        error: AppColors.accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      );

  static TextTheme _textTheme(bool isDark) => TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary,
        ),
      );

  static AppBarTheme _appBarTheme(bool isDark) => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor:
            isDark ? AppColors.textOnDark : AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      );

  static CardThemeData _cardTheme(bool isDark) => CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
          side: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        textStyle: AppTypography.button,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(
      bool isDark, ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        textStyle: AppTypography.button,
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4895EF),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? AppColors.darkSurfaceLight.withValues(alpha: 0.5)
          : AppColors.lightCard,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        borderSide: const BorderSide(
          color: Color(0xFF4895EF),
          width: 1.5,
        ),
      ),
      hintStyle: TextStyle(
        color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary,
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
      ),
      prefixIconColor: isDark
          ? AppColors.textOnDarkSecondary
          : AppColors.textSecondary,
      suffixIconColor: isDark
          ? AppColors.textOnDarkSecondary
          : AppColors.textSecondary,
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(bool isDark) {
    return BottomNavigationBarThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      selectedItemColor: const Color(0xFF4895EF),
      unselectedItemColor:
          isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      unselectedLabelStyle:
          const TextStyle(fontSize: 10, letterSpacing: 0.3),
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );
  }

  static NavigationBarThemeData _navBarTheme(bool isDark) {
    return NavigationBarThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      indicatorColor: const Color(0xFF4895EF).withValues(alpha: 0.15),
      surfaceTintColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 72,
    );
  }

  static ChipThemeData _chipTheme(bool isDark, ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurfaceLight : AppColors.lightCard,
      selectedColor: colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
    );
  }

  static FloatingActionButtonThemeData _fabTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
    );
  }

  static DividerThemeData _dividerTheme(bool isDark) {
    return DividerThemeData(
      color: isDark
          ? AppColors.darkBorder.withValues(alpha: 0.5)
          : AppColors.lightBorder,
      thickness: 0.5,
      space: 1,
    );
  }

  static DialogThemeData _dialogTheme(bool isDark) {
    return DialogThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(bool isDark) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      ),
      backgroundColor:
          isDark ? AppColors.darkSurfaceLight : AppColors.darkBackground,
    );
  }

  static DrawerThemeData _drawerTheme(bool isDark) {
    return DrawerThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
    );
  }

  static BottomSheetThemeData _bottomSheetTheme(bool isDark) {
    return BottomSheetThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.borderRadiusXl),
        ),
      ),
    );
  }

  static TabBarThemeData _tabBarTheme(bool isDark, ColorScheme colorScheme) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor:
          isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
    );
  }

  static ProgressIndicatorThemeData _progressTheme(ColorScheme colorScheme) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primary.withValues(alpha: 0.1),
    );
  }
}
