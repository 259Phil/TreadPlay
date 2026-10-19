import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/companion_cutouts.dart';

({Size size, Rect body}) _cutout(String artKey) =>
    companionCutouts[artKey] ?? companionCutouts['pebble']!;

String companionAsset(String artKey) => 'assets/companions/$artKey.png';

/// Places the cutout [artKey] so its creature fits into [maxWidth] ×
/// [maxHeight], centred on [centerX], feet on [groundY]. [image] is the rect
/// for the full image (with its transparent margin), [body] the creature.
({Rect image, Rect body}) companionPlacement({
  required String artKey,
  required double centerX,
  required double groundY,
  required double maxWidth,
  required double maxHeight,
}) {
  final c = _cutout(artKey);
  final scale = min(maxWidth / c.body.width, maxHeight / c.body.height);
  final left = centerX - c.body.center.dx * scale;
  final top = groundY - c.body.bottom * scale;
  return (
    image: Rect.fromLTWH(
      left,
      top,
      c.size.width * scale,
      c.size.height * scale,
    ),
    body: Rect.fromLTRB(
      left + c.body.left * scale,
      top + c.body.top * scale,
      left + c.body.right * scale,
      groundY,
    ),
  );
}

/// The creature of [artKey], trimmed to its body, as large as fits and
/// standing on the bottom edge.
class CompanionArt extends StatelessWidget {
  const CompanionArt(this.artKey, {super.key, this.imageKey});

  final String artKey;
  final Key? imageKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final place = companionPlacement(
          artKey: artKey,
          centerX: box.maxWidth / 2,
          groundY: box.maxHeight,
          maxWidth: box.maxWidth,
          maxHeight: box.maxHeight,
        );
        return ClipRect(
          child: SizedBox(
            width: box.maxWidth,
            height: box.maxHeight,
            child: Stack(
              children: [
                Positioned.fromRect(
                  rect: place.image,
                  child: Image.asset(
                    companionAsset(artKey),
                    key: imageKey,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
