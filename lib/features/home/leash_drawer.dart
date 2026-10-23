import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/game_data.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../ui/skin.dart';
import '../../widgets/pouch_art.dart';

/// What the leash drawer has shown so far this session: the leash length
/// the player last looked at and the one it last peeked for, so a new
/// pouch glows on the handle and peeks out once.
class LeashSeen {
  const LeashSeen({this.seen, this.peeked});
  final int? seen;
  final int? peeked;
}

class LeashSeenNotifier extends Notifier<LeashSeen> {
  @override
  LeashSeen build() => const LeashSeen();

  void seeing(int n) => state = LeashSeen(seen: n, peeked: n);
  void peeking(int n) => state = LeashSeen(seen: state.seen, peeked: n);
}

final leashSeenProvider = NotifierProvider<LeashSeenNotifier, LeashSeen>(
  LeashSeenNotifier.new,
);

/// The leash on Home as a drawer at the right edge of the world: a slim
/// brass-and-leather handle with the pouch count while closed (so the
/// companion stays free), the full leash sliding out on tap or swipe.
/// A tap outside or on the handle slides it back. A new pouch makes it
/// peek out once by itself.
class LeashDrawer extends ConsumerStatefulWidget {
  const LeashDrawer({super.key, required this.game});

  final GameData game;

  /// Width of the handle while closed.
  static const handleW = 30.0;
  static const handleH = 68.0;

  /// Distance from the bottom of the world.
  static const bottom = 8.0;

  static const _railW = 184.0;
  static const _panelW = _railW + 18;

  @override
  ConsumerState<LeashDrawer> createState() => _LeashDrawerState();
}

class _LeashDrawerState extends ConsumerState<LeashDrawer>
    with TickerProviderStateMixin {
  late final _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final _hold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _peeking = false;

  int get _count => widget.game.pouches.leash.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didUpdateWidget(LeashDrawer old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _slide.dispose();
    _hold.dispose();
    super.dispose();
  }

  /// First look of the session: what hangs now counts as seen. Later a
  /// longer leash peeks out once; a shorter one (a pouch opened) is seen.
  void _check() {
    if (!mounted) return;
    final s = ref.read(leashSeenProvider);
    final n = _count;
    final notifier = ref.read(leashSeenProvider.notifier);
    if (s.seen == null || n < (s.seen ?? 0)) {
      notifier.seeing(n);
    } else if (n > (s.peeked ?? s.seen!) && _slide.value == 0) {
      notifier.peeking(n);
      _peek();
    }
  }

  Future<void> _peek() async {
    _peeking = true;
    try {
      await _slide.animateTo(1, curve: Curves.easeOutCubic).orCancel;
      await _hold.forward(from: 0).orCancel;
      if (_peeking) await _slide.animateBack(0).orCancel;
    } on TickerCanceled {
      // Closed or disposed meanwhile.
    } finally {
      _peeking = false;
    }
  }

  void _open() {
    _stopPeek();
    ref.read(leashSeenProvider.notifier).seeing(_count);
    _slide.animateTo(1, curve: Curves.easeOutCubic);
  }

  void _close() {
    _stopPeek();
    _slide.animateBack(0, curve: Curves.easeInCubic);
  }

  void _stopPeek() {
    if (!_peeking) return;
    _peeking = false;
    _hold.stop();
  }

  void _toggle() => _slide.value > .5 ? _close() : _open();

  void _drag(DragUpdateDetails d) {
    _stopPeek();
    _slide.value -= d.primaryDelta! / LeashDrawer._panelW;
  }

  void _dragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < -300 || (v.abs() <= 300 && _slide.value > .5)) {
      _open();
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final seen = ref.watch(leashSeenProvider);
    final leash = game.pouches.leash;
    final fresh = seen.seen != null && leash.length > seen.seen!;
    final glow = fresh || leash.any((p) => p.ready);
    return AnimatedBuilder(
      animation: _slide,
      builder: (context, _) {
        final t = _slide.value;
        return Stack(
          children: [
            if (t > 0)
              Positioned.fill(
                child: GestureDetector(
                  key: const Key('home-leash-barrier'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: .28 * t),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: LeashDrawer.bottom,
              child: GestureDetector(
                onHorizontalDragUpdate: _drag,
                onHorizontalDragEnd: _dragEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Handle(
                      count: leash.length,
                      clips: game.leashClips,
                      open: t > .5,
                      turn: t,
                      glow: glow,
                      onTap: _toggle,
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: t,
                        child: ExcludeSemantics(
                          excluding: t < .5,
                          child: IgnorePointer(
                            ignoring: t < .99,
                            child: _Panel(game: game),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Painted leather tab with brass trim at the edge of the world.
class _Handle extends StatelessWidget {
  const _Handle({
    required this.count,
    required this.clips,
    required this.open,
    required this.turn,
    required this.glow,
    required this.onTap,
  });

  final int count;
  final int clips;
  final bool open;
  final double turn;
  final bool glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = TreadSkin.of(context);
    const r = Radius.circular(11);
    return Semantics(
      button: true,
      label:
          '${open ? l.homeLeashClose : l.homeLeashOpen}, '
          '${l.pouchLeash(count, clips)}',
      child: GestureDetector(
        key: const Key('home-leash-handle'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: LeashDrawer.handleW,
          height: LeashDrawer.handleH,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(left: r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B4527), Color(0xFF3B2414)],
            ),
            border: Border.all(color: s.brass, width: 1.4),
            boxShadow: [
              const BoxShadow(color: Color(0x99000000), blurRadius: 6),
              if (glow)
                BoxShadow(
                  color: s.brass.withValues(alpha: .6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Container(
            // Stitched inner line.
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
              border: Border.all(
                color: s.brassDeep.withValues(alpha: .7),
                width: .8,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Transform.rotate(
                  angle: turn * 3.14159,
                  child: Icon(Icons.chevron_left, size: 16, color: s.brass),
                ),
                Container(
                  key: const Key('home-leash-badge'),
                  constraints: const BoxConstraints(minWidth: 19),
                  height: 19,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: count > 0 ? s.brass : s.brassDeep,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2A190D)),
                  ),
                  child: Text(
                    '$count',
                    key: const Key('home-leash-count'),
                    style: const TextStyle(
                      color: Color(0xFF241608),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                Icon(
                  Icons.drag_indicator,
                  size: 13,
                  color: s.brass.withValues(alpha: .7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The full leash: the pouches found so far, warm ones glowing. Tap
/// opens the pouch screen.
class _Panel extends StatelessWidget {
  const _Panel({required this.game});

  final GameData game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = TreadSkin.of(context);
    final leash = game.pouches.leash;
    return Semantics(
      button: true,
      label: l.pouchLeash(leash.length, game.leashClips),
      child: SizedBox(
        width: LeashDrawer._panelW,
        child: SkinChip(
          key: const Key('home-leash'),
          onTap: () => context.push(AppRoutes.pouches),
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.displayText(l.homeLeash),
                style: TextStyle(
                  color: s.brass,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: s.displayUpper ? 1 : 0,
                ),
              ),
              LeashRail(
                leash: leash,
                clips: game.leashClips,
                artSize: 36,
                compact: true,
                keyPrefix: 'home-leash-clip',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
