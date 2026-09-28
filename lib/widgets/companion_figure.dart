import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/companion_art.dart';

/// Size of a companion image that fits into [maxWidth] × [maxHeight].
Size companionFigureSize(String artKey, double maxWidth, double maxHeight) {
  final px = companionArt[artKey] ?? const Size(720, 540);
  final scale = min(maxWidth / px.width, maxHeight / px.height);
  return Size(px.width * scale, px.height * scale);
}

/// Distance from the bottom of a drawn image of [height] to the creature's
/// feet (the transparent border).
double companionFeetInset(String artKey, double height) {
  final px = companionArt[artKey] ?? const Size(720, 540);
  return companionArtBorder * height / px.height;
}

/// Places a companion so its feet stand on [groundY], centred on [centerX].
/// Returns the rect for the full image (including the transparent border).
Rect companionStandingRect({
  required String artKey,
  required double centerX,
  required double groundY,
  required double maxWidth,
  required double maxHeight,
}) {
  final size = companionFigureSize(artKey, maxWidth, maxHeight);
  final inset = companionFeetInset(artKey, size.height);
  return Rect.fromLTWH(
    centerX - size.width / 2,
    groundY - size.height + inset,
    size.width,
    size.height,
  );
}
