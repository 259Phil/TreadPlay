import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_data.dart';
import '../data/game_repository.dart';
import '../data/movement_source.dart';
import '../domain/breath.dart';
import '../domain/companion.dart';
import '../domain/forge.dart';
import '../domain/pouch.dart';
import '../domain/run_engine.dart';
import '../domain/run_summary.dart';
import '../domain/salve.dart';

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
        .advancingWanderweg(now)
        .regenerated(now)
        .agingPouches(now)
        .withMarket(now, _random);
    if (!identical(game.market, saved?.market) ||
        !identical(game.pouches, saved?.pouches) ||
        !identical(game.wanderweg, saved?.wanderweg)) {
      _repo.saveGame(game);
    }
    return game;
  }

  Random get _random => ref.read(randomProvider);

  void refreshBreath() {
    final now = _now();
    _set(state.regenerated(now).agingPouches(now));
  }

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

  bool get _running => ref.read(runControllerProvider) != null;

  /// Buys one more shelf slot for LP. Not possible during a run.
  bool buySlot() {
    if (_running || state.slotBlock != null) return false;
    _set(state.buyingSlot());
    return true;
  }

  /// Levels [companionId] up for LP once it has walked the XP. Not
  /// possible during a run.
  bool levelUp(String companionId) {
    if (_running || state.levelUpBlock(companionId) != null) return false;
    _set(state.levelingUp(companionId, _now()));
    return true;
  }

  /// Buys one [salve] from the Market into the Vorrat. Not during a run.
  bool buySalve(Salve salve) {
    if (_running || state.buySalveBlock(salve) != null) return false;
    _set(state.buyingSalve(salve));
    return true;
  }

  /// Uses one [salve] from the Vorrat on [companionId]. Not during a run.
  bool useSalve(String companionId, Salve salve) {
    if (_running || state.useSalveBlock(companionId, salve) != null) {
      return false;
    }
    _set(state.usingSalve(companionId, salve));
    return true;
  }

  /// Buys a seal L1 into the seal case. Not possible during a run.
  bool buySeal(SealType type) {
    if (_running || state.buySealBlock() != null) return false;
    _set(state.buyingSeal(type));
    return true;
  }

  /// Forges two equal seals up one level with [glut] Glut. Null when not
  /// allowed (see [GameData.upgradeBlock]) or during a run.
  ForgeOutcome? upgradeSeal(Seal seal, int glut) {
    if (_running || state.upgradeBlock(seal, glut) != null) return null;
    final (next, outcome) = state.upgrading(seal, glut, _random);
    _set(next);
    return outcome;
  }

  /// Combines two single seals of different stats. Null when not allowed
  /// (see [GameData.combineBlock]) or during a run.
  ForgeOutcome? combineSeals(Seal a, Seal b, int glut) {
    if (_running || state.combineBlock(a, b, glut) != null) return null;
    final (next, outcome) = state.combining(a, b, glut, _random);
    _set(next);
    return outcome;
  }

  /// Melts splinters into a seal L1 of [type]. Not possible during a run.
  bool meltSplinters(SealType type) {
    if (_running || state.meltBlock() != null) return false;
    _set(state.meltingSplinters(type));
    return true;
  }

  /// Sets [seal] from the case into [companionId]. Not during a run.
  bool setSeal(String companionId, Seal seal) {
    if (_running || state.setBlock(companionId, seal) != null) return false;
    _set(state.settingSeal(companionId, seal));
    return true;
  }

  /// Takes the seal in [slot] of [companionId] back into the case. Not
  /// possible during a run.
  void clearSeal(String companionId, int slot) {
    if (_running) return;
    _set(state.clearingSeal(companionId, slot));
  }

  /// Switches the companion for the next run. Not possible during a run.
  void takeAlong(String companionId) {
    if (ref.read(runControllerProvider) != null) return;
    if (companionId == state.activeCompanionId) return;
    if (!state.companions.any((c) => c.id == companionId)) return;
    _set(state.takingAlong(companionId, _now()));
  }

  /// Opens pouch [index] on the leash (free when warmed through, else for
  /// LP). Returns what was inside; null when not possible or during a run.
  List<PouchReward>? openPouch(int index) {
    if (_running || state.openPouchBlock(index) != null) return null;
    final (next, rewards) = state.openingPouch(index, _random);
    _set(next);
    return rewards;
  }

  void completeRun(RunSummary run, {required double breathLeft}) {
    var next = state.recordingRun(run, random: _random);
    if (run.valid) {
      next = next.copyWith(
        lp: next.lp + run.lp,
        breath: Breath(points: breathLeft, updatedAt: run.startedAt),
      );
    }
    _set(next);
    refreshBreath();
  }

  /// Takes the task the waiting messenger offers.
  void acceptMessengerTask() => _set(state.acceptingTask());

  /// Turns the offered task down: the messenger leaves its pouch instead.
  void declineMessengerTask() => _set(state.decliningTask(_now()));

  /// The waiting messenger delivery (or leash-full visit) was shown.
  void dismissMessenger() => _set(state.dismissingVisit());

  /// The "task done" note was shown.
  void dismissMessengerDone() => _set(state.dismissingDone());

  /// Replaces the whole game with an imported save. Not during a run.
  bool importGame(GameData game) {
    if (ref.read(runControllerProvider) != null) return false;
    final now = _now();
    _set(game.regenerated(now).withMarket(now, _random));
    return true;
  }

  /// "Delete save game": everything goes, incl. totals and today's videos,
  /// back to a fresh start with Pebble. Not during a run.
  bool wipe() {
    if (ref.read(runControllerProvider) != null) return false;
    final now = _now();
    _set(GameData.initial(now).withMarket(now, _random));
    return true;
  }

  /// Deletes the stored run history; lifetime totals stay.
  void eraseRuns() => _set(state.erasingRuns());

  /// Pays today's next video reward after a fully watched video.
  bool claimVideo() {
    final next = state.claimingVideo(_now());
    if (next == null) return false;
    _set(next);
    return true;
  }

  /// The forge tree has drawn the links of [keys] growing once.
  void markLinksGrown(Iterable<String> keys) {
    final next = state.forge.growing(keys);
    if (identical(next, state.forge)) return;
    _set(state.copyWith(forge: next));
  }

  /// The player has seen the newly reached waymarks (bubble closed or the
  /// trail opened).
  void markWanderwegSeen() {
    if (state.wanderweg.unseen == 0) return;
    _set(state.copyWith(wanderweg: state.wanderweg.markedSeen()));
  }

  /// Every change also reaches the waymarks it allows; none is ever taken
  /// back.
  void _set(GameData data) {
    final next = data.advancingWanderweg(_now());
    state = next;
    _repo.saveGame(next);
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

  void markExported(DateTime at) => _set(state.copyWith(lastExportAt: at));

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
      tankSize: game.breathCap,
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
