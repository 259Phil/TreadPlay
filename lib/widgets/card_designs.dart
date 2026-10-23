import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../ui/skin.dart';
import 'companion_card.dart';
import 'companion_figure.dart';
import 'format.dart';

/// Card design trial, chosen at build time with
/// `--dart-define=TREADPLAY_CARD=1|2|3`. 0 (default) keeps the current card.
/// Mockups only – not final.
const kCardDesign = int.fromEnvironment('TREADPLAY_CARD');

/// Builds [card] in the trial design [kCardDesign].
Widget cardDesign(CompanionCard card) => switch (kCardDesign) {
  1 => _LeatherCard(card),
  2 => _ParchmentCard(card),
  _ => _FrameCard(card),
};

/// Colour of the rarity jewel / wax / pips.
Color rarityJewel(Rarity r) => switch (r) {
  Rarity.common => const Color(0xFFB9B1A2),
  Rarity.rare => const Color(0xFF3F7FD0),
  Rarity.epic => const Color(0xFF9A52D2),
  Rarity.legendary => const Color(0xFFE6A434),
};

IconData elementIcon(CompanionType t) => switch (t) {
  CompanionType.moss => Icons.eco,
  CompanionType.brook => Icons.water_drop,
  CompanionType.gale => Icons.air,
};

Widget _scene(CompanionCard c, {bool sepia = false}) {
  final bg = c.world.background;
  Widget back = bg == null
      ? ColoredBox(color: c.world.placeholder)
      : Image.asset(
          bg,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          color: const Color(0x40000000),
          colorBlendMode: BlendMode.darken,
        );
  if (sepia) {
    back = ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.39, 0.77, 0.19, 0, 0, //
        0.35, 0.69, 0.17, 0, 0, //
        0.27, 0.53, 0.13, 0, 0, //
        0, 0, 0, 0.75, 0,
      ]),
      child: back,
    );
  }
  return Stack(
    fit: StackFit.expand,
    children: [
      ColoredBox(
        color: sepia ? const Color(0xFFD8C08E) : const Color(0xFF1E140F),
      ),
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
      Padding(
        padding: const EdgeInsets.fromLTRB(6, 22, 6, 4),
        child: CompanionArt(c.artKey),
      ),
    ],
  );
}

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
  const _Tag(this.text, {required this.bg, required this.ink, this.border});

  final String text;
  final Color bg;
  final Color ink;
  final Color? border;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      border: border == null ? null : Border.all(color: border!),
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

// ---------------------------------------------------------------- design 1

/// 1 · Leather card, brass-framed picture window, faceted rarity jewel.
class _LeatherCard extends StatelessWidget {
  const _LeatherCard(this.c);
  final CompanionCard c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final skin = TreadSkin.of(context);
    final jewel = rarityJewel(c.rarity);
    final s = c.stats;
    final a = c.action;
    return _tap(
      c,
      DecoratedBox(
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C402C), Color(0xFF3C291C), Color(0xFF2A1C13)],
          ),
          shape: const LeatherBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            rim: 2,
            stitchInset: 5,
          ),
          shadows: [
            const BoxShadow(
              color: Color(0xAA000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
            if (c.rarity == Rarity.legendary)
              BoxShadow(color: jewel.withValues(alpha: .35), blurRadius: 14),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: brassGradient,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(color: Color(0x99000000), blurRadius: 4),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _scene(c),
                          ),
                        ),
                      ),
                    ),
                    if (c.badge case final b?)
                      Positioned(
                        left: 7,
                        top: 7,
                        child: _Tag(
                          b,
                          bg: TreadColors.brass,
                          ink: const Color(0xFF241912),
                        ),
                      ),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: _Jewel(color: jewel, size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: skin.display(18, color: const Color(0xFFF2DCA8)),
              ),
              Row(
                children: [
                  Text(
                    rarityLabel(l, c.rarity).toUpperCase(),
                    style: TextStyle(
                      color: jewel,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      c.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TreadColors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (s != null) ...[
                const SizedBox(height: 6),
                _stats(s, TreadColors.muted, TreadColors.text),
              ],
              if (a != null) ...[
                const SizedBox(height: 8),
                _pill(
                  a,
                  deco: const BoxDecoration(
                    gradient: brassGradient,
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x88000000),
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  ink: const Color(0xFF241912),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Round faceted jewel in a brass bezel.
class _Jewel extends StatelessWidget {
  const _Jewel({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _JewelPainter(color)),
  );
}

class _JewelPainter extends CustomPainter {
  _JewelPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c + const Offset(0, 1.5),
      r,
      Paint()
        ..color = const Color(0x99000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFF0CE8A),
            Color(0xFF8E6A38),
            Color(0xFFE2BC78),
            Color(0xFF7A5A2E),
            Color(0xFFF0CE8A),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final ri = r * .72;
    canvas.drawCircle(
      c,
      ri,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.3, -.35),
          colors: [
            Color.lerp(color, Colors.white, .55)!,
            color,
            Color.lerp(color, Colors.black, .55)!,
          ],
          stops: const [0, .45, 1],
        ).createShader(Rect.fromCircle(center: c, radius: ri)),
    );
    final facet = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    final inner = <Offset>[];
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + math.pi / 8;
      inner.add(c + Offset(math.cos(a), math.sin(a)) * ri * .5);
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * ri * .5,
        c + Offset(math.cos(a), math.sin(a)) * ri,
        facet,
      );
    }
    canvas.drawPath(Path()..addPolygon(inner, true), facet);
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-ri * .32, -ri * .4),
        width: ri * .55,
        height: ri * .3,
      ),
      Paint()..color = const Color(0xB3FFFFFF),
    );
  }

  @override
  bool shouldRepaint(_JewelPainter old) => old.color != color;
}

// ---------------------------------------------------------------- design 2

const _ink = Color(0xFF3A2414);
const _inkSoft = Color(0xFF6B5034);

/// 2 · Parchment card, arched sepia window, wax seal for the rarity.
class _ParchmentCard extends StatelessWidget {
  const _ParchmentCard(this.c);
  final CompanionCard c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final skin = TreadSkin.of(context);
    final wax = _waxColor(c.rarity);
    final s = c.stats;
    final a = c.action;
    final rarity = rarityLabel(l, c.rarity);
    return _tap(
      c,
      DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4E6C6), Color(0xFFE6CF9F), Color(0xFFCDAF77)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xAA000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: CustomPaint(
          foregroundPainter: _ParchmentPainter(c.artKey.hashCode),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          position: DecorationPosition.foreground,
                          decoration: BoxDecoration(
                            borderRadius: _arch,
                            border: Border.all(color: _ink, width: 1.4),
                          ),
                          child: ClipRRect(
                            borderRadius: _arch,
                            child: _scene(c, sepia: true),
                          ),
                        ),
                      ),
                      if (c.badge case final b?)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 8,
                          child: Center(
                            child: _Tag(
                              b,
                              bg: const Color(0xE6F4E6C6),
                              ink: _ink,
                              border: _ink,
                            ),
                          ),
                        ),
                      Positioned(
                        right: -10,
                        bottom: -12,
                        child: _WaxSeal(
                          color: wax,
                          letter: rarity.characters.first.toUpperCase(),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: skin.display(18, color: _ink),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      rarity.toUpperCase(),
                      style: TextStyle(
                        color: Color.lerp(wax, _ink, .25),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        c.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _inkSoft,
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                if (s != null) ...[
                  const SizedBox(height: 5),
                  Container(height: 1, color: const Color(0x553A2414)),
                  const SizedBox(height: 4),
                  _stats(s, _inkSoft, _ink),
                ],
                if (a != null) ...[
                  const SizedBox(height: 8),
                  _pill(
                    a,
                    deco: BoxDecoration(
                      color: const Color(0x223A2414),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _ink, width: 1.2),
                    ),
                    ink: _ink,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _arch = BorderRadius.vertical(
    top: Radius.circular(70),
    bottom: Radius.circular(4),
  );
}

Color _waxColor(Rarity r) => switch (r) {
  Rarity.common => const Color(0xFF8C3A26),
  Rarity.rare => const Color(0xFF2E5592),
  Rarity.epic => const Color(0xFF6A2E86),
  Rarity.legendary => const Color(0xFFC08A26),
};

/// Speckles, darker edges and a double ink rule.
class _ParchmentPainter extends CustomPainter {
  _ParchmentPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final rect = Offset.zero & size;
    final speck = Paint();
    for (var i = 0; i < 140; i++) {
      speck.color = Color.fromARGB(12 + rnd.nextInt(26), 90, 60, 30);
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        .4 + rnd.nextDouble() * 1.6,
        speck,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    final rule = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x995A3D22);
    canvas.drawRect(rect.deflate(5), rule..strokeWidth = 1.2);
    canvas.drawRect(rect.deflate(8), rule..strokeWidth = .6);
  }

  @override
  bool shouldRepaint(_ParchmentPainter old) => old.seed != seed;
}

class _WaxSeal extends StatelessWidget {
  const _WaxSeal({
    required this.color,
    required this.letter,
    required this.size,
  });
  final Color color;
  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _WaxPainter(color),
        child: Center(
          child: Text(
            letter,
            style: TreadSkin.of(context)
                .display(
                  size * .42,
                  color: Color.lerp(color, Colors.black, .45),
                )
                .copyWith(
                  shadows: [
                    Shadow(
                      color: Color.lerp(color, Colors.white, .35)!,
                      offset: const Offset(.6, .8),
                    ),
                  ],
                ),
          ),
        ),
      ),
    ),
  );
}

class _WaxPainter extends CustomPainter {
  _WaxPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final blob = Path();
    for (var i = 0; i <= 72; i++) {
      final a = i / 72 * 2 * math.pi;
      final k = r * (.9 + .06 * math.sin(7 * a) + .04 * math.sin(11 * a + 1.3));
      final p = c + Offset(math.cos(a), math.sin(a)) * k;
      i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
    }
    blob.close();
    canvas.drawShadow(blob, Colors.black, 3, false);
    canvas.drawPath(
      blob,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.4),
          colors: [
            Color.lerp(color, Colors.white, .3)!,
            color,
            Color.lerp(color, Colors.black, .45)!,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r * .62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Color.lerp(color, Colors.black, .35)!,
    );
    canvas.drawCircle(
      c + const Offset(.6, .8),
      r * .62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..color = Color.lerp(color, Colors.white, .3)!.withValues(alpha: .6),
    );
  }

  @override
  bool shouldRepaint(_WaxPainter old) => old.color != color;
}

// ---------------------------------------------------------------- design 3

/// 3 · Dark trading-card frame, brass name plate, element coin, rarity pips.
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
                          if (c.type case final t?)
                            Positioned(left: 5, top: 5, child: _ElementCoin(t)),
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
                            bottom: 5,
                            child: _NamePlate(
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
  const _NamePlate({required this.name, required this.style});
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
  );
}

class _ElementCoin extends StatelessWidget {
  const _ElementCoin(this.type);
  final CompanionType type;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: Alignment(-.3, -.4),
        colors: [Color(0xFFF0D598), Color(0xFFC4A36A), Color(0xFF7E6038)],
      ),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFF4A3420))),
      boxShadow: [BoxShadow(color: Color(0xAA000000), blurRadius: 3)],
    ),
    child: Icon(elementIcon(type), size: 16, color: const Color(0xFF2A1A0E)),
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
