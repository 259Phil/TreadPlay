import 'package:flutter/material.dart';

import '../theme.dart';

/// Painted Glut: the ember in its brass cradle. Up to 40 px the small
/// variant is used, cropped to the ember ring, so the pointed frame does
/// not read as a seal.
class GlutIcon extends StatelessWidget {
  const GlutIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => _StockArt(
    asset: size <= smallMax
        ? 'assets/icons/glut_small.webp'
        : 'assets/icons/glut.webp',
    size: size,
    fallback: Icons.local_fire_department,
    color: ForgeColors.ember,
  );

  static const double smallMax = 40;
}

/// Painted splinters: a seal broken into brass shards. Up to 40 px a
/// slightly brighter variant keeps the shards readable on dark plates.
class SplitterIcon extends StatelessWidget {
  const SplitterIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => _StockArt(
    asset: size <= GlutIcon.smallMax
        ? 'assets/icons/splitter_small.webp'
        : 'assets/icons/splitter.webp',
    size: size,
    fallback: Icons.scatter_plot,
    color: ForgeColors.muted,
  );
}

class _StockArt extends StatelessWidget {
  const _StockArt({
    required this.asset,
    required this.size,
    required this.fallback,
    required this.color,
  });

  final String asset;
  final double size;
  final IconData fallback;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => Icon(fallback, size: size * .8, color: color),
    ),
  );
}
