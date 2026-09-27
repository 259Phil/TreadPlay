import 'dart:math';
import 'dart:ui';

import '../domain/boot_footprint.dart';

/// Where to draw a square boot image so its sole rests on [soleY] and the
/// visible boot is centred on [centerX].
class BootPlacement {
  factory BootPlacement.seat({
    required String modelId,
    required double centerX,
    required double soleY,
    required double maxImageSize,
    required double maxBootHeight,
  }) {
    final fp = bootFootprints[modelId] ?? defaultBootFootprint;
    final size = min(maxImageSize, maxBootHeight / fp.height);
    final image = Rect.fromLTWH(
      centerX - fp.center.dx * size,
      soleY - fp.bottom * size,
      size,
      size,
    );
    final boot = Rect.fromLTRB(
      image.left + fp.left * size,
      image.top + fp.top * size,
      image.left + fp.right * size,
      soleY,
    );
    return BootPlacement._(image, boot);
  }

  const BootPlacement._(this.image, this.boot);

  /// Square area for the full image, including transparent padding.
  final Rect image;

  /// Opaque boot bounds in the same coordinates.
  final Rect boot;
}
