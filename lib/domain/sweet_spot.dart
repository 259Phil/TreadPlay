import 'dart:math';

import 'companion.dart';

/// Share of the range around the sweet spot that pays 100 %.
const double sweetSpotCoreShare = 0.4;

/// LP factor (0–1) for moving at [speedKmh] with a companion of [type].
///
/// 1.0 inside the core, smooth cosine falloff to 0 at the edge of the range.
/// [widenKmh] (from the recipe Ausdauer) moves the core and the edge out by
/// that much on each side.
double sweetSpotFactor(
  CompanionType type,
  double speedKmh, {
  double widenKmh = 0,
}) {
  final d = (speedKmh - type.sweetSpotKmh).abs();
  final range = type.rangeKmh + widenKmh;
  final core = type.rangeKmh * sweetSpotCoreShare + widenKmh;
  if (d <= core) return 1;
  if (d >= range) return 0;
  final t = (d - core) / (range - core);
  return 0.5 * (1 + cos(pi * t));
}
