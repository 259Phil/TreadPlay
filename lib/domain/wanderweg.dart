import 'pouch.dart';
import 'world.dart';

/// What a waymark task counts. Counters of features that are not in the game
/// yet are [built] = false: their tasks are shown on the trail but count as
/// met, so nobody gets stuck on something they cannot do.
enum WaymarkCounter {
  /// Pouches of a colour opened (lifetime).
  brownPouchesOpened(built: true),
  copperPouchesOpened(built: true),
  turquoisePouchesOpened(built: true),

  /// Seals made in the Forge (lifetime; at least the seals owned now).
  sealsForged(built: true),

  /// Seals set into a companion (lifetime; at least the seals set now).
  sealsPlaced(built: true),

  /// Highest seal level ever held (at least the best seal owned now).
  bestSealLevel(built: true),

  // TODO(wanderweg): messengers are not built yet.
  messengersMet(built: false),

  /// Valid runs with a Sweet Spot share of at least 58 %.
  sweetSpot58Runs(built: true),

  /// Valid runs with a Sweet Spot share of at least 71 %.
  sweetSpot71Runs(built: true),

  /// Times all 4 leash clips held a pouch at once.
  leashFilled(built: true),

  /// Companions bought in the Market (lifetime).
  companionsBought(built: true),

  // TODO(wanderweg): levelling is not built yet (level stays 1).
  companionLevel(built: false),

  /// Successful combines (lifetime; at least the combined seals owned now).
  combines(built: true);

  const WaymarkCounter({required this.built});

  final bool built;
}

class WaymarkTask {
  const WaymarkTask(this.counter, this.target);

  final WaymarkCounter counter;
  final int target;
}

/// What a waymark opens. Only some have a feature behind them in this
/// version; see [WaymarkUnlocks].
enum WaymarkUnlock {
  brownPouch,
  forge,
  marketMedievalJungle,
  copperPouch,
  forgeL2,
  worldUnderwater,
  leashClip4,
  forgeL3,
  marketEgyptPirate,
  turquoisePouch,
  worldSteampunk,
  forgeL4,
  combineL3,
  navyPouch,
  worldSpaceRobot,
  forgeL5,
  shelfPlus2,
  combineL5,
  worldRococoCandy;

  /// True when this version has a feature that the unlock actually opens.
  /// Since the pouches and the leash every unlock is wired.
  bool get wired => true;

  /// Worlds whose species join the Market pool.
  List<World> get marketWorlds => switch (this) {
    marketMedievalJungle => const [World.medieval, World.jungle],
    worldUnderwater => const [World.underwater],
    marketEgyptPirate => const [World.egypt, World.pirate],
    worldSteampunk => const [World.steampunk],
    worldSpaceRobot => const [World.space, World.robot],
    worldRococoCandy => const [World.rococo, World.candy],
    _ => const [],
  };
}

class Waymark {
  const Waymark(this.number, this.km, this.unlock, [this.tasks = const []]);

  /// 1-based.
  final int number;

  /// Lifetime distance from valid runs, in km.
  final double km;
  final WaymarkUnlock unlock;
  final List<WaymarkTask> tasks;

  double get meters => km * 1000;
}

/// The 19 waymarks of the progression plan (section 5).
const List<Waymark> waymarks = [
  Waymark(1, 0.7, WaymarkUnlock.brownPouch),
  Waymark(2, 2.3, WaymarkUnlock.forge, [
    WaymarkTask(WaymarkCounter.brownPouchesOpened, 1),
  ]),
  Waymark(3, 4.1, WaymarkUnlock.marketMedievalJungle),
  Waymark(4, 6.8, WaymarkUnlock.copperPouch, [
    WaymarkTask(WaymarkCounter.sealsPlaced, 1),
  ]),
  Waymark(5, 9.4, WaymarkUnlock.forgeL2),
  Waymark(6, 13.2, WaymarkUnlock.worldUnderwater, [
    WaymarkTask(WaymarkCounter.messengersMet, 1),
    WaymarkTask(WaymarkCounter.sweetSpot58Runs, 1),
  ]),
  Waymark(7, 17.6, WaymarkUnlock.leashClip4),
  Waymark(8, 22.9, WaymarkUnlock.forgeL3, [
    WaymarkTask(WaymarkCounter.copperPouchesOpened, 1),
  ]),
  Waymark(9, 28.4, WaymarkUnlock.marketEgyptPirate),
  Waymark(10, 34.7, WaymarkUnlock.turquoisePouch, [
    WaymarkTask(WaymarkCounter.leashFilled, 1),
  ]),
  Waymark(11, 41.3, WaymarkUnlock.worldSteampunk),
  Waymark(12, 48.6, WaymarkUnlock.forgeL4, [
    WaymarkTask(WaymarkCounter.sealsForged, 5),
    WaymarkTask(WaymarkCounter.bestSealLevel, 3),
  ]),
  Waymark(13, 57.2, WaymarkUnlock.combineL3),
  Waymark(14, 66.9, WaymarkUnlock.navyPouch, [
    WaymarkTask(WaymarkCounter.companionsBought, 1),
    WaymarkTask(WaymarkCounter.turquoisePouchesOpened, 1),
  ]),
  Waymark(15, 77.4, WaymarkUnlock.worldSpaceRobot),
  Waymark(16, 88.8, WaymarkUnlock.forgeL5, [
    WaymarkTask(WaymarkCounter.companionLevel, 3),
    WaymarkTask(WaymarkCounter.combines, 1),
  ]),
  Waymark(17, 101.3, WaymarkUnlock.shelfPlus2),
  Waymark(18, 114.7, WaymarkUnlock.combineL5, [
    WaymarkTask(WaymarkCounter.sweetSpot71Runs, 3),
  ]),
  Waymark(19, 128.2, WaymarkUnlock.worldRococoCandy),
];

/// Current values of everything a task can count, read from the save. Every
/// value is retroactive: it comes from data the save already holds.
class WaymarkCounters {
  const WaymarkCounters({required this.distanceM, required this.values});

  final double distanceM;
  final Map<WaymarkCounter, int> values;

  int operator [](WaymarkCounter c) => values[c] ?? 0;

  /// Tasks of features not built yet count as met.
  bool met(WaymarkTask t) => !t.counter.built || this[t.counter] >= t.target;

  bool reaches(Waymark w) => distanceM >= w.meters && w.tasks.every(met);
}

/// Reached waymarks, kept in the save. Only ever grows: a waymark once
/// reached is never locked again, whatever happens to the counters.
class WanderwegProgress {
  const WanderwegProgress({
    this.reachedAt = const [],
    this.seen = 0,
    this.legacyForge = false,
  });

  /// Saves from before the trail existed: every waymark the distance allows,
  /// tasks not asked. The Forge stays open for them as it always was.
  factory WanderwegProgress.legacy(double distanceM, DateTime now) =>
      WanderwegProgress(
        reachedAt: [
          for (final w in waymarks)
            if (distanceM >= w.meters) now,
        ],
        legacyForge: true,
      );

  /// When waymark i+1 was reached. Its length is the reached count.
  final List<DateTime> reachedAt;

  /// Reached waymarks the player has already been told about.
  final int seen;

  /// The Forge was open before the trail existed.
  final bool legacyForge;

  int get reached => reachedAt.length;
  int get unseen => reached - seen.clamp(0, reached);
  bool get complete => reached >= waymarks.length;
  Waymark? get next => complete ? null : waymarks[reached];
  Waymark? get last => reached == 0 ? null : waymarks[reached - 1];

  bool hasReached(WaymarkUnlock u) =>
      waymarks.take(reached).any((w) => w.unlock == u);

  /// Reaches waymarks in order while [counters] allow; never removes any.
  WanderwegProgress advanced(WaymarkCounters counters, DateTime now) {
    var count = reached;
    while (count < waymarks.length && counters.reaches(waymarks[count])) {
      count++;
    }
    if (count == reached) return this;
    return WanderwegProgress(
      reachedAt: [...reachedAt, for (var i = reached; i < count; i++) now],
      seen: seen,
      legacyForge: legacyForge,
    );
  }

  WanderwegProgress markedSeen() => WanderwegProgress(
    reachedAt: reachedAt,
    seen: reached,
    legacyForge: legacyForge,
  );

  Map<String, Object?> toJson() => {
    'reachedAt': [for (final d in reachedAt) d.toIso8601String()],
    'seen': seen,
    if (legacyForge) 'legacyForge': true,
  };

  factory WanderwegProgress.fromJson(Map<String, Object?> json) {
    final reached = [
      for (final d in json['reachedAt'] as List<Object?>? ?? const [])
        DateTime.parse(d! as String),
    ].take(waymarks.length).toList();
    return WanderwegProgress(
      reachedAt: reached,
      seen: (json['seen'] as int? ?? 0).clamp(0, reached.length),
      legacyForge: json['legacyForge'] as bool? ?? false,
    );
  }
}

/// Feature flags from the trail: the Forge and its levels, pouch colours,
/// leash clips, Market worlds and shelf slots.
class WaymarkUnlocks {
  WaymarkUnlocks(
    this.progress, {
    this.forgeUsed = false,
    this.ownedWorlds = const {},
  });

  final WanderwegProgress progress;

  /// Forge already used or a seal set before the trail locked it.
  final bool forgeUsed;

  /// Worlds of companions on the shelf; their species stay in the Market.
  final Set<World> ownedWorlds;

  static const int baseShelfSlots = 12;

  /// Market pool before waymark 3. The plan leaves it open; Pebble's world.
  static const Set<World> startWorlds = {World.medieval};

  bool has(WaymarkUnlock u) => progress.hasReached(u);

  bool get forge =>
      has(WaymarkUnlock.forge) || progress.legacyForge || forgeUsed;

  Set<World> get marketWorlds => {
    ...startWorlds,
    ...ownedWorlds,
    for (final w in waymarks.take(progress.reached)) ...w.unlock.marketWorlds,
  };

  int get shelfSlots =>
      baseShelfSlots + (has(WaymarkUnlock.shelfPlus2) ? 2 : 0);

  bool get brownPouch => has(WaymarkUnlock.brownPouch);
  bool get copperPouch => has(WaymarkUnlock.copperPouch);
  bool get turquoisePouch => has(WaymarkUnlock.turquoisePouch);
  bool get navyPouch => has(WaymarkUnlock.navyPouch);

  /// Pouch colours a run can find, lowest first; empty before waymark 1.
  List<PouchColor> get pouchColors => [
    if (brownPouch) PouchColor.brown,
    if (copperPouch) PouchColor.copper,
    if (turquoisePouch) PouchColor.turquoise,
    if (navyPouch) PouchColor.navy,
  ];

  /// Highest seal level the Forge may make (1 with the Forge, up to 5).
  int get forgeLevel => !forge
      ? 0
      : has(WaymarkUnlock.forgeL5)
      ? 5
      : has(WaymarkUnlock.forgeL4)
      ? 4
      : has(WaymarkUnlock.forgeL3)
      ? 3
      : has(WaymarkUnlock.forgeL2)
      ? 2
      : 1;

  /// Highest seal level combining may make; 0 = not yet.
  int get combineLevel => has(WaymarkUnlock.combineL5)
      ? 5
      : has(WaymarkUnlock.combineL3)
      ? 3
      : 0;

  int get leashClips => has(WaymarkUnlock.leashClip4) ? 4 : 3;
}
