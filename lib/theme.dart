import 'package:flutter/material.dart';

import 'domain/companion.dart';

/// Metal UI palette (V1.2 §5): dark iron, brass accents, no pastel surfaces.
class TreadColors {
  static const iron = Color(0xFF1A1D22);
  static const plate = Color(0xFF2A3038);
  static const rail = Color(0xFF12141A);
  static const text = Color(0xFFE8E0D0);
  static const muted = Color(0xFF9C968C);
  static const brass = Color(0xFFC4A36A);
  static const brassDark = Color(0xFF7A6238);
  static const copper = Color(0xFFB0703F);
  static const steel = Color(0xFF7D858E);
  static const stop = Color(0xFF8B3A3A);
  static const breath = Color(0xFF6FB7C4);
}

/// Frame metal per rarity: iron, brass, copper, brass with glow.
Color rarityMetal(Rarity rarity) => switch (rarity) {
  Rarity.common => TreadColors.steel,
  Rarity.rare => TreadColors.brass,
  Rarity.epic => TreadColors.copper,
  Rarity.legendary => const Color(0xFFE2C487),
};

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: TreadColors.brass,
        brightness: Brightness.dark,
      ).copyWith(
        primary: TreadColors.brass,
        onPrimary: TreadColors.iron,
        secondary: TreadColors.steel,
        surface: TreadColors.iron,
        onSurface: TreadColors.text,
        surfaceContainerHighest: TreadColors.plate,
        surfaceContainer: TreadColors.plate,
        outline: TreadColors.brassDark,
        error: TreadColors.stop,
        onError: TreadColors.text,
      );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: TreadColors.iron,
    textTheme: base.textTheme.apply(
      bodyColor: TreadColors.text,
      displayColor: TreadColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: TreadColors.rail,
      foregroundColor: TreadColors.text,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      shape: Border(bottom: BorderSide(color: TreadColors.brassDark)),
    ),
    cardTheme: const CardThemeData(
      color: TreadColors.plate,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: Color(0xFF3A424C)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: TreadColors.rail,
      surfaceTintColor: Colors.transparent,
      indicatorColor: TreadColors.brass.withValues(alpha: 0.22),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? TreadColors.brass
              : TreadColors.muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          color: s.contains(WidgetState.selected)
              ? TreadColors.brass
              : TreadColors.muted,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: TreadColors.brass,
        foregroundColor: TreadColors.iron,
        disabledBackgroundColor: TreadColors.plate,
        disabledForegroundColor: TreadColors.muted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TreadColors.brass,
        side: const BorderSide(color: TreadColors.brassDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF3A424C)),
    sliderTheme: const SliderThemeData(
      activeTrackColor: TreadColors.brass,
      thumbColor: TreadColors.brass,
      inactiveTrackColor: TreadColors.plate,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? TreadColors.iron
            : TreadColors.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? TreadColors.brass
            : TreadColors.plate,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: TreadColors.brass.withValues(alpha: 0.25),
        selectedForegroundColor: TreadColors.brass,
        foregroundColor: TreadColors.text,
        side: const BorderSide(color: TreadColors.brassDark),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: TreadColors.iron,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
