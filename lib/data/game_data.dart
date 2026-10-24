import 'dart:math';

import '../domain/breath.dart';
import '../domain/companion.dart';
import '../domain/forge.dart';
import '../domain/market.dart';
import '../domain/messenger.dart';
import '../domain/pouch.dart';
import '../domain/run_summary.dart';
import '../domain/salve.dart';
import '../domain/totals.dart';
import '../domain/video_rewards.dart';
import '../domain/wanderweg.dart';
import '../domain/world.dart';

class GameData {
  const GameData({
    required this.lp,
    required this.companions,
    required this.activeCompanionId,
    required this.breath,
    required this.runs,
    this.market,
    this.totals = const Totals(),
    this.videos = const VideoRewards(),
    this.wanderweg = const WanderwegProgress(),
    this.forge = const ForgeState(),
    this.pouches = const PouchState(),
    this.messengers = const MessengerState(),
    this.salves = const SalveStock(),
  });

  factory GameData.initial(DateTime now) {
    final pebble = Companion.starter();
    return GameData(
      lp: 0,
      companions: [pebble],
      activeCompanionId: pebble.id,
      breath: Breath.full(pebble.tankSize, now),
      runs: const [],
    );
  }

  static const int maxStoredRuns = 50;

  /// Shelf slots without the trail's extra ones; see [shelfSlots].
  static const int inventoryCap = WaymarkUnlocks.baseShelfSlots;

  final double lp;
  final List<Companion> companions;
  final String activeCompanionId;

  /// The one account-wide Breath bar; see [breathCap].
  final Breath breath;

  /// Newest first.
  final List<RunSummary> runs;

  /// Null until the market is first opened (see [withMarket]).
  final Market? market;

  /// Lifetime counters, not capped at [maxStoredRuns].
  final Totals totals;

  /// Today's rewarded videos.
  final VideoRewards videos;

  /// Reached waymarks of the Wanderweg.
  final WanderwegProgress wanderweg;

  /// Seal case, Glut, splinters and Forge counters.
  final ForgeState forge;

  /// The leash with its treat pouches and the pouch counters.
  final PouchState pouches;

  /// Messenger visits, the open task and their counters.
  final MessengerState messengers;

  /// Mutsalben in the Vorrat.
  final SalveStock salves;

  /// Seals set into companions, all of them.
  Iterable<Seal> get setSeals => companions.expand((c) => c.seals);

  /// Every seal the player owns: set ones and loose ones in the case.
  Iterable<Seal> get ownedSeals => [
    ...setSeals,
    for (final (s, n) in forge.sealsInStock)
      for (var i = 0; i < n; i++) s,
  ];

  /// Everything a waymark task can count, from what the save holds.
  /// Seal counters are retroactive: they also count what the save already
  /// holds (set and loose seals), so older saves are never behind.
  WaymarkCounters get waymarkCounters {
    final owned = ownedSeals.toList();
    final set = setSeals.length;
    final forged = max(totals.forgeUses, owned.length);
    final placed = max(forge.placed, set);
    final best = owned.fold<int>(forge.bestLevel, (n, s) => max(n, s.level));
    final combined = max(forge.combines, owned.where((s) => s.combined).length);
    final bought = companions.where(_fromMarket).length;
    final maxLevel = companions.fold<int>(
      1,
      (n, c) => c.level > n ? c.level : n,
    );
    return WaymarkCounters(
      distanceM: totals.distanceM,
      values: {
        WaymarkCounter.sealsForged: forged,
        WaymarkCounter.sealsPlaced: placed,
        WaymarkCounter.bestSealLevel: best,
        WaymarkCounter.combines: combined,
        WaymarkCounter.sweetSpot58Runs: totals.sweetSpot58Runs,
        WaymarkCounter.sweetSpot71Runs: totals.sweetSpot71Runs,
        WaymarkCounter.companionsBought: totals.companionsBought > bought
            ? totals.companionsBought
            : bought,
        WaymarkCounter.companionLevel: maxLevel,
        WaymarkCounter.brownPouchesOpened: pouches.openedOf(PouchColor.brown),
        WaymarkCounter.copperPouchesOpened: pouches.openedOf(PouchColor.copper),
        WaymarkCounter.turquoisePouchesOpened: pouches.openedOf(
          PouchColor.turquoise,
        ),
        WaymarkCounter.pouchesOpened: pouches.openedTotal,
        WaymarkCounter.leashFilled: pouches.leashFills,
        WaymarkCounter.messengersMet: messengers.met,
      },
    );
  }

  static bool _fromMarket(Companion c) => c.id.startsWith('m');

  WaymarkUnlocks get unlocks => WaymarkUnlocks(
    wanderweg,
    forgeUsed:
        totals.forgeUses > 0 ||
        companions.any((c) => c.charms.any((s) => s != null)),
    ownedWorlds: {for (final c in companions) c.world},
  );

  /// Reaches every waymark the counters allow. Never takes one back.
  /// Gift waymarks (13: Glut, 18: a Runentopf salve) pay out once, when
  /// they are newly reached here.
  GameData advancingWanderweg(DateTime now) {
    final next = wanderweg.advanced(waymarkCounters, now);
    if (identical(next, wanderweg)) return this;
    var game = copyWith(wanderweg: next);
    for (final w in waymarks.sublist(wanderweg.reached, next.reached)) {
      game = switch (w.unlock) {
        WaymarkUnlock.glutGift => game.copyWith(
          forge: game.forge.copyWith(
            glut: game.forge.glut + WaymarkUnlock.glutGiftAmount,
          ),
        ),
        WaymarkUnlock.salveGift => game.copyWith(
          salves: game.salves.adding(Salve.large),
        ),
        _ => game,
      };
    }
    return game;
  }

  /// Shelf size: [inventoryCap], plus 2 from waymark 17.
  int get shelfSlots => unlocks.shelfSlots;

  /// Worlds whose species the Market offers.
  Set<World> get marketWorlds => unlocks.marketWorlds;

  Companion get activeCompanion =>
      companions.firstWhere((c) => c.id == activeCompanionId);

  /// Only the companion taken along sets the cap, never the collection size.
  int get breathCap => activeCompanion.tankSize;

  RunSummary? get lastRun => runs.isEmpty ? null : runs.first;

  /// The last companion can never be sold, so a player is never left without
  /// one; selling also needs full Spirit.
  bool canSell(String companionId) {
    if (companions.length < 2) return false;
    final c = companions.where((c) => c.id == companionId).firstOrNull;
    return c != null && c.spirit >= 100;
  }

  bool get shelfFull => companions.length >= shelfSlots;

  /// Why [offerId] can't be bought right now, or null if it can.
  TradeBlock? buyBlock(String offerId) {
    final m = market;
    final offer = m?.offer(offerId);
    if (m == null || offer == null) return TradeBlock.gone;
    if (shelfFull) return TradeBlock.shelfFull;
    if (offer.spirit < 100) return TradeBlock.needsSpirit;
    if (lp < m.priceOf(offer)) return TradeBlock.notEnoughLp;
    return null;
  }

  /// Why [companionId] can't be sold right now, or null if it can.
  TradeBlock? sellBlock(String companionId) {
    final c = companions.where((c) => c.id == companionId).firstOrNull;
    if (market == null || c == null) return TradeBlock.gone;
    if (companions.length < 2) return TradeBlock.lastCompanion;
    if (c.spirit < 100) return TradeBlock.needsSpirit;
    return null;
  }

  /// Why a new seal L1 can't be bought right now, or null if it can.
  ForgeBlock? buySealBlock() {
    if (!unlocks.forge) return ForgeBlock.locked;
    if (lp < Forge.sealCost) return ForgeBlock.notEnoughLp;
    return null;
  }

  /// Pays [Forge.sealCost] for a seal L1 of [type]; it goes into the case.
  /// Check [buySealBlock] first.
  GameData buyingSeal(SealType type) => copyWith(
    lp: lp - Forge.sealCost,
    forge: forge.adding(Seal(type, 1)),
    totals: totals.addingForgeUse(),
  );

  /// Why two [seal]s from the case can't be forged into the next level with
  /// [glut] Glut, or null if they can.
  ForgeBlock? upgradeBlock(Seal seal, int glut) {
    if (!unlocks.forge) return ForgeBlock.locked;
    final step = Forge.upgrades[seal.level];
    if (seal.combined || step == null) return ForgeBlock.maxLevel;
    if (seal.level + 1 > unlocks.forgeLevel) return ForgeBlock.levelLocked;
    if (forge.count(seal) < 2) return ForgeBlock.needsPair;
    if (!step.allows(glut)) return ForgeBlock.glutRange;
    if (forge.glut < glut) return ForgeBlock.notEnoughGlut;
    if (lp < step.lp) return ForgeBlock.notEnoughLp;
    return null;
  }

  /// Forges two [seal]s up one level. LP and Glut are always spent; on a
  /// fail one input falls to splinters and the other stays in the case.
  /// Check [upgradeBlock] first.
  (GameData, ForgeOutcome) upgrading(Seal seal, int glut, Random random) {
    final step = Forge.upgrades[seal.level]!;
    final paid = forge.copyWith(
      glut: forge.glut - glut,
      attempts: forge.attempts + 1,
    );
    if (Forge.rollsFail(failChanceFor(step, glut), random)) {
      return (
        copyWith(lp: lp - step.lp, forge: _broken(paid, seal)),
        ForgeOutcome.failed(seal),
      );
    }
    final made = seal.nextLevel!;
    return (
      copyWith(
        lp: lp - step.lp,
        forge: paid.removing(seal, 2).adding(made),
        totals: totals.addingForgeUse(),
      ),
      ForgeOutcome.success(made),
    );
  }

  /// Fail chance of [step] at [glut] Glut for the companion taken along:
  /// [Recipe.schutz] in its sockets takes some points off.
  double failChanceFor(ForgeStep step, int glut) => max(
    0,
    step.failChance(glut) - activeCompanion.recipeEffect(Recipe.schutz),
  );

  /// What [a] and [b] would make in Kombinieren, null when they don't fit:
  /// two single seals of different stats make a recipe seal ([a] leads);
  /// a level-1 recipe seal and a single seal of its missing stat make the
  /// level-2 recipe seal. Both at the same level.
  static Seal? combineResult(Seal a, Seal b) {
    if (a.level != b.level || a.isTriple || b.isTriple) return null;
    if (!a.combined && !b.combined) {
      return a.type == b.type ? null : Seal.combined(a.type, b.type, a.level);
    }
    if (a.combined && b.combined) return null;
    final pair = a.combined ? a : b;
    final single = a.combined ? b : a;
    if (pair.stats.contains(single.type)) return null;
    return Seal.triple(pair.type, pair.partner!, single.type, a.level);
  }

  /// Cost, Glut range and fail chance for combining into [made].
  static ForgeStep? combineStep(Seal made) =>
      made.isTriple ? Forge.tripleStep(made.level) : Forge.combines[made.level];

  /// Why [a] and [b] can't be combined with [glut] Glut, or null if they
  /// can (see [combineResult]). A level-2 recipe opens once its level-1
  /// recipe was forged.
  ForgeBlock? combineBlock(Seal a, Seal b, int glut) {
    if (!unlocks.forge) return ForgeBlock.locked;
    final made = combineResult(a, b);
    final step = made == null ? null : combineStep(made);
    if (made == null || step == null) return ForgeBlock.badCombine;
    if (!forge.canForge(made.recipe!)) return ForgeBlock.recipeLocked;
    if (forge.count(a) < 1 || forge.count(b) < 1) return ForgeBlock.needsPair;
    if (!step.allows(glut)) return ForgeBlock.glutRange;
    if (forge.glut < glut) return ForgeBlock.notEnoughGlut;
    if (lp < step.lp) return ForgeBlock.notEnoughLp;
    return null;
  }

  /// Combines [a] and [b] into a recipe seal (see [combineResult]); both
  /// inputs are used up, so a level-2 recipe consumes its recipe seal. The
  /// recipe is noted as discovered at that level. On a fail one of the two
  /// (picked by [random]) falls to splinters, the other stays. Check
  /// [combineBlock] first.
  (GameData, ForgeOutcome) combining(Seal a, Seal b, int glut, Random random) {
    final made = combineResult(a, b)!;
    final step = combineStep(made)!;
    final paid = forge.copyWith(
      glut: forge.glut - glut,
      attempts: forge.attempts + 1,
    );
    if (Forge.rollsFail(failChanceFor(step, glut), random)) {
      final broken = random.nextBool() ? a : b;
      return (
        copyWith(lp: lp - step.lp, forge: _broken(paid, broken)),
        ForgeOutcome.failed(broken),
      );
    }
    return (
      copyWith(
        lp: lp - step.lp,
        forge: paid
            .removing(a)
            .removing(b)
            .adding(made)
            .discovering(made.recipe!, made.level)
            .copyWith(combines: paid.combines + 1),
        totals: totals.addingForgeUse(),
      ),
      ForgeOutcome.success(made),
    );
  }

  /// [seal] falls to splinters; [Recipe.schutz] on the companion taken
  /// along adds [Recipe.schutzSplinters].
  ForgeState _broken(ForgeState f, Seal seal) => f
      .removing(seal)
      .copyWith(
        splinters:
            f.splinters +
            Forge.splintersOnFail +
            (activeCompanion.recipeLevel(Recipe.schutz) > 0
                ? Recipe.schutzSplinters
                : 0),
        fails: f.fails + 1,
      );

  /// Why splinters can't be melted into a seal L1 right now.
  ForgeBlock? meltBlock() {
    if (!unlocks.forge) return ForgeBlock.locked;
    if (forge.splinters < Forge.splintersPerSeal) {
      return ForgeBlock.needsSplinters;
    }
    return null;
  }

  /// Melts [Forge.splintersPerSeal] splinters into a seal L1 of [type].
  GameData meltingSplinters(SealType type) => copyWith(
    forge: forge
        .copyWith(splinters: forge.splinters - Forge.splintersPerSeal)
        .adding(Seal(type, 1)),
    totals: totals.addingForgeUse(),
  );

  /// Why [seal] from the case can't be set into [companionId] right now.
  ForgeBlock? setBlock(String companionId, Seal seal) {
    final c = companions.where((c) => c.id == companionId).firstOrNull;
    if (c == null) return ForgeBlock.gone;
    if (!unlocks.forge) return ForgeBlock.locked;
    if (forge.count(seal) < 1) return ForgeBlock.needsPair;
    if (c.freeSocket == null) return ForgeBlock.noSocket;
    if (c.spirit < sealSpiritMin) return ForgeBlock.needsSpirit;
    return null;
  }

  /// Moves [seal] from the case into the first free socket of
  /// [companionId]. Check [setBlock] first.
  GameData settingSeal(String companionId, Seal seal) {
    final c = companions.firstWhere((c) => c.id == companionId);
    return replaceCompanion(
      c.withSeal(c.freeSocket!, seal),
    ).copyWith(forge: forge.removing(seal).copyWith(placed: forge.placed + 1));
  }

  /// Why [companionId] can't level up right now, or null if it can.
  LevelBlock? levelUpBlock(String companionId) {
    final c = companions.where((c) => c.id == companionId).firstOrNull;
    if (c == null) return LevelBlock.gone;
    final cost = c.levelUpCost;
    if (cost == null) return LevelBlock.maxLevel;
    if (!c.xpReady) return LevelBlock.needsXp;
    if (lp < cost) return LevelBlock.notEnoughLp;
    return null;
  }

  /// Levels [companionId] up for its [Companion.levelUpCost]. Breath is
  /// settled first, so a bigger tank fills up by regenerating, not at once.
  /// Check [levelUpBlock] first.
  GameData levelingUp(String companionId, DateTime now) {
    final c = companions.firstWhere((c) => c.id == companionId);
    return regenerated(now)
        .replaceCompanion(c.leveledUp())
        .copyWith(lp: lp - c.levelUpCost!)
        .advancingWanderweg(now);
  }

  /// Why [salve] can't be bought right now, or null if it can.
  SalveBlock? buySalveBlock(Salve salve) {
    final m = market;
    if (m == null) return SalveBlock.gone;
    if (lp < m.priceOfSalve(salve)) return SalveBlock.notEnoughLp;
    return null;
  }

  /// Buys one [salve] at the Market's price into the Vorrat.
  GameData buyingSalve(Salve salve) => copyWith(
    lp: lp - market!.priceOfSalve(salve),
    salves: salves.adding(salve),
  );

  /// Why [salve] can't be used on [companionId] right now, or null.
  SalveBlock? useSalveBlock(String companionId, Salve salve) {
    final c = companions.where((c) => c.id == companionId).firstOrNull;
    if (c == null) return SalveBlock.gone;
    if (salves.count(salve) < 1) return SalveBlock.noneLeft;
    if (c.spirit >= 100) return SalveBlock.fullSpirit;
    return null;
  }

  /// Uses one [salve] from the Vorrat on [companionId]. Check
  /// [useSalveBlock] first.
  GameData usingSalve(String companionId, Salve salve) {
    final c = companions.firstWhere((c) => c.id == companionId);
    return replaceCompanion(
      c.healed(salve.points),
    ).copyWith(salves: salves.removing(salve));
  }

  /// Clips on the leash: 3, the 4th from waymark 7.
  int get leashClips => unlocks.leashClips;

  bool get leashFull => pouches.leash.length >= leashClips;

  /// Glut a finished [run] brings without a pouch: [Forge.glutPerRun] for a
  /// valid run of at least [Forge.glutRunMinM] once the Forge is open.
  int glutFor(RunSummary run) =>
      run.valid && run.distanceM >= Forge.glutRunMinM && unlocks.forge
      ? Forge.glutPerRun
      : 0;

  /// The companion that went on [run] (the one taken along if it is gone).
  Companion companionFor(RunSummary run) =>
      companions.where((c) => c.id == run.companionId).firstOrNull ??
      activeCompanion;

  /// Fortune factor of the companion that went on [run].
  double fortuneFactorFor(RunSummary run) => companionFor(run).fortuneFactor;

  /// Pouch find chance of [run] (see [Pouches.chance]); 0 before waymark 1
  /// or for an invalid run. The very first pouch is sure, so the first
  /// Wanderweg task never waits on luck.
  double pouchChanceFor(RunSummary run) {
    if (!run.valid || unlocks.pouchColors.isEmpty) return 0;
    final chance = Pouches.chance(
      breathUsed: run.breathUsed,
      tankSize: run.tankSize ?? activeCompanion.tankSize,
      fortuneFactor: fortuneFactorFor(run),
    );
    if (chance > 0 && pouches.foundTotal == 0) return 1;
    // Fährte: a few points more on longer runs that used Breath.
    final faehrte = run.distanceM >= Recipe.pouchMinDistanceM && chance > 0
        ? companionFor(run).recipeEffect(Recipe.faehrte)
        : 0.0;
    return min(1, chance + faehrte);
  }

  /// Stores [run] (newest first, capped) and counts it in [totals]. Then
  /// the run warms the pouches on the leash, may find a new one (one roll
  /// with [random], none when the leash is full) and, when it found none,
  /// brings the small run Glut (see [glutFor]). Without [random] no pouch
  /// is rolled.
  GameData recordingRun(RunSummary run, {Random? random}) {
    final end = run.startedAt.add(run.duration);
    var next = copyWith(
      totals: totals.addingRun(run),
    ).agingPouches(run.startedAt).advancingWanderweg(end);
    // Warming: every pouch on the leash walks along.
    var warmed = 0;
    if (run.valid && run.distanceM > 0 && next.pouches.leash.isNotEmpty) {
      // Spurenleser: the run counts that much more for warming.
      final warmth =
          1 + next.companionFor(run).recipeEffect(Recipe.spurenleser);
      final leash = [
        for (final p in next.pouches.leash)
          p.ready ? p : p.warmed(run.distanceM * warmth, end),
      ];
      warmed = [
        for (var i = 0; i < leash.length; i++)
          if (leash[i].ready && !next.pouches.leash[i].ready) i,
      ].length;
      next = next.copyWith(pouches: next.pouches.copyWith(leash: leash));
    }
    PouchColor? found;
    final full = next.leashFull && next.unlocks.pouchColors.isNotEmpty;
    final chance = next.pouchChanceFor(run);
    if (random != null && !full && chance > 0) {
      if (random.nextDouble() < chance) {
        found = Pouches.pickColor(
          next.unlocks.pouchColors,
          next.pouches.found,
          random,
          fortuneFactor: next.fortuneFactorFor(run),
        );
        next = next.hangingPouch(found, end);
      }
    }
    var glut = found == null ? next.glutFor(run) : 0;
    // An accepted messenger task counts this run (before a new visit).
    next = next._progressingTask(run)._finishingTask();
    Messenger? came;
    // A messenger only comes when the run found no pouch, except the sure
    // first one (the next waymark asks to meet it).
    if (random != null && (found == null || next._firstMessengerSure)) {
      final chance = next.messengerChanceFor(run);
      if (chance > 0 && random.nextDouble() < chance) {
        final (visited, visit) = next._visiting(run, end, random);
        next = visited;
        came = visit.messenger;
        // A delivered pouch takes the place of the run Glut, as with a
        // pouch the run found itself.
        if (visit.kind == VisitKind.gift) glut = 0;
      }
    }
    // Glutherz: a chance of one Glut more, at most once a day.
    if (random != null) {
      final heart = next.glutherzChanceFor(run);
      if (heart > 0 && random.nextDouble() < heart) {
        glut += 1;
        next = next.copyWith(
          forge: next.forge.copyWith(glutherzDay: Messengers.dayKey(end)),
        );
      }
    }
    var stored = run.withRewards(
      glut: glut,
      pouch: found,
      leashFull: run.valid && full,
      pouchesWarmed: warmed,
      messenger: came,
    );
    // Mut and XP: only Breath used in the sweet spot counts.
    final along = next.companions
        .where((c) => c.id == run.companionId)
        .firstOrNull;
    if (run.valid && run.breathUsed > 0 && along != null) {
      final after = along.afterRun(run.breathUsed);
      next = next.replaceCompanion(after);
      stored = stored.withCompanion(
        spiritLost: ((along.spirit - after.spirit) * 10).round() / 10,
        spiritAfter: after.spirit,
        xpGained: along.level >= maxLevel ? 0 : after.xp - along.xp,
        levelReady: after.xpReady,
      );
    }
    return next.copyWith(
      runs: [stored, ...runs].take(maxStoredRuns).toList(),
      forge: glut == 0
          ? next.forge
          : next.forge.copyWith(glut: next.forge.glut + glut),
    );
  }

  /// Chance that a messenger comes after [run]: only for a valid run of at
  /// least [Messengers.minDistanceM] that found no pouch, from waymark
  /// [Messengers.fromWaymark], while no visit is waiting and below the
  /// [Messengers.dailyCap]. Scaled by Breath used and Fortune like the
  /// pouch chance; the first messenger ever is sure from waymark
  /// [Messengers.sureFromWaymark].
  double messengerChanceFor(RunSummary run) {
    if (!run.valid || run.distanceM < Messengers.minDistanceM) return 0;
    if (wanderweg.reached < Messengers.fromWaymark ||
        unlocks.pouchColors.isEmpty ||
        messengers.pending != null) {
      return 0;
    }
    final day = Messengers.dayKey(run.startedAt.add(run.duration));
    if (messengers.todayOn(day) >= Messengers.dailyCap) return 0;
    final chance = Messengers.chance(
      breathUsed: run.breathUsed,
      tankSize: run.tankSize ?? activeCompanion.tankSize,
      fortuneFactor: fortuneFactorFor(run),
    );
    if (chance <= 0) return 0;
    if (_firstMessengerSure) return 1;
    // Wanderstern: a few points more.
    return min(1, chance + companionFor(run).recipeEffect(Recipe.wanderstern));
  }

  /// Chance of one extra Glut from [Recipe.glutherz] after [run]: a valid
  /// run of at least [Forge.glutRunMinM] with the Forge open, at most once
  /// a day.
  double glutherzChanceFor(RunSummary run) {
    if (!run.valid || run.distanceM < Forge.glutRunMinM || !unlocks.forge) {
      return 0;
    }
    final day = Messengers.dayKey(run.startedAt.add(run.duration));
    if (forge.glutherzDay == day) return 0;
    return companionFor(run).recipeEffect(Recipe.glutherz);
  }

  bool get _firstMessengerSure =>
      messengers.met == 0 && wanderweg.reached >= Messengers.sureFromWaymark;

  /// A messenger arrives at [now]: picks who (Fortune colour roll), what
  /// (gift, task or leash full) and its lines.
  (GameData, MessengerVisit) _visiting(
    RunSummary run,
    DateTime now,
    Random random,
  ) {
    final m = Messengers.pick(
      unlocks.pouchColors,
      random,
      fortuneFactor: fortuneFactorFor(run),
    );
    final VisitKind kind;
    if (leashFull) {
      kind = VisitKind.leashFull;
    } else if (messengers.task == null &&
        random.nextDouble() < Messengers.taskShare) {
      kind = VisitKind.task;
    } else {
      kind = VisitKind.gift;
    }
    final last = {...messengers.lastLines};
    int line(String pool) {
      final i = Messengers.pickLine(pool, last, random);
      last[pool] = i;
      return i;
    }

    final greet = line('${m.name}.greet');
    final say = switch (kind) {
      VisitKind.gift => line('${m.name}.gift'),
      VisitKind.task => line('${m.name}.task'),
      VisitKind.leashFull => line('full'),
    };
    final visit = MessengerVisit(
      messenger: m,
      kind: kind,
      at: now,
      greet: greet,
      line: say,
      glut: kind == VisitKind.gift ? m.giftGlut : 0,
      task: kind == VisitKind.task
          ? Messengers.rollTask(m, random, line: say)
          : null,
    );
    final day = Messengers.dayKey(now);
    var next = copyWith(
      messengers: messengers.copyWith(
        met: messengers.met + 1,
        day: day,
        today: messengers.todayOn(day) + (kind == VisitKind.leashFull ? 0 : 1),
        pending: () => visit,
        lastLines: last,
      ),
    );
    if (kind == VisitKind.gift) {
      next = next
          .hangingPouch(m.color, now, source: PouchSource.messenger)
          .addingGlut(m.giftGlut);
    }
    return (next, visit);
  }

  GameData addingGlut(int n) =>
      n <= 0 ? this : copyWith(forge: forge.copyWith(glut: forge.glut + n));

  /// Counts [run] for the open task.
  GameData _progressingTask(RunSummary run) {
    final t = messengers.task;
    if (t == null || !run.valid) return this;
    final by = switch (t.type) {
      TaskType.walk => run.distanceM.floor(),
      TaskType.sweetSpotRuns => (run.sweetSpotShare ?? 0) >= .58 ? 1 : 0,
      TaskType.validRuns => run.distanceM >= Messengers.minDistanceM ? 1 : 0,
      TaskType.openPouches => 0,
    };
    return by == 0
        ? this
        : copyWith(messengers: messengers.copyWith(task: () => t.advanced(by)));
  }

  /// Pays a finished task into the case (Glut and splinters) and leaves a
  /// "done" note; the Aushang disappears.
  GameData _finishingTask() {
    final t = messengers.task;
    if (t == null || !t.done) return this;
    return copyWith(
      forge: forge.copyWith(
        glut: forge.glut + t.glut,
        splinters: forge.splinters + t.splinters,
      ),
      messengers: messengers.copyWith(
        task: () => null,
        done: () => t,
        tasksDone: messengers.tasksDone + 1,
      ),
    );
  }

  /// Takes the task the waiting messenger offers (at most one is open).
  GameData acceptingTask() {
    final v = messengers.pending;
    if (v == null || v.kind != VisitKind.task || messengers.task != null) {
      return this;
    }
    return copyWith(
      messengers: messengers.copyWith(pending: () => null, task: () => v.task),
    );
  }

  /// Turns the offered task down: the messenger leaves its pouch and Glut
  /// like a plain delivery (no pouch when the leash is full).
  GameData decliningTask(DateTime now) {
    final v = messengers.pending;
    if (v == null || v.kind != VisitKind.task) return this;
    return copyWith(messengers: messengers.copyWith(pending: () => null))
        .hangingPouch(v.messenger.color, now, source: PouchSource.messenger)
        .addingGlut(v.messenger.giftGlut);
  }

  /// The waiting gift / leash-full visit was shown.
  GameData dismissingVisit() {
    final v = messengers.pending;
    if (v == null || v.kind == VisitKind.task) return this;
    return copyWith(messengers: messengers.copyWith(pending: () => null));
  }

  /// The "task done" note was shown.
  GameData dismissingDone() => messengers.done == null
      ? this
      : copyWith(messengers: messengers.copyWith(done: () => null));

  /// Hangs a new [color] pouch on the leash if a clip is free. Runs and
  /// messengers ([PouchSource.messenger]) both use it.
  GameData hangingPouch(
    PouchColor color,
    DateTime now, {
    PouchSource source = PouchSource.run,
  }) {
    if (leashFull) return this;
    final leash = [...pouches.leash, Pouch(color: color, foundAt: now)];
    return copyWith(
      pouches: pouches.copyWith(
        leash: leash,
        found: {...pouches.found, color: pouches.foundOf(color) + 1},
        leashFills:
            leash.length >= Pouches.maxClips && leashClips >= Pouches.maxClips
            ? pouches.leashFills + 1
            : pouches.leashFills,
      ),
    );
  }

  /// Unwarmed pouches fade off the leash a day after they were found or
  /// last warmed. Warmed-through pouches stay until opened.
  GameData agingPouches(DateTime now) {
    final keep = [
      for (final p in pouches.leash)
        if (!p.fadedBy(now)) p,
    ];
    if (keep.length == pouches.leash.length) return this;
    return copyWith(
      pouches: pouches.copyWith(
        leash: keep,
        faded: pouches.faded + pouches.leash.length - keep.length,
      ),
    );
  }

  /// Why pouch [index] on the leash can't be opened now, or null.
  PouchBlock? openPouchBlock(int index) {
    if (index < 0 || index >= pouches.leash.length) return PouchBlock.gone;
    if (lp < pouches.leash[index].openLp) return PouchBlock.notEnoughLp;
    return null;
  }

  /// Opens pouch [index]: free when warmed through, else for its
  /// [Pouch.openLp]. Its contents are rolled with [random] and go into the
  /// seal case (seals, Glut, splinters). Check [openPouchBlock] first.
  (GameData, List<PouchReward>) openingPouch(int index, Random random) {
    final pouch = pouches.leash[index];
    final rewards = [
      ...Pouches.roll(pouch.color, random),
      ?Pouches.rollSalve(pouch.color, random),
    ];
    var case_ = forge;
    var stock = salves;
    for (final r in rewards) {
      case_ = switch (r.kind) {
        PouchRewardKind.seal => case_.adding(r.seal!),
        PouchRewardKind.glut => case_.copyWith(glut: case_.glut + r.amount),
        PouchRewardKind.splinters => case_.copyWith(
          splinters: case_.splinters + r.amount,
        ),
        PouchRewardKind.salve => case_,
      };
      if (r.salve case final s?) stock = stock.adding(s);
    }
    final t = messengers.task;
    final counted = t != null && t.type == TaskType.openPouches
        ? copyWith(messengers: messengers.copyWith(task: () => t.advanced(1)))
        : this;
    return (
      counted
          .copyWith(forge: case_, salves: stock)
          ._finishingTask()
          .copyWith(
            lp: lp - pouch.openLp,
            pouches: pouches.copyWith(
              leash: [...pouches.leash]..removeAt(index),
              opened: {
                ...pouches.opened,
                pouch.color: pouches.openedOf(pouch.color) + 1,
              },
            ),
          ),
      rewards,
    );
  }

  /// "Erase local record": drops the stored runs. [totals] stay, since they
  /// only hold sums for milestones, no dates or single runs.
  GameData erasingRuns() => copyWith(runs: const []);

  /// LP the next video pays, sized by the companion taken along.
  double? nextVideoReward(DateTime now) =>
      videos.nextReward(now, activeCompanion.rarity.lpPerBreath);

  /// Pays today's next video reward. Null when today's videos are used up.
  GameData? claimingVideo(DateTime now) {
    final reward = nextVideoReward(now);
    if (reward == null) return null;
    return copyWith(lp: lp + reward, videos: videos.claimed(now));
  }

  /// Takes the seal out of charm socket [slot] of [companionId]; it goes
  /// back into the seal case, nothing is lost.
  GameData clearingSeal(String companionId, int slot) {
    final c = companions.firstWhere((c) => c.id == companionId);
    final seal = c.sealAt(slot);
    final next = replaceCompanion(c.withCharm(slot, null));
    return seal == null ? next : next.copyWith(forge: forge.adding(seal));
  }

  /// Keeps the current market until its drift is due, then rolls a new one.
  /// Offers only come from [marketWorlds] (topped up to three species);
  /// at least three share the gait of the companion taken along. A market
  /// saved under older rolling rules is rolled anew once.
  GameData withMarket(DateTime now, Random random) {
    final pool = marketWorlds;
    final along = activeCompanion.tempo;
    final m = market;
    return copyWith(
      market: m == null || m.outdated
          ? Market.rolled(now, random, worlds: pool, along: along)
          : m.drifted(now, random, worlds: pool, along: along),
    );
  }

  /// Moves the offer onto the shelf for its price. Check [buyBlock] first.
  GameData buying(String offerId) {
    final m = market!;
    final offer = m.offer(offerId)!;
    return copyWith(
      lp: lp - m.priceOf(offer),
      companions: [...companions, offer],
      market: m.without(offerId),
      totals: totals.addingPurchase(),
    );
  }

  /// Sells to the market. If it was taken along, the first remaining
  /// companion is taken along instead, under the usual [takingAlong] rule.
  /// Its seals go back into the seal case. Check [sellBlock] first.
  GameData selling(String companionId, DateTime now) {
    final c = companions.firstWhere((c) => c.id == companionId);
    final next = c.id == activeCompanionId
        ? takingAlong(companions.firstWhere((o) => o.id != c.id).id, now)
        : this;
    var case_ = next.forge;
    for (final seal in c.seals) {
      case_ = case_.adding(seal);
    }
    return next.copyWith(
      lp: lp + market!.sellPriceOf(c),
      forge: case_,
      companions: [
        for (final o in companions)
          if (o.id != c.id) o,
      ],
    );
  }

  GameData regenerated(DateTime now) =>
      copyWith(breath: breath.regenerated(now, breathCap));

  /// Switches companion. The bar keeps its points (regenerated up to [now]
  /// under the old cap) and is only trimmed if the new cap is lower.
  GameData takingAlong(String companionId, DateTime now) {
    final settled = regenerated(now).copyWith(activeCompanionId: companionId);
    return settled.copyWith(breath: settled.breath.capped(settled.breathCap));
  }

  GameData copyWith({
    double? lp,
    List<Companion>? companions,
    String? activeCompanionId,
    Breath? breath,
    List<RunSummary>? runs,
    Market? market,
    Totals? totals,
    VideoRewards? videos,
    WanderwegProgress? wanderweg,
    ForgeState? forge,
    PouchState? pouches,
    MessengerState? messengers,
    SalveStock? salves,
  }) => GameData(
    lp: lp ?? this.lp,
    companions: companions ?? this.companions,
    activeCompanionId: activeCompanionId ?? this.activeCompanionId,
    breath: breath ?? this.breath,
    runs: runs ?? this.runs,
    market: market ?? this.market,
    totals: totals ?? this.totals,
    videos: videos ?? this.videos,
    wanderweg: wanderweg ?? this.wanderweg,
    forge: forge ?? this.forge,
    pouches: pouches ?? this.pouches,
    messengers: messengers ?? this.messengers,
    salves: salves ?? this.salves,
  );

  GameData replaceCompanion(Companion companion) => copyWith(
    companions: [
      for (final c in companions) c.id == companion.id ? companion : c,
    ],
  );

  Map<String, Object?> toJson() => {
    'lp': lp,
    'companions': [for (final c in companions) c.toJson()],
    'activeCompanionId': activeCompanionId,
    starterKey: true,
    'breath': breath.toJson(),
    'runs': [for (final r in runs) r.toJson()],
    if (market case final m?) 'market': m.toJson(),
    'totals': totals.toJson(),
    'videos': videos.toJson(),
    'wanderweg': wanderweg.toJson(),
    'forge': forge.toJson(),
    'pouches': pouches.toJson(),
    'messengers': messengers.toJson(),
    if (!salves.isEmpty) 'salves': salves.toJson(),
  };

  /// [now] dates the waymarks a save from before the trail is granted.
  factory GameData.fromJson(Map<String, Object?> json, {DateTime? now}) {
    final companions = [
      for (final c in json['companions']! as List<Object?>)
        c! as Map<String, Object?>,
    ];
    final activeId = json['activeCompanionId']! as String;
    final runs = [
      for (final r in json['runs']! as List<Object?>)
        RunSummary.fromJson(r! as Map<String, Object?>),
    ];
    final owned = [
      for (final c in companions)
        _retuningStarter(Companion.fromJson(c), json[starterKey] == null),
    ];
    // Saves from before the counters start from their stored runs, once.
    final totals = switch (json['totals']) {
      final Map<String, Object?> t => Totals.fromJson(
        t,
        runs: runs,
        boughtOnShelf: owned.where(_fromMarket).length,
      ),
      _ => Totals.fromRuns(
        runs,
      ).copyWith(companionsBought: owned.where(_fromMarket).length),
    };
    return GameData(
      lp: (json['lp']! as num).toDouble(),
      companions: owned,
      activeCompanionId: activeId,
      breath: switch (json['breath']) {
        final Map<String, Object?> b => Breath.fromJson(b),
        _ => _legacyBreath(companions.firstWhere((c) => c['id'] == activeId)),
      },
      runs: runs,
      market: switch (json['market']) {
        final Map<String, Object?> m => Market.fromJson(m),
        _ => null,
      },
      totals: totals,
      videos: switch (json['videos']) {
        final Map<String, Object?> v => VideoRewards.fromJson(v),
        _ => const VideoRewards(),
      },
      // Saves from before the trail get every waymark their km allow.
      wanderweg: switch (json['wanderweg']) {
        final Map<String, Object?> w => WanderwegProgress.fromJson(w),
        _ => WanderwegProgress.legacy(totals.distanceM, now ?? DateTime.now()),
      },
      // Saves from before the seal case: every forge use set one seal.
      // Recipe seals already set count as discovered recipes (the case
      // itself is read in ForgeState.fromJson).
      forge: switch (json['forge']) {
        final Map<String, Object?> f => ForgeState.fromJson(f),
        _ => ForgeState(placed: totals.forgeUses),
      }.discoveringAll([for (final c in owned) ...c.seals]),
      // Saves from before pouches start with an empty leash.
      pouches: switch (json['pouches']) {
        final Map<String, Object?> p => PouchState.fromJson(p),
        _ => const PouchState(),
      },
      // Saves from before messengers: none met yet.
      messengers: switch (json['messengers']) {
        final Map<String, Object?> m => MessengerState.fromJson(m),
        _ => const MessengerState(),
      },
      // Saves from before salves: an empty Vorrat.
      salves: SalveStock.fromJson(json['salves']),
    );
  }

  /// Marks a game whose starter already has [Companion.starterStats].
  static const String starterKey = 'starterStats';

  /// Games stored before [starterKey] give the original starter
  /// ([Companion.pebble]'s id, still owned) the uneven starter stats once;
  /// level, XP, Mut, seals and gait stay.
  static Companion _retuningStarter(Companion c, bool old) {
    if (!old || c.id != Companion.pebble().id || c.speciesId != 'pebble') {
      return c;
    }
    final s = Companion.starterStats;
    return c.copyWith(stride: s.stride, grit: s.grit, fortune: s.fortune);
  }

  /// Older saves kept a tank per companion; the one taken along becomes the
  /// shared bar and all the others are dropped.
  static Breath _legacyBreath(Map<String, Object?> active) => Breath(
    points: (active['breath']! as num).toDouble(),
    updatedAt: DateTime.parse(active['breathUpdatedAt']! as String),
  );
}

enum ForgeBlock {
  gone,

  /// The Forge opens at waymark 2 of the Wanderweg.
  locked,

  /// This level of forging or combining opens later on the trail.
  levelLocked,

  /// Already at L5, or a combined seal (those are not forged further).
  maxLevel,

  /// Not enough of these seals in the case (two equal ones to forge up).
  needsPair,

  /// Two single seals of different stats at the same level (1–5) needed,
  /// or a recipe seal and a single seal of its missing stat.
  badCombine,

  /// A level-2 recipe opens once its level-1 recipe was forged.
  recipeLocked,

  /// Glut outside the recipe's min–max.
  glutRange,
  notEnoughGlut,
  needsSplinters,

  /// Every charm socket holds a seal.
  noSocket,
  needsSpirit,
  notEnoughLp,
}

enum LevelBlock {
  gone,

  /// Already at [maxLevel].
  maxLevel,

  /// Not enough XP walked for the next level yet.
  needsXp,
  notEnoughLp,
}

enum SalveBlock {
  /// No Market yet, or the companion is no longer owned.
  gone,
  notEnoughLp,

  /// No salve of that size in the Vorrat.
  noneLeft,

  /// Mut is already at 100 %.
  fullSpirit,
}

enum PouchBlock {
  /// No pouch at that clip (opened or faded).
  gone,
  notEnoughLp,
}

enum TradeBlock {
  /// Offer already bought or drifted away, or companion no longer owned.
  gone,
  shelfFull,
  notEnoughLp,
  needsSpirit,

  /// The only companion on the shelf (Pebble for a new player).
  lastCompanion,
}

/// Answer to the movement / health notice. Only [allowed] lets real
/// movement earn LP.
enum MovementAccess { unasked, allowed, denied }

class AppSettings {
  const AppSettings({
    this.localeCode = 'en',
    this.kaching = true,
    this.movementAccess = MovementAccess.unasked,
    this.lastExportAt,
  });

  final String localeCode;
  final bool kaching;
  final MovementAccess movementAccess;

  /// When the save game was last exported on this device.
  final DateTime? lastExportAt;

  AppSettings copyWith({
    String? localeCode,
    bool? kaching,
    MovementAccess? movementAccess,
    DateTime? lastExportAt,
  }) => AppSettings(
    localeCode: localeCode ?? this.localeCode,
    kaching: kaching ?? this.kaching,
    movementAccess: movementAccess ?? this.movementAccess,
    lastExportAt: lastExportAt ?? this.lastExportAt,
  );

  Map<String, Object?> toJson() => {
    'localeCode': localeCode,
    'kaching': kaching,
    'movementAccess': movementAccess.name,
    if (lastExportAt case final d?) 'lastExportAt': d.toIso8601String(),
  };

  factory AppSettings.fromJson(Map<String, Object?> json) => AppSettings(
    localeCode: json['localeCode'] as String? ?? 'en',
    kaching: json['kaching'] as bool? ?? true,
    movementAccess:
        MovementAccess.values.asNameMap()[json['movementAccess']] ??
        MovementAccess.unasked,
    lastExportAt: DateTime.tryParse(json['lastExportAt'] as String? ?? ''),
  );
}
