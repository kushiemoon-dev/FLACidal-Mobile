import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color constants matching the FLACidal desktop app.
class FlacColors {
  FlacColors._();

  // Dark theme
  static const bgVoid = Color(0xFF050505);
  static const bgPrimary = Color(0xFF0A0A0A);
  static const bgSecondary = Color(0xFF111111);
  static const bgTertiary = Color(0xFF1A1A1A);
  static const bgElevated = Color(0xFF222222);
  static const bgHover = Color(0xFF2A2A2A);
  static const accent = Color(0xFFF472B6);
  static const accentHover = Color(0xFFF9A8D4);
  static const accentSubtle = Color(0x26F472B6);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1A1);
  static const textTertiary = Color(0xFF666666);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  static const border = Color(0xFF1A1A1A);

  // Light theme
  static const lightBgPrimary = Color(0xFFFFFFFF);
  static const lightBgSecondary = Color(0xFFF5F5F5);
  static const lightBgTertiary = Color(0xFFE5E5E5);
  static const lightBgElevated = Color(0xFFD4D4D4);
  static const lightTextPrimary = Color(0xFF171517);
  static const lightTextSecondary = Color(0xFF666666);
  static const lightAccent = Color(0xFFDB2777);
}

/// Theme builder that produces ThemeData matching the desktop app aesthetic.
class FlacTheme {
  FlacTheme._();

  static ThemeData dark({Color? accentColor}) {
    final ac = accentColor ?? FlacColors.accent;
    final textTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: textTheme.apply(
        bodyColor: FlacColors.textPrimary,
        displayColor: FlacColors.textPrimary,
      ),
      colorScheme: ColorScheme.dark(
        surface: FlacColors.bgPrimary,
        surfaceContainerLowest: FlacColors.bgVoid,
        surfaceContainerLow: FlacColors.bgSecondary,
        surfaceContainer: FlacColors.bgTertiary,
        surfaceContainerHigh: FlacColors.bgElevated,
        surfaceContainerHighest: FlacColors.bgHover,
        primary: ac,
        onPrimary: FlacColors.bgVoid,
        onSurface: FlacColors.textPrimary,
        onSurfaceVariant: FlacColors.textSecondary,
        outline: FlacColors.textTertiary,
        error: FlacColors.error,
      ),
      cardTheme: CardThemeData(
        color: FlacColors.bgTertiary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ac,
          foregroundColor: FlacColors.bgVoid,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ac),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: FlacColors.bgElevated),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlacColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FlacColors.bgElevated),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FlacColors.bgElevated),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ac),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FlacColors.bgPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: FlacColors.textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FlacColors.bgPrimary,
        indicatorColor: FlacColors.accentSubtle,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: ac);
          }
          return const IconThemeData(color: FlacColors.textTertiary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: ac, fontSize: 12);
          }
          return const TextStyle(color: FlacColors.textTertiary, fontSize: 12);
        }),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FlacColors.bgSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FlacColors.bgSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FlacColors.bgTertiary,
        selectedColor: FlacColors.accentSubtle,
        side: const BorderSide(color: FlacColors.bgElevated),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ac;
          return FlacColors.bgElevated;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return FlacColors.accentSubtle;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return ac;
            return FlacColors.textSecondary;
          }),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ac,
        linearTrackColor: FlacColors.bgElevated,
        circularTrackColor: FlacColors.bgElevated,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: FlacColors.bgElevated,
        contentTextStyle: TextStyle(color: FlacColors.textPrimary),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: FlacColors.bgSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: FlacColors.bgTertiary),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(FlacColors.bgHover),
        thickness: WidgetStateProperty.all(4),
        radius: const Radius.circular(2),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: ac,
        labelColor: ac,
        unselectedLabelColor: FlacColors.textTertiary,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData light({Color? accentColor}) {
    final ac = accentColor ?? FlacColors.lightAccent;
    final textTheme = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: textTheme.apply(
        bodyColor: FlacColors.lightTextPrimary,
        displayColor: FlacColors.lightTextPrimary,
      ),
      colorScheme: ColorScheme.light(
        surface: FlacColors.lightBgPrimary,
        surfaceContainerLowest: FlacColors.lightBgPrimary,
        surfaceContainerLow: FlacColors.lightBgSecondary,
        surfaceContainer: FlacColors.lightBgTertiary,
        surfaceContainerHigh: FlacColors.lightBgElevated,
        surfaceContainerHighest: FlacColors.lightBgElevated,
        primary: ac,
        onPrimary: FlacColors.lightBgPrimary,
        onSurface: FlacColors.lightTextPrimary,
        onSurfaceVariant: FlacColors.lightTextSecondary,
        outline: FlacColors.lightTextSecondary,
        error: FlacColors.error,
      ),
      cardTheme: CardThemeData(
        color: FlacColors.lightBgSecondary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ac,
          foregroundColor: FlacColors.lightBgPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ac),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: FlacColors.lightBgElevated),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlacColors.lightBgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FlacColors.lightBgElevated),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FlacColors.lightBgElevated),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ac),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FlacColors.lightBgPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: FlacColors.lightTextPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FlacColors.lightBgPrimary,
        indicatorColor: ac.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: ac);
          }
          return const IconThemeData(color: FlacColors.lightTextSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: ac, fontSize: 12);
          }
          return const TextStyle(
            color: FlacColors.lightTextSecondary,
            fontSize: 12,
          );
        }),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FlacColors.lightBgSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FlacColors.lightBgSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FlacColors.lightBgTertiary,
        selectedColor: ac.withValues(alpha: 0.15),
        side: const BorderSide(color: FlacColors.lightBgElevated),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ac;
          return FlacColors.lightBgElevated;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ac.withValues(alpha: 0.15);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return ac;
            return FlacColors.lightTextSecondary;
          }),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ac,
        linearTrackColor: FlacColors.lightBgElevated,
        circularTrackColor: FlacColors.lightBgElevated,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: FlacColors.lightBgElevated,
        contentTextStyle: TextStyle(color: FlacColors.lightTextPrimary),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: FlacColors.lightBgSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: FlacColors.lightBgTertiary),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(FlacColors.lightBgElevated),
        thickness: WidgetStateProperty.all(4),
        radius: const Radius.circular(2),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: ac,
        labelColor: ac,
        unselectedLabelColor: FlacColors.lightTextSecondary,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
