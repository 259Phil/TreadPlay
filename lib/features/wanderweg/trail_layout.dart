import 'dart:math' as math;
import 'dart:ui';

import '../../domain/wanderweg.dart';
import '../../domain/world.dart';

/// Painted art is 780 × 1688 per section; every point below is in that space,
/// y down. The trail climbs from the bottom of section 0 to the top of the
/// last one.
const double artWidth = 780;
const double artHeight = 1688;

class TrailSign {
  const TrailSign(this.worlds, this.at, this.fromWaymark, {this.right = false});

  final List<World> worlds;
  final Offset at;

  /// The sign lights up once this waymark is reached (0 = from the start).
  final int fromWaymark;

  /// Anchored at its right edge instead of its left.
  final bool right;
}

class TrailSection {
  const TrailSection({
    required this.asset,
    required this.path,
    required this.cairns,
    this.signs = const [],
  });

  final String asset;

  /// Bottom to top.
  final List<Offset> path;

  /// Foot of the cairn per waymark number.
  final Map<int, Offset> cairns;
  final List<TrailSign> signs;
}

/// Where a new player starts: on the painted path inside section 0, well
/// above the fade into the task panel.
const Offset trailStart = Offset(616, 1450);

/// Where the companion rests once all waymarks are reached: further up the
/// path in the last section, clear of the last waymark and its label.
const Offset trailEnd = Offset(480, 120);

/// Section 0 at the bottom (Medieval → Jungle) up to section 3 (Robot,
/// Space, Rococo, Candy).
const List<TrailSection> trailSections = [
  TrailSection(
    asset: 'assets/wanderweg/trail_1.webp',
    path: [
      Offset(470, 1688),
      Offset(600, 1500),
      Offset(640, 1350),
      Offset(560, 1220),
      Offset(440, 1100),
      Offset(290, 980),
      Offset(280, 880),
      Offset(380, 800),
      Offset(560, 720),
      Offset(650, 640),
      Offset(600, 560),
      Offset(450, 500),
      Offset(300, 440),
      Offset(260, 380),
      Offset(380, 320),
      Offset(480, 280),
      Offset(430, 230),
      Offset(330, 200),
      Offset(370, 160),
      Offset(410, 140),
      Offset(420, 0),
    ],
    cairns: {
      1: Offset(472, 1372),
      2: Offset(300, 1092),
      3: Offset(400, 922),
      4: Offset(700, 652),
      5: Offset(210, 452),
    },
    signs: [
      TrailSign([World.medieval], Offset(24, 1560), 0),
      TrailSign([World.jungle], Offset(24, 620), 3),
    ],
  ),
  TrailSection(
    asset: 'assets/wanderweg/trail_2.webp',
    path: [
      Offset(380, 1688),
      Offset(336, 1640),
      Offset(335, 1600),
      Offset(368, 1560),
      Offset(413, 1520),
      Offset(463, 1480),
      Offset(503, 1440),
      Offset(527, 1400),
      Offset(532, 1360),
      Offset(521, 1320),
      Offset(487, 1280),
      Offset(435, 1240),
      Offset(371, 1200),
      Offset(321, 1160),
      Offset(287, 1120),
      Offset(296, 1080),
      Offset(334, 1040),
      Offset(384, 1000),
      Offset(413, 960),
      Offset(391, 920),
      Offset(328, 880),
      Offset(279, 840),
      Offset(233, 800),
      Offset(226, 760),
      Offset(260, 720),
      Offset(323, 680),
      Offset(360, 640),
      Offset(340, 600),
      Offset(295, 550),
      Offset(272, 500),
      Offset(282, 450),
      Offset(320, 420),
      Offset(400, 390),
      Offset(470, 360),
      Offset(490, 330),
      Offset(450, 300),
      Offset(400, 270),
      Offset(385, 240),
      Offset(420, 210),
      Offset(500, 180),
      Offset(540, 150),
      Offset(470, 120),
      Offset(400, 100),
      Offset(390, 60),
      Offset(420, 0),
    ],
    cairns: {
      6: Offset(370, 1450),
      7: Offset(480, 1130),
      8: Offset(120, 830),
      9: Offset(160, 470),
    },
    signs: [
      TrailSign([World.underwater], Offset(756, 1010), 6, right: true),
      TrailSign([World.egypt, World.pirate], Offset(24, 150), 9),
    ],
  ),
  TrailSection(
    asset: 'assets/wanderweg/trail_3.webp',
    path: [
      Offset(390, 1688),
      Offset(400, 1450),
      Offset(410, 1240),
      Offset(370, 1100),
      Offset(320, 1000),
      Offset(260, 900),
      Offset(205, 800),
      Offset(230, 740),
      Offset(330, 705),
      Offset(420, 670),
      Offset(380, 610),
      Offset(300, 560),
      Offset(275, 505),
      Offset(330, 470),
      Offset(440, 435),
      Offset(505, 400),
      Offset(470, 365),
      Offset(405, 330),
      Offset(410, 300),
      Offset(470, 280),
      Offset(500, 255),
      Offset(450, 230),
      Offset(425, 205),
      Offset(430, 0),
    ],
    cairns: {
      10: Offset(300, 1176),
      11: Offset(430, 1010),
      12: Offset(430, 590),
      13: Offset(600, 420),
      14: Offset(370, 262),
    },
    signs: [
      TrailSign([World.steampunk], Offset(756, 860), 11, right: true),
    ],
  ),
  TrailSection(
    asset: 'assets/wanderweg/trail_4.webp',
    path: [
      Offset(420, 1688),
      Offset(420, 1500),
      Offset(400, 1350),
      Offset(380, 1250),
      Offset(370, 1150),
      Offset(380, 1000),
      Offset(390, 880),
      Offset(370, 780),
      Offset(360, 700),
      Offset(400, 640),
      Offset(470, 580),
      Offset(500, 520),
      Offset(450, 440),
      Offset(380, 390),
      Offset(330, 330),
      Offset(350, 270),
      Offset(430, 220),
      Offset(490, 170),
      Offset(480, 120),
      Offset(420, 80),
      Offset(360, 40),
      Offset(340, 0),
    ],
    cairns: {
      15: Offset(540, 1330),
      16: Offset(510, 960),
      17: Offset(240, 700),
      18: Offset(610, 500),
      19: Offset(230, 300),
    },
    signs: [
      TrailSign([World.space, World.robot], Offset(24, 1560), 15),
      TrailSign([World.rococo], Offset(756, 1040), 19, right: true),
      TrailSign([World.candy], Offset(756, 160), 19, right: true),
    ],
  ),
];

/// Places the sections for a given screen width and answers where things
/// sit on the stacked trail.
class TrailGeometry {
  TrailGeometry({
    required this.width,
    required this.topPad,
    required this.bottomPad,
  }) {
    for (var i = 0; i < trailSections.length; i++) {
      final section = trailSections[i];
      for (final p in section.path) {
        final g = map(i, p);
        if (_points.isNotEmpty) {
          _cum.add(_cum.last + (g - _points.last).distance);
        } else {
          _cum.add(0);
        }
        _points.add(g);
      }
      for (final e in section.cairns.entries) {
        _waymarkS[e.key] = project(map(i, e.value));
      }
    }
  }

  final double width;

  /// Arc length of [trailStart]; nothing is walked before it.
  late final double startS = project(map(0, trailStart));

  /// Arc length of [trailEnd].
  late final double endS = project(map(trailSections.length - 1, trailEnd));
  final double topPad;
  final double bottomPad;
  final List<Offset> _points = [];
  final List<double> _cum = [];
  final Map<int, double> _waymarkS = {};

  double get sectionHeight => width * artHeight / artWidth;
  double get totalHeight =>
      topPad + sectionHeight * trailSections.length + bottomPad;
  double get length => _cum.last;

  /// Top edge of section [i] (0 = bottom) in content coordinates.
  double sectionTop(int i) =>
      topPad + (trailSections.length - 1 - i) * sectionHeight;

  Offset map(int section, Offset art) => Offset(
    art.dx / artWidth * width,
    sectionTop(section) + art.dy / artHeight * sectionHeight,
  );

  Offset cairnFoot(int waymark) {
    for (var i = 0; i < trailSections.length; i++) {
      final p = trailSections[i].cairns[waymark];
      if (p != null) return map(i, p);
    }
    throw ArgumentError.value(waymark, 'waymark');
  }

  /// Arc length on the trail next to waymark [n].
  double waymarkS(int n) => _waymarkS[n]!;

  /// Point on the trail at arc length [s].
  Offset at(double s) {
    final t = s.clamp(0, length);
    for (var i = 1; i < _points.length; i++) {
      if (_cum[i] >= t) {
        final seg = _cum[i] - _cum[i - 1];
        final f = seg == 0 ? 0.0 : (t - _cum[i - 1]) / seg;
        return Offset.lerp(_points[i - 1], _points[i], f)!;
      }
    }
    return _points.last;
  }

  /// Arc length of the trail point nearest to [p].
  double project(Offset p) {
    var best = double.infinity;
    var bestS = 0.0;
    for (var i = 1; i < _points.length; i++) {
      final a = _points[i - 1];
      final b = _points[i];
      final ab = b - a;
      final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
      final f = len2 == 0
          ? 0.0
          : (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
      final q = a + ab * f;
      final d = (p - q).distance;
      if (d < best) {
        best = d;
        bestS = _cum[i - 1] + math.sqrt(len2) * f;
      }
    }
    return bestS;
  }

  /// Where the companion walks: between the last reached waymark and the
  /// next one, by km; it never passes a waymark it has not reached.
  double companionS(WanderwegProgress progress, double distanceM) {
    final reached = progress.reached;
    if (progress.complete) {
      return endS;
    }
    final next = waymarks[reached];
    final fromKm = reached == 0 ? 0.0 : waymarks[reached - 1].km;
    final fromS = reached == 0 ? startS : waymarkS(reached);
    final toS = waymarkS(next.number);
    final f = ((distanceM / 1000 - fromKm) / (next.km - fromKm)).clamp(
      0.0,
      1.0,
    );
    final start = reached == 0 ? 0.0 : 0.1;
    return fromS + (toS - fromS) * (start + (0.88 - start) * f);
  }
}
