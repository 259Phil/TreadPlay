import 'package:flutter/material.dart';

import 'domain/companion.dart';
import 'ui/skin.dart';

/// Metal UI palette (V1.2 §5): dark iron, brass accents, no pastel surfaces.
/// Style C builds ([kLeatherBuild]) get the warm leather tones instead.
class TreadColors {
  static const iron = kLeatherBuild ? Color(0xFF1E140F) : Color(0xFF0F0E0D);
  static const plate = kLeatherBuild ? Color(0xFF3A2A20) : Color(0xFF1F1C18);
  static const rail = kLeatherBuild ? Color(0xFF2A1D15) : Color(0xFF161411);
  static const text = kLeatherBuild ? Color(0xFFEDE4D3) : Color(0xFFF2EADC);
  static const muted = kLeatherBuild ? Color(0xFFBBAC95) : Color(0xFF9B9387);
  static const brass = kLeatherBuild ? Color(0xFFD2B074) : Color(0xFFDDB066);
  static const brassDark = Color(0xFF7A6238);
  static const copper = kLeatherBuild ? Color(0xFFD08A55) : Color(0xFFB0703F);
  static const bronze = Color(0xFF8E7046);
  static const steel = Color(0xFFA9B1BA);
  static const stop = Color(0xFF8B3A3A);
  static const breath = Color(0xFF6FB7C4);
}

/// Frame metal per rarity: steel, bronze, copper, brass (with glow).
Color rarityMetal(Rarity rarity) => switch (rarity) {
  Rarity.common => TreadColors.steel,
  Rarity.rare => TreadColors.bronze,
  Rarity.epic => TreadColors.copper,
  Rarity.legendary => TreadColors.brass,
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
  return applySkin(_baseTheme(base), TreadSkin.forStyle(buildStyle));
}

ThemeData _baseTheme(ThemeData base) {
  return base.copyWith(
    scaffoldBackgroundColor: TreadColors.iron,
    textTheme: base.textTheme.apply(
      bodyColor: TreadColors.text,
      displayColor: TreadColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: TreadColors.iron,
      foregroundColor: TreadColors.text,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      toolbarHeight: 64,
      titleTextStyle: TextStyle(
        fontFamily: 'serif',
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: TreadColors.text,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: TreadColors.plate,
      contentTextStyle: TextStyle(color: TreadColors.text, fontSize: 15),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: TreadColors.brassDark),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: TreadColors.plate,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: TreadColors.plate,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Color(0xFF332E27)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: TreadColors.rail,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
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
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TreadColors.brass,
        side: const BorderSide(color: TreadColors.brassDark),
        shape: const StadiumBorder(),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF2B2722)),
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

/// Serif display style for screen and companion titles.
const serifTitle = TextStyle(
  fontFamily: 'serif',
  fontWeight: FontWeight.w600,
  color: TreadColors.text,
);

/// Brushed brass for primary pills and the Start button.
const brassGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFF0CE8A), TreadColors.brass, Color(0xFFB98A44)],
  stops: [0, 0.5, 1],
);

/// Forge palette (V1.2 metal palette): cool iron base and surface, warm
/// text, brass and the stop red. No pastel, pink or white surfaces.
class ForgeColors {
  static const base = kLeatherBuild ? Color(0xFF241912) : Color(0xFF1A1D22);
  static const surface = kLeatherBuild ? Color(0xFF3A2A20) : Color(0xFF2A3038);
  static const raised = kLeatherBuild ? Color(0xFF47332A) : Color(0xFF323944);
  static const line = kLeatherBuild ? Color(0xFF5C4433) : Color(0xFF3B434E);
  static const text = kLeatherBuild ? Color(0xFFEDE4D3) : Color(0xFFE8E0D0);
  static const muted = kLeatherBuild ? Color(0xFFBBAC95) : Color(0xFF9AA1AA);
  static const brass = kLeatherBuild ? Color(0xFFD2B074) : Color(0xFFC4A36A);
  static const stop = Color(0xFF8B3A3A);
  static const ember = Color(0xFFD9692F);
}

/// Frame metal of a seal level: grey stone, bronze, brass, glowing copper,
/// brass with a red-hot core.
Color sealLevelMetal(int level) => switch (level) {
  <= 1 => const Color(0xFF7D838B),
  2 => const Color(0xFF9A7A4E),
  3 => ForgeColors.brass,
  4 => const Color(0xFFD08A45),
  _ => const Color(0xFFE0B872),
};
