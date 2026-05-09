import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        scaffoldBackground: AppColors.cream,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.forest,
          onPrimary: Colors.white,
          primaryContainer: AppColors.mint,
          onPrimaryContainer: AppColors.forest,
          secondary: AppColors.leaf,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.sage,
          onSecondaryContainer: AppColors.forest,
          tertiary: AppColors.sun,
          onTertiary: Colors.white,
          error: AppColors.ember,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.bark,
          onSurfaceVariant: Color(0xFF6B6760),
          surfaceContainerHighest: Color(0xFFEFEDE3),
          outline: Color(0xFFCFCBBE),
          outlineVariant: Color(0xFFE2DFD3),
        ),
        statusBarBrightness: Brightness.dark,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        scaffoldBackground: AppColors.nightBg,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF7CC18C),
          onPrimary: Color(0xFF0E1714),
          primaryContainer: Color(0xFF26433A),
          onPrimaryContainer: Color(0xFFC9E6CF),
          secondary: Color(0xFF8FBCA0),
          onSecondary: Color(0xFF0E1714),
          secondaryContainer: Color(0xFF223830),
          onSecondaryContainer: Color(0xFFCFE6D6),
          tertiary: AppColors.sun,
          onTertiary: Color(0xFF1A1108),
          error: Color(0xFFE89074),
          onError: Color(0xFF1A0904),
          surface: AppColors.nightSurface,
          onSurface: AppColors.nightTextPrimary,
          onSurfaceVariant: AppColors.nightTextSecondary,
          surfaceContainerHighest: AppColors.nightSurfaceElevated,
          outline: Color(0xFF40554A),
          outlineVariant: AppColors.nightBorder,
        ),
        statusBarBrightness: Brightness.light,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffoldBackground,
    required ColorScheme scheme,
    required Brightness statusBarBrightness,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return scheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.outlineVariant;
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        side: BorderSide.none,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle:
            textTheme.labelLarge?.copyWith(color: scheme.onPrimary),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      listTileTheme: ListTileThemeData(
        textColor: scheme.onSurface,
        iconColor: scheme.primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
    );
  }
}
