import 'package:flutter/material.dart';

class TreadColors {
  static const gold = Color(0xFFD4A24C);
  static const night = Color(0xFF14110F);
  static const panel = Color(0xFF221D19);
  static const breath = Color(0xFF7FC8D8);
}

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: TreadColors.gold,
        brightness: Brightness.dark,
      ).copyWith(
        primary: TreadColors.gold,
        onPrimary: Colors.black,
        surface: TreadColors.night,
      );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: TreadColors.night,
    cardTheme: const CardThemeData(color: TreadColors.panel),
    useMaterial3: true,
  );
}
