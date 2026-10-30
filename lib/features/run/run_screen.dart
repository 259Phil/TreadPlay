import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/movement_source.dart';
import '../../domain/run_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/breath_bar.dart';
import '../../widgets/companion_figure.dart';
import '../../widgets/format.dart';
import 'run_trail.dart';
import 'sweet_spot_gauge.dart';

class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kaching = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  int _lastPieces = 0;
  int _lastBlocks = 0;
  double _lastGainLp = 0;

  /// Hidden developer readout, toggled by a long press on the distance.
  bool _gpsDebug = false;

  @override
  void dispose() {
    _kaching.dispose();
    super.dispose();
  }

  /// Every paid piece floats its LP up; a full Breath block also clicks.
  void _onPieces(RunEngine engine) {
    if (engine.pieces <= _lastPieces) return;
    _lastGainLp = (engine.pieces - _lastPieces) * engine.lpPerPiece;
    _lastPieces = engine.pieces;
    final block = engine.blocks > _lastBlocks;
    _lastBlocks = engine.blocks;
    if (ref.read(settingsProvider).kaching) {
      if (block) {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    _kaching.forward(from: 0);
  }

  void _stop() {
    ref.read(runControllerProvider.notifier).stop();
    context.go(AppRoutes.summary);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(runControllerProvider, (_, next) {
      if (next != null) _onPieces(next.engine);
    });
    final view = ref.watch(runControllerProvider);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (view == null) return const Scaffold();
    final e = view.engine;
    final device = switch (ref.read(movementSourceProvider)) {
      final DeviceMovementSource d => d,
      _ => null,
    };
    final standing = e.speedKmh < 0.5;
    final hint = !e.earnsLp
        ? null
        : !e.canEarn
        ? l.hintNoBreath
        : standing
        ? l.hintStanding
        : e.inBand
        ? l.hintInside
        : l.hintOutside;

    final skin = TreadSkin.of(context);
    final leather = skin.style == TreadStyle.leather;
    final game = ref.watch(gameProvider);
    final spot = RunTrailSpot(
      game.wanderweg,
      game.totals.distanceM + e.distanceM,
    );
    final moving = !standing;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: skin.canvas,
        body: Stack(
          children: [
            SafeArea(
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        sliver: SliverList.list(
                          children: [
                            _Portrait(view: view),
                            const SizedBox(height: 8),
                            _LpCounter(
                              lp: e.lp,
                              style: leather
                                  ? skin
                                        .display(64, color: TreadColors.brass)
                                        .copyWith(
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xCC000000),
                                              offset: Offset(0, 2),
                                              blurRadius: 5,
                                            ),
                                          ],
                                        )
                                  : theme.textTheme.displayLarge?.copyWith(
                                      color: TreadColors.brass,
                                      fontWeight: FontWeight.bold,
                                    ),
                            ),
                            Text(l.lpThisRun, textAlign: TextAlign.center),
                            if (!e.earnsLp) ...[
                              const SizedBox(height: 12),
                              Card(
                                key: const Key('run-no-lp'),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    l.runNoLp,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: TreadColors.copper,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            _StatCard(
                              leather: leather,
                              child: Row(
                                children: [
                                  _Stat(
                                    l.distance,
                                    l.kmValue(formatKm(context, e.distanceM)),
                                    onLongPress: device == null
                                        ? null
                                        : () => setState(
                                            () => _gpsDebug = !_gpsDebug,
                                          ),
                                  ),
                                  _Stat(l.time, formatDuration(e.elapsed)),
                                  _Stat(
                                    l.pace,
                                    l.paceValue(formatPace(e.livePace)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            BreathBar(breath: e.breathLeft, tank: e.tankSize),
                            const SizedBox(height: 24),
                            SweetSpotGauge(
                              type: e.companion.type,
                              speedKmh: e.speedKmh,
                              widenKmh: e.companion.sweetSpotWidenKmh,
                            ),
                            const SizedBox(height: 4),
                            if (hint != null)
                              _GpsHint(device: device, hint: hint, l: l),
                            if (kIsWeb && device != null && e.earnsLp)
                              Text(
                                l.runWebGpsHint,
                                key: const Key('run-web-gps-hint'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: TreadColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 24),
                            if (view.simulator case final sim?) ...[
                              _DemoPanel(sim: sim),
                              const SizedBox(height: 24),
                            ],
                            SizedBox(
                              height: 64,
                              child: FilledButton.icon(
                                style: leather
                                    ? skinButtonStyle(
                                        skin,
                                        SkinButtonKind.danger,
                                        height: 64,
                                      )
                                    : FilledButton.styleFrom(
                                        backgroundColor: TreadColors.stop,
                                        foregroundColor: TreadColors.text,
                                      ),
                                icon: leather
                                    ? const SkinIcon(SkinIcons.stop, size: 36)
                                    : const Icon(Icons.stop, size: 32),
                                label: Text(
                                  l.stopRun,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                onPressed: _stop,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // The Wanderweg only in the free space below the
                      // controls, never behind them.
                      SliverFillRemaining(
                        hasScrollBody: false,
                        fillOverscroll: false,
                        child: SizedBox(
                          height: RunTrailMap.minHeight,
                          child: IgnorePointer(
                            child: RunTrailMap(
                              game: game,
                              spot: spot,
                              companion: e.companion,
                              moving: moving,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_gpsDebug && device != null)
                    Positioned(
                      top: 4,
                      left: 8,
                      child: IgnorePointer(child: _GpsReadoutLine(device)),
                    ),
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _kaching,
                      builder: (context, _) {
                        final t = _kaching.value;
                        if (t == 0 || t == 1) return const SizedBox.shrink();
                        return Align(
                          alignment: Alignment(0, -0.45 - t * 0.4),
                          child: Opacity(
                            opacity: 1 - t,
                            child: Text(
                              '+${l.lpAmount(formatNumber(context, _lastGainLp))}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: TreadColors.brass,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The run's LP, counting up in small steps as pieces are paid.
class _LpCounter extends StatelessWidget {
  const _LpCounter({required this.lp, required this.style});

  final double lp;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: lp),
    duration: const Duration(milliseconds: 650),
    curve: Curves.easeOut,
    builder: (context, shown, _) => Text(
      formatNumber(context, shown),
      key: const Key('run-lp'),
      textAlign: TextAlign.center,
      style: style,
    ),
  );
}

/// The three run values on a leather card (style C), bare otherwise.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.leather, required this.child});

  final bool leather;
  final Widget child;

  @override
  Widget build(BuildContext context) => leather
      ? Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: child,
          ),
        )
      : child;
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.onLongPress});

  final String label;
  final String value;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Column(
          children: [
            Text(
              value,
              style: kLeatherBuild
                  ? TreadSkin.of(context).display(22)
                  : theme.textTheme.titleLarge,
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// The pace hint, replaced while the GPS is still settling.
class _GpsHint extends StatelessWidget {
  const _GpsHint({required this.device, required this.hint, required this.l});

  final DeviceMovementSource? device;
  final String hint;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final d = device;
    if (d == null) return Text(hint, textAlign: TextAlign.center);
    return ValueListenableBuilder(
      valueListenable: d.readout,
      builder: (context, r, _) => Text(
        r?.warmingUp == true ? l.hintGpsWarmup : hint,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Developer-only GPS quality line (long press on the distance).
class _GpsReadoutLine extends StatelessWidget {
  const _GpsReadoutLine(this.device);

  final DeviceMovementSource device;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: device.readout,
    builder: (context, r, _) => Text(
      r == null
          ? 'GPS –'
          : 'GPS ±${r.accuracyM?.toStringAsFixed(0) ?? '?'} m · '
                'ok ${r.accepted} · drop ${r.rejected} · '
                'jump ${r.jumps} · gap ${r.gaps}'
                '${r.warmingUp ? ' · warm-up' : ''} · ${r.verdict?.name ?? ''}'
                ' · doppler ${r.dopplerKmh?.toStringAsFixed(1) ?? '–'}',
      key: const Key('run-gps-readout'),
      style: const TextStyle(color: TreadColors.muted, fontSize: 10),
    ),
  );
}

class _DemoPanel extends ConsumerWidget {
  const _DemoPanel({required this.sim});

  final SimulatedMovementSource sim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(runControllerProvider.notifier);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.demoTitle, style: Theme.of(context).textTheme.labelLarge),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    key: const Key('demo-speed'),
                    value: sim.targetSpeedKmh,
                    max: SweetSpotGauge.maxKmh,
                    divisions: 40,
                    onChanged: controller.setDemoSpeed,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    l.kmhValue(formatNumber(context, sim.targetSpeedKmh)),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.demoTimeLapse),
              value: sim.timeScale > 1,
              onChanged: controller.setTimeLapse,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small portrait of the companion on this run.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.view});

  final RunView view;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = view.engine.companion;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TreadColors.plate,
            border: Border.all(color: rarityMetal(c.rarity), width: 2),
            boxShadow: kLeatherBuild
                ? const [BoxShadow(color: Color(0xAA000000), blurRadius: 6)]
                : null,
          ),
          child: CompanionArt(c.artKey),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${typeLabel(l, c.type)} · ${l.statSpirit} '
                '${l.percentValue(formatNumber(context, c.spirit))}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: TreadColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
