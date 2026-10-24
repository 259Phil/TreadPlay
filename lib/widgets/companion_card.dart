import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../domain/world.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../ui/skin.dart';
import 'companion_figure.dart';
import 'format.dart';

/// Collectible card: dark trading-card frame with brass corners, a brass
/// name plate under the art, a tempo coin and rarity pips. The image is
/// only the creature on transparency; everything else is drawn here.
class CompanionCard extends StatelessWidget {
  const CompanionCard({
    super.key,
    required this.artKey,
    required this.world,
    required this.rarity,
    required this.name,
    required this.subtitle,
    this.badge,
    this.onTap,
    this.stats,
    this.action,
    this.type,
  });

  final String artKey;
  final World world;
  final Rarity rarity;
  final String name;
  final String subtitle;

  /// Small brass tag in the top left corner, e.g. "Along". On narrow cards
  /// the rarity tag wraps below it instead of overlapping.
  final String? badge;
  final VoidCallback? onTap;

  /// Label and value pairs shown in a row under the subtitle.
  final List<(String, String)>? stats;

  /// Text on the brass pill at the bottom of the card, e.g. the price.
  final String? action;

  /// Gait of the companion; shown as a brass coin with 1–3 arrows and a
  /// tag with its name and sweet spot on the art.
  final CompanionType? type;

  static const double aspectRatio = 0.72;

  /// Two-column card grid used by Gehege and Market; taller cards when they
  /// carry an [action] pill.
  static SliverGridDelegate grid({bool withAction = false}) =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: withAction ? 0.5 : 0.58,
      );

  @override
  Widget build(BuildContext context) => _FrameCard(this);
}

/// Colour of the rarity pips and rarity word.
Color rarityJewel(Rarity r) => switch (r) {
  Rarity.common => const Color(0xFFB9B1A2),
  Rarity.rare => const Color(0xFF3F7FD0),
  Rarity.epic => const Color(0xFF9A52D2),
  Rarity.legendary => const Color(0xFFE6A434),
};

/// Rim and label colour of each gait.
Color tempoColor(CompanionType t) => switch (t) {
  CompanionType.moss => const Color(0xFF7FA650),
  CompanionType.brook => const Color(0xFF3FA39A),
  CompanionType.gale => const Color(0xFFD0703A),
};

Widget _scene(CompanionCard c) {
  final bg = c.world.background;
  final back = bg == null
      ? ColoredBox(color: c.world.placeholder)
      : Image.asset(
          bg,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          color: const Color(0x40000000),
          colorBlendMode: BlendMode.darken,
        );
  return Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Color(0xFF1E140F)),
      back,
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0x77000000)],
            stops: [0.55, 1],
          ),
        ),
      ),
    ],
  );
}

/// Height of the brass name plate and its gap to the bottom of the art.
const double _plateH = 26;
const double _plateBottom = 5;

/// The art gets its own window: below the tempo coin and badge, above
/// the name plate, so no creature hides behind either.
const EdgeInsets cardArtWindow = EdgeInsets.fromLTRB(
  6,
  34,
  6,
  _plateBottom + _plateH + 3,
);

Widget _stats(List<(String, String)> s, Color label, Color value) => Row(
  children: [
    for (final (l, v) in s)
      Expanded(
        child: Column(
          children: [
            Text(
              l,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(color: label, fontSize: 10),
            ),
            Text(
              v,
              style: TextStyle(
                color: value,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
  ],
);

Widget _pill(String text, {required BoxDecoration deco, required Color ink}) =>
    DecoratedBox(
      decoration: deco,
      child: SizedBox(
        height: 34,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ink,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );

class _Tag extends StatelessWidget {
  const _Tag(this.text, {required this.bg, required this.ink});

  final String text;
  final Color bg;
  final Color ink;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: ink,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

Widget _tap(CompanionCard c, Widget child) => Semantics(
  button: c.onTap != null,
  label: c.name,
  child: GestureDetector(onTap: c.onTap, child: child),
);

class _FrameCard extends StatelessWidget {
  const _FrameCard(this.c);
  final CompanionCard c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final skin = TreadSkin.of(context);
    final metal = rarityJewel(c.rarity);
    final s = c.stats;
    final a = c.action;
    return _tap(
      c,
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: brassGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            const BoxShadow(
              color: Color(0xAA000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
            if (c.rarity == Rarity.legendary)
              BoxShadow(color: metal.withValues(alpha: .4), blurRadius: 14),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF15100C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomPaint(
              foregroundPainter: _CornerPainter(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 7, 7, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              position: DecorationPosition.foreground,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0x99D2B074),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: _scene(c),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: cardArtWindow,
                              child: CompanionArt(
                                c.artKey,
                                imageKey: ValueKey('card-art-${c.artKey}'),
                              ),
                            ),
                          ),
                          if (c.type case final t?)
                            Positioned(
                              left: 5,
                              top: 5,
                              // Leaves room for the badge on the right.
                              right: c.badge == null ? 5 : 64,
                              child: Row(
                                children: [
                                  _TempoCoin(t),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: _TempoTag(
                                        key: const Key('card-tempo'),
                                        label: typeLabel(l, t).toUpperCase(),
                                        speed: l.kmhValue(
                                          formatNumber(context, t.sweetSpotKmh),
                                        ),
                                        color: tempoColor(t),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (c.badge case final b?)
                            Positioned(
                              right: 5,
                              top: 7,
                              child: _Tag(
                                b,
                                bg: TreadColors.brass,
                                ink: const Color(0xFF1A110B),
                              ),
                            ),
                          Positioned(
                            left: 4,
                            right: 4,
                            bottom: _plateBottom,
                            height: _plateH,
                            child: _NamePlate(
                              key: const Key('card-plate'),
                              name: c.name,
                              style: skin.display(
                                15.5,
                                color: const Color(0xFF2A1A0E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (var i = 0; i <= c.rarity.index; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Transform.rotate(
                              angle: math.pi / 4,
                              child: Container(
                                width: 5.5,
                                height: 5.5,
                                decoration: BoxDecoration(
                                  color: metal,
                                  border: Border.all(
                                    color: const Color(0xFF15100C),
                                    width: .5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          rarityLabel(l, c.rarity).toUpperCase(),
                          style: TextStyle(
                            color: metal,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            c.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: TreadColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (s != null) ...[
                      const SizedBox(height: 6),
                      _stats(s, TreadColors.muted, const Color(0xFFF2DCA8)),
                    ],
                    if (a != null) ...[
                      const SizedBox(height: 8),
                      _pill(
                        a,
                        deco: BoxDecoration(
                          color: const Color(0xFF2A1D15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: TreadColors.brass),
                        ),
                        ink: const Color(0xFFF2DCA8),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NamePlate extends StatelessWidget {
  const _NamePlate({super.key, required this.name, required this.style});
  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: brassGradient,
      borderRadius: BorderRadius.all(Radius.circular(4)),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFF6E5030))),
      boxShadow: [
        BoxShadow(
          color: Color(0xAA000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: style.copyWith(
              shadows: const [
                Shadow(color: Color(0x99FFF0C8), offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _TempoCoin extends StatelessWidget {
  const _TempoCoin(this.type);
  final CompanionType type;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('tempo-coin-${type.name}'),
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(
        center: Alignment(-.3, -.4),
        colors: [Color(0xFFF0D598), Color(0xFFC4A36A), Color(0xFF7E6038)],
      ),
      border: Border.all(color: tempoColor(type), width: 2),
      boxShadow: const [
        BoxShadow(color: Color(0xFF4A3420), spreadRadius: 1),
        BoxShadow(color: Color(0xAA000000), blurRadius: 3),
      ],
    ),
    child: CustomPaint(painter: _ArrowsPainter(type.arrows)),
  );
}

/// 1–3 dark chevrons, centred on the coin.
class _ArrowsPainter extends CustomPainter {
  _ArrowsPainter(this.count);
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF2A1A0E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const w = 4.0, h = 8.0, gap = 4.0;
    final total = w + gap * (count - 1);
    final x0 = (size.width - total) / 2;
    final cy = size.height / 2;
    for (var i = 0; i < count; i++) {
      final x = x0 + gap * i;
      canvas.drawPath(
        Path()
          ..moveTo(x, cy - h / 2)
          ..lineTo(x + w, cy)
          ..lineTo(x, cy + h / 2),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_ArrowsPainter old) => old.count != count;
}

/// Dark tag next to the coin: gait name in its colour, then the sweet spot.
class _TempoTag extends StatelessWidget {
  const _TempoTag({
    super.key,
    required this.label,
    required this.speed,
    required this.color,
  });

  final String label;
  final String speed;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xCC1A110B),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
            TextSpan(text: ' $speed'),
          ],
        ),
        maxLines: 1,
        style: const TextStyle(
          color: Color(0xFFF2DCA8),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: .3,
        ),
      ),
    ),
  );
}

/// Small brass corner brackets on the dark frame.
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFD2B074)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const d = 3.0, k = 12.0;
    for (final (x, y, sx, sy) in [
      (d, d, 1.0, 1.0),
      (size.width - d, d, -1.0, 1.0),
      (d, size.height - d, 1.0, -1.0),
      (size.width - d, size.height - d, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y + k * sy)
          ..lineTo(x, y)
          ..lineTo(x + k * sx, y),
        p,
      );
      canvas.drawCircle(
        Offset(x + 4 * sx, y + 4 * sy),
        1.3,
        Paint()..color = const Color(0xFFD2B074),
      );
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
