import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_data.dart';
import '../data/game_repository.dart';
import '../data/movement_source.dart';
import '../domain/breath.dart';
import '../domain/companion.dart';
import '../domain/run_engine.dart';
import '../domain/run_summary.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override in main'),
);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Rolls market offers. Overridden with a seeded [Random] in tests.
final randomProvider = Provider<Random>((ref) => Random());

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(ref.watch(sharedPreferencesProvider)),
);

final movementSourceProvider = Provider<MovementSource>(
  (ref) => simulatorFlag ? SimulatedMovementSource() : DeviceMovementSource(),
);

final gameProvider = NotifierProvider<GameNotifier, GameData>(GameNotifier.new);

class GameNotifier extends Notifier<GameData> {
  Timer? _regenTimer;

  GameRepository get _repo => ref.read(gameRepositoryProvider);

  DateTime _now() => ref.read(clockProvider)();

  @override
  GameData build() {
    _regenTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      refreshBreath();
      refreshMarket();
    });
    ref.onDispose(() => _regenTimer?.cancel());
    final now = _now();
    final saved = _repo.loadGame();
    final game = (saved ?? GameData.initial(now))
        .regenerated(now)
        .withMarket(now, _random);
    if (!identical(game.market, saved?.market)) _repo.saveGame(game);
    return game;
  }

  Random get _random => ref.read(randomProvider);

  void refreshBreath() => _set(state.regenerated(_now()));

  void refreshMarket() {
    final next = state.withMarket(_now(), _random);
    if (!identical(next.market, state.market)) _set(next);
  }

  /// Buys a market offer for LP. Not possible during a run.
  bool buy(String offerId) {
    if (ref.read(runControllerProvider) != null) return false;
    if (state.buyBlock(offerId) != null) return false;
    _set(state.buying(offerId));
    return true;
  }

  /// Sells a companion to the market for LP. Not possible during a run.
  bool sell(String companionId) {
    if (ref.read(runControllerProvider) != null) return false;
    if (state.sellBlock(companionId) != null) return false;
    _set(state.selling(companionId, _now()));
    return true;
  }

  /// Buys a seal and sets it into [companionId]. Not possible during a run.
  bool forge(String companionId, SealType type) {
    if (ref.read(runControllerProvider) != null) return false;
    if (state.forgeBlock(companionId, type) != null) return false;
    _set(state.forging(companionId, type));
    return true;
  }

  /// Removes the seal in [slot] of [companionId]. Not possible during a run.
  void clearSeal(String companionId, int slot) {
    if (ref.read(runControllerProvider) != null) return;
    _set(state.clearingSeal(companionId, slot));
  }

  /// Switches the companion for the next run. Not possible during a run.
  void takeAlong(String companionId) {
    if (ref.read(runControllerProvider) != null) return;
    if (companionId == state.activeCompanionId) return;
    if (!state.companions.any((c) => c.id == companionId)) return;
    _set(state.takingAlong(companionId, _now()));
  }

  void completeRun(RunSummary run, {required double breathLeft}) {
    var next = state.copyWith(
      runs: [run, ...state.runs].take(GameData.maxStoredRuns).toList(),
    );
    if (run.valid) {
      next = next.copyWith(
        lp: next.lp + run.lp,
        breath: Breath(points: breathLeft, updatedAt: run.startedAt),
      );
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

  void setMovementAccess(MovementAccess access) =>
      _set(state.copyWith(movementAccess: access));

  void _set(AppSettings s) {
    state = s;
    ref.read(gameRepositoryProvider).saveSettings(s);
  }
}

/// Snapshot of an active run for the UI.
class RunView {
  const RunView({required this.engine, this.simulator});

  final RunEngine engine;

  /// Set only when the debug simulator drives the run.
  final SimulatedMovementSource? simulator;
}

final runControllerProvider = NotifierProvider<RunController, RunView?>(
  RunController.new,
);

class RunController extends Notifier<RunView?> {
  StreamSubscription<Object?>? _sub;

  MovementSource get _source => ref.read(movementSourceProvider);

  SimulatedMovementSource? get _simulator => switch (_source) {
    final SimulatedMovementSource s => s,
    _ => null,
  };

  @override
  RunView? build() {
    ref.onDispose(() => _sub?.cancel());
    return null;
  }

  /// Starts a run on the shared Breath bar. Without movement access the run
  /// still opens but earns no LP, and device sensors are not touched.
  bool start() {
    if (state != null) return false;
    final allowed =
        ref.read(settingsProvider).movementAccess == MovementAccess.allowed;
    ref.read(gameProvider.notifier).refreshBreath();
    final game = ref.read(gameProvider);
    final engine = RunEngine(
      companion: game.activeCompanion,
      breathAtStart: game.breath.points,
      startedAt: ref.read(clockProvider)(),
      earnsLp: allowed,
    );
    final sim = _simulator
      ?..targetSpeedKmh = 0
      ..timeScale = 1;
    if (allowed || sim != null) {
      _sub = _source.start(engine.startedAt).listen((sample) {
        engine.add(sample);
        _emit(engine);
      });
    }
    _emit(engine);
    return true;
  }

  void setDemoSpeed(double kmh) {
    final sim = _simulator;
    if (sim == null) return;
    sim.targetSpeedKmh = kmh;
    final view = state;
    if (view != null) _emit(view.engine);
  }

  void setTimeLapse(bool on) {
    final sim = _simulator;
    if (sim == null) return;
    sim.timeScale = on ? 10 : 1;
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
    state = RunView(engine: engine, simulator: _simulator);
  }
}
