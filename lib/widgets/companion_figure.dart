import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/companion_cutouts.dart';

({Size size, Rect body}) _cutout(String artKey) =>
    companionCutouts[artKey] ?? companionCutouts['pebble']!;

String companionAsset(String artKey) => 'assets/companions/$artKey.png';

/// Species of a cutout key: `brine-epic` → `brine`.
String _species(String artKey) => artKey.split('-').first;

/// Places the cutout [artKey] so its creature fits into [maxWidth] ×
/// [maxHeight], centred on [centerX], feet on [groundY]. [image] is the rect
/// for the full image (with its transparent margin), [body] the creature.
///
/// With [presence] set, the creature is sized by its visual mass instead of
/// filling the box: the Common cutout of its species gets a body whose
/// √(width × height) equals [presence], every rarity of that species uses the
/// same scale, and [maxWidth] / [maxHeight] only cap it. Squat and tall
/// species then read as the same size instead of the squat ones spanning the
/// whole width.
({Rect image, Rect body}) companionPlacement({
  required String artKey,
  required double centerX,
  required double groundY,
  required double maxWidth,
  required double maxHeight,
  double? presence,
}) {
  final c = _cutout(artKey);
  var scale = min(maxWidth / c.body.width, maxHeight / c.body.height);
  if (presence != null) {
    final ref = (companionCutouts[_species(artKey)] ?? c).body;
    scale = min(scale, presence / sqrt(ref.width * ref.height));
  }
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

/// The creature of [artKey], trimmed to its body, sized like the other
/// species (see [companionPlacement] `presence`) with a little side margin and
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
          maxWidth: box.maxWidth * 0.92,
          maxHeight: box.maxHeight,
          presence: min(box.maxWidth * 0.8, box.maxHeight * 0.82),
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
