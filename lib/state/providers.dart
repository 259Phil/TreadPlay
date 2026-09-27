import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_data.dart';
import '../data/game_repository.dart';
import '../data/movement_source.dart';
import '../domain/run_engine.dart';
import '../domain/run_summary.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override in main'),
);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(ref.watch(sharedPreferencesProvider)),
);

final movementSourceProvider = Provider<SimulatedMovementSource>(
  (ref) => SimulatedMovementSource(),
);

final gameProvider = NotifierProvider<GameNotifier, GameData>(GameNotifier.new);

class GameNotifier extends Notifier<GameData> {
  Timer? _regenTimer;

  GameRepository get _repo => ref.read(gameRepositoryProvider);

  DateTime _now() => ref.read(clockProvider)();

  @override
  GameData build() {
    _regenTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => refreshBreath(),
    );
    ref.onDispose(() => _regenTimer?.cancel());
    final now = _now();
    final loaded = (_repo.loadGame() ?? GameData.initial(now)).withStarterShoes(
      now,
    );
    return loaded.copyWith(
      shoes: [for (final s in loaded.shoes) s.regenerated(now)],
    );
  }

  void refreshBreath() {
    final now = _now();
    _set(
      state.copyWith(shoes: [for (final s in state.shoes) s.regenerated(now)]),
    );
  }

  void equip(String shoeId) {
    if (shoeId == state.activeShoeId) return;
    if (!state.shoes.any((s) => s.id == shoeId)) return;
    _set(state.copyWith(activeShoeId: shoeId));
  }

  void completeRun(RunSummary run, {required double breathLeft}) {
    var next = state.copyWith(
      runs: [run, ...state.runs].take(GameData.maxStoredRuns).toList(),
    );
    if (run.valid) {
      final shoe = next.shoes.firstWhere((s) => s.id == run.shoeId);
      next = next
          .replaceShoe(
            shoe.copyWith(breath: breathLeft, breathUpdatedAt: run.startedAt),
          )
          .copyWith(lp: next.lp + run.lp);
    }
    _set(next);
    refreshBreath();
  }

  void _set(GameData data) {
    state = data;
    _repo.saveGame(data);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(gameRepositoryProvider).loadSettings();

  void setLocale(String code) => _set(state.copyWith(localeCode: code));

  void setKaching(bool on) => _set(state.copyWith(kaching: on));

  void _set(AppSettings s) {
    state = s;
    ref.read(gameRepositoryProvider).saveSettings(s);
  }
}

/// Snapshot of an active run for the UI.
class RunView {
  const RunView({
    required this.engine,
    required this.demoSpeedKmh,
    required this.timeScale,
  });

  final RunEngine engine;
  final double demoSpeedKmh;
  final int timeScale;
}

final runControllerProvider = NotifierProvider<RunController, RunView?>(
  RunController.new,
);

class RunController extends Notifier<RunView?> {
  StreamSubscription<Object?>? _sub;

  SimulatedMovementSource get _source => ref.read(movementSourceProvider);

  @override
  RunView? build() {
    ref.onDispose(() => _sub?.cancel());
    return null;
  }

  void start() {
    ref.read(gameProvider.notifier).refreshBreath();
    final shoe = ref.read(gameProvider).activeShoe;
    final engine = RunEngine(shoe: shoe, startedAt: ref.read(clockProvider)());
    _source
      ..targetSpeedKmh = 0
      ..timeScale = 1;
    _sub = _source.start(engine.startedAt).listen((sample) {
      engine.add(sample);
      _emit(engine);
    });
    _emit(engine);
  }

  void setDemoSpeed(double kmh) {
    _source.targetSpeedKmh = kmh;
    final view = state;
    if (view != null) _emit(view.engine);
  }

  void setTimeLapse(bool on) {
    _source.timeScale = on ? 10 : 1;
    final view = state;
    if (view != null) _emit(view.engine);
  }

  RunSummary? stop() {
    final view = state;
    if (view == null) return null;
    _sub?.cancel();
    _sub = null;
    _source.stop();
    final summary = view.engine.finish();
    ref
        .read(gameProvider.notifier)
        .completeRun(summary, breathLeft: view.engine.breathLeft);
    state = null;
    return summary;
  }

  void _emit(RunEngine engine) {
    state = RunView(
      engine: engine,
      demoSpeedKmh: _source.targetSpeedKmh,
      timeScale: _source.timeScale,
    );
  }
}
