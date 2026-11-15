import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/battle.dart';
import '../../domain/world.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../widgets/companion_card.dart';
import 'arena_look.dart';
import 'arena_state.dart';

/// Plays a battle of the current line-up against the practice opponent:
/// every [BattleEvent] becomes a short animation (lunge, throw, mend,
/// knock-out), the Herz bars follow, a banner shows each round.
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen>
    with SingleTickerProviderStateMixin {
  late final ArenaTeams _teams;
  late final World _world;
  late final Map<BattlePos, ArenaEntry> _byPos;
  late final AnimationController _c;
  BattleResult? _result;
  final _hearts = <BattlePos, int>{};
  final _ko = <BattlePos>{};
  var _i = 0;
  var _applied = false;
  var _round = 0;
  var _fast = false;

  List<BattleEvent> get _events => _result?.events ?? const [];
  bool get _done => _result != null && _i >= _events.length;
  BattleEvent? get _event => _i < _events.length ? _events[_i] : null;

  @override
  void initState() {
    super.initState();
    _teams = ref.read(arenaTeamsProvider);
    _world = ref.read(arenaWorldProvider);
    _byPos = _teams.byPos;
    _c = AnimationController(vsync: this)
      ..addListener(_tick)
      ..addStatusListener((s) {
        if (s != AnimationStatus.completed) return;
        _apply();
        _i++;
        _step();
      });
    if (_teams.ready) _start();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _start() {
    _result = _teams.play(ref.read(randomProvider));
    _hearts
      ..clear()
      ..addAll({for (final e in _byPos.entries) e.key: e.value.maxHeart});
    _ko.clear();
    _i = 0;
    _round = 0;
    _step();
  }

  static int _ms(BattleEvent e) => switch (e) {
    RoundStarted() => 700,
    Attacked() => 780,
    Mended() => 660,
    KnockedOut() => 560,
  };

  void _step() {
    final e = _event;
    if (e == null) {
      setState(() {});
      return;
    }
    _applied = false;
    _c.duration = Duration(milliseconds: _ms(e) ~/ (_fast ? 2.5 : 1));
    setState(() {});
    _c.forward(from: 0);
  }

  void _tick() {
    if (!_applied && _c.value >= .5) setState(_apply);
  }

  void _apply() {
    if (_applied) return;
    _applied = true;
    switch (_event) {
      case RoundStarted(:final round):
        _round = round;
      case Attacked(:final target, :final heartLeft):
        _hearts[target] = heartLeft;
      case Mended(:final target, :final heartLeft):
        _hearts[target] = heartLeft;
      case KnockedOut(:final target):
        _ko.add(target);
      case null:
    }
  }

  void _skip() {
    _c.stop();
    setState(() {
      while (_i < _events.length) {
        _applied = false;
        _apply();
        _i++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ArenaColors.leather,
      body: LayoutBuilder(
        builder: (context, box) {
          final geo = ArenaGeometry(box.biggest);
          return AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: ArenaBackdrop(world: _world)),
                ..._fighters(geo),
                ..._effects(l, geo),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(child: _topBar(l)),
                ),
                if (_done)
                  _ResultPanel(
                    result: _result!,
                    onAgain: () => setState(_start),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topBar(AppLocalizations l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        IconButton(
          key: const Key('arena-close'),
          color: ArenaColors.text,
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        const Spacer(),
        if (_round > 0)
          Text(
            l.arenaRound(_round),
            style: const TextStyle(
              color: ArenaColors.brassLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        const Spacer(),
        if (!_done) ...[
          IconButton(
            key: const Key('arena-fast'),
            tooltip: l.arenaFaster,
            color: _fast ? ArenaColors.ember : ArenaColors.text,
            icon: const Icon(Icons.fast_forward),
            onPressed: () => setState(() => _fast = !_fast),
          ),
          TextButton(
            key: const Key('arena-skip'),
            style: TextButton.styleFrom(foregroundColor: ArenaColors.text),
            onPressed: _skip,
            child: Text(l.arenaSkip),
          ),
        ],
      ],
    ),
  );

  Offset _feet(ArenaGeometry geo, BattlePos p) {
    final n = _byPos.keys.where((q) => q.side == p.side && q.row == p.row);
    return geo.feet(p.side, p.row, p.slot, n.length);
  }

  double _size(ArenaGeometry geo, BattlePos p) =>
      geo.figure * ArenaGeometry.depth(p.side, p.row);

  /// Size of fighter [p] now: a lunge carries it along the depth too.
  double _sizeNow(ArenaGeometry geo, BattlePos p) {
    if (_event case Attacked(
      :final actor,
      :final target,
      :final volley,
    ) when p == actor && !volley) {
      final k = .4 * sin(pi * _c.value);
      return _size(geo, actor) + (_size(geo, target) - _size(geo, actor)) * k;
    }
    return _size(geo, p);
  }

  /// Offset of fighter [p] in the current animation.
  Offset _motion(ArenaGeometry geo, BattlePos p) {
    final e = _event;
    final t = _c.value;
    switch (e) {
      case Attacked(:final actor, :final target, :final volley, :final dodged):
        if (p == actor && !volley) {
          return (_feet(geo, target) - _feet(geo, actor)) * .4 * sin(pi * t);
        }
        if (p == actor) return Offset(0, -12 * sin(pi * t));
        if (p == target && dodged && t > .3) {
          return Offset(_size(geo, p) * .3 * sin(pi * (t - .3) / .7), 0);
        }
        if (p == target && t > .5 && t < .85) {
          return Offset(sin(t * 70) * 6 * (1 - (t - .5) / .35), 0);
        }
      case Mended(:final actor):
        if (p == actor) return Offset(0, -10 * sin(pi * t));
      default:
    }
    return Offset.zero;
  }

  bool _lit(BattlePos p) => switch (_event) {
    Attacked(:final actor, :final target) =>
      p == actor || (p == target && _c.value > .5),
    Mended(:final actor, :final target) => p == actor || p == target,
    _ => false,
  };

  Iterable<Widget> _fighters(ArenaGeometry geo) {
    // Far rows first so nearer fighters overlap them; the attacker on top.
    final order = _byPos.keys.toList()
      ..sort((a, b) => _feet(geo, a).dy.compareTo(_feet(geo, b).dy));
    final e = _event;
    final actor = switch (e) {
      Attacked(:final actor) => actor,
      Mended(:final actor) => actor,
      _ => null,
    };
    if (actor != null && order.remove(actor)) order.add(actor);
    return [
      for (final p in order)
        () {
          final size = _sizeNow(geo, p);
          final at = _feet(geo, p) + _motion(geo, p);
          return Positioned(
            key: ValueKey(p),
            left: at.dx - size / 2,
            top: at.dy - ArenaFigure.heightFor(size),
            child: ArenaFigure(
              entry: _byPos[p]!,
              side: p.side,
              size: size,
              heart: _hearts[p],
              knockedOut: _ko.contains(p),
              lit: _lit(p),
            ),
          );
        }(),
    ];
  }

  Iterable<Widget> _effects(AppLocalizations l, ArenaGeometry geo) sync* {
    final e = _event;
    final t = _c.value;
    if (e is RoundStarted) {
      final a = t < .25 ? t / .25 : (t > .75 ? (1 - t) / .25 : 1.0);
      yield Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: a,
              child: Transform.scale(
                scale: .85 + .15 * a,
                child: _Banner(l.arenaRound(e.round)),
              ),
            ),
          ),
        ),
      );
      return;
    }
    if (e case Attacked(
      :final actor,
      :final target,
      :final volley,
    ) when volley && t < .5) {
      final from = _feet(geo, actor) - Offset(0, _size(geo, actor) * .7);
      final to = _feet(geo, target) - Offset(0, _size(geo, target) * .6);
      final at =
          Offset.lerp(from, to, t / .5)! - Offset(0, 40 * sin(pi * t * 2));
      final col = tempoColor(_byPos[actor]!.fighter.tempo);
      yield Positioned(
        left: at.dx - 9,
        top: at.dy - 9,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: col, blurRadius: 14, spreadRadius: 4)],
          ),
        ),
      );
    }
    if (t < .45) return;
    final (
      BattlePos? target,
      String text,
      Color color,
      double scale,
    ) = switch (e) {
      Attacked(:final target, :final dodged, :final crit, :final damage) =>
        dodged
            ? (target, l.arenaDodge, ArenaColors.text, 1.0)
            : crit
            ? (target, '-$damage ${l.arenaCrit}', ArenaColors.ember, 1.3)
            : (target, '-$damage', Colors.white, 1.0),
      Mended(:final target, :final amount) => (
        target,
        '+$amount',
        ArenaColors.mend,
        1.1,
      ),
      KnockedOut(:final target) => (target, l.arenaKo, ArenaColors.heart, 1.4),
      _ => (null, '', Colors.white, 1.0),
    };
    if (target == null) return;
    final k = (t - .45) / .55;
    final size = _size(geo, target);
    final at = _feet(geo, target) - Offset(0, size * .95 + 30 * k);
    yield Positioned(
      left: at.dx - 90,
      top: at.dy,
      width: 180,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - k * k).clamp(0, 1),
          child: Text(
            text,
            key: const Key('arena-popup'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 20 * scale,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(blurRadius: 4),
                Shadow(blurRadius: 10, color: Color(0xCC000000)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xE6241912),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: ArenaColors.brass, width: 1.6),
      boxShadow: [
        BoxShadow(
          color: ArenaColors.ember.withValues(alpha: .45),
          blurRadius: 22,
        ),
      ],
    ),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: ArenaColors.brassLight,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
      ),
    ),
  );
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result, required this.onAgain});

  final BattleResult result;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final won = result.won;
    final glow = won ? ArenaColors.ember : ArenaColors.brassDeep;
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xB3000000),
        child: Center(
          child: Container(
            key: const Key('arena-result'),
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
            decoration: BoxDecoration(
              color: ArenaColors.leather,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ArenaColors.brass, width: 1.6),
              boxShadow: [
                BoxShadow(color: glow.withValues(alpha: .5), blurRadius: 30),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  won ? Icons.emoji_events : Icons.shield_outlined,
                  size: 52,
                  color: won ? ArenaColors.brassLight : ArenaColors.muted,
                ),
                const SizedBox(height: 8),
                Text(
                  won ? l.arenaWon : l.arenaLost,
                  style: TextStyle(
                    color: won ? ArenaColors.brassLight : ArenaColors.text,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [Shadow(color: glow, blurRadius: 16)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.arenaRounds(result.rounds),
                  style: const TextStyle(color: ArenaColors.muted),
                ),
                const SizedBox(height: 20),
                ArenaButton(
                  key: const Key('arena-again'),
                  label: l.arenaAgain,
                  icon: Icons.replay,
                  onPressed: onAgain,
                ),
                const SizedBox(height: 6),
                TextButton(
                  key: const Key('arena-back'),
                  style: TextButton.styleFrom(
                    foregroundColor: ArenaColors.text,
                  ),
                  onPressed: () => context.pop(),
                  child: Text(l.arenaBackToLineup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
