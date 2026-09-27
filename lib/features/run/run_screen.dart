import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/breath_bar.dart';
import '../../widgets/format.dart';
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
  int _lastBlocks = 0;
  double _lastBlockLp = 0;

  @override
  void dispose() {
    _kaching.dispose();
    super.dispose();
  }

  void _onBlocks(RunEngine engine) {
    if (engine.blocks <= _lastBlocks) return;
    _lastBlocks = engine.blocks;
    _lastBlockLp = engine.shoe.lpPerBreath;
    if (ref.read(settingsProvider).kaching) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.mediumImpact();
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
      if (next != null) _onBlocks(next.engine);
    });
    final view = ref.watch(runControllerProvider);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (view == null) return const Scaffold();
    final e = view.engine;
    final hint = !e.canEarn
        ? l.hintNoBreath
        : e.speedKmh < 0.5
        ? l.hintStanding
        : e.factor > 0
        ? l.hintInside
        : l.hintOutside;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(
                    '${e.shoe.name} · ${shoeTypeLabel(l, e.shoe.type)}',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatNumber(context, e.lp),
                    key: const Key('run-lp'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: TreadColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(l.lpThisRun, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _Stat(
                        l.distance,
                        l.kmValue(formatKm(context, e.distanceM)),
                      ),
                      _Stat(l.time, formatDuration(e.elapsed)),
                      _Stat(
                        l.speed,
                        l.kmhValue(formatNumber(context, e.speedKmh)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BreathBar(breath: e.breathLeft, tank: e.shoe.tankSize),
                  const SizedBox(height: 24),
                  SweetSpotGauge(type: e.shoe.type, speedKmh: e.speedKmh),
                  const SizedBox(height: 4),
                  Text(hint, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  _DemoPanel(view: view),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 64,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      icon: const Icon(Icons.stop, size: 32),
                      label: Text(
                        l.stopRun,
                        style: const TextStyle(fontSize: 22),
                      ),
                      onPressed: _stop,
                    ),
                  ),
                ],
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
                          '+${l.lpAmount(formatNumber(context, _lastBlockLp))}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: TreadColors.gold,
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
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DemoPanel extends ConsumerWidget {
  const _DemoPanel({required this.view});

  final RunView view;

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
                    value: view.demoSpeedKmh,
                    max: SweetSpotGauge.maxKmh,
                    divisions: 40,
                    onChanged: controller.setDemoSpeed,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    l.kmhValue(formatNumber(context, view.demoSpeedKmh)),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.demoTimeLapse),
              value: view.timeScale > 1,
              onChanged: controller.setTimeLapse,
            ),
          ],
        ),
      ),
    );
  }
}
