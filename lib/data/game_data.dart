import 'dart:math';

import '../domain/breath.dart';
import '../domain/companion.dart';
import '../domain/forge.dart';
import '../domain/market.dart';
import '../domain/run_summary.dart';
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
  });

  factory GameData.initial(DateTime now) {
    final pebble = Companion.pebble();
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

  /// Everything a waymark task can count, from what the save holds.
  WaymarkCounters get waymarkCounters {
    final setSeals = companions.fold<int>(
      0,
      (n, c) => n + c.charms.where((s) => s != null).length,
    );
    final forged = totals.forgeUses > setSeals ? totals.forgeUses : setSeals;
    final bought = companions.where(_fromMarket).length;
    final maxLevel = companions.fold<int>(
      1,
      (n, c) => c.level > n ? c.level : n,
    );
    return WaymarkCounters(
      distanceM: totals.distanceM,
      values: {
        WaymarkCounter.sealsForged: forged,
        WaymarkCounter.sealsPlaced: forged,
        WaymarkCounter.sweetSpot58Runs: totals.sweetSpot58Runs,
        WaymarkCounter.sweetSpot71Runs: totals.sweetSpot71Runs,
        WaymarkCounter.companionsBought: totals.companionsBought > bought
            ? totals.companionsBought
            : bought,
        WaymarkCounter.companionLevel: maxLevel,
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
  GameData advancingWanderweg(DateTime now) {
    final next = wanderweg.advanced(waymarkCounters, now);
    return identical(next, wanderweg) ? this : copyWith(wanderweg: next);
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

  /// Why a seal of [type] can't be set into [companionId] right now, or null
  /// if it can.
  ForgeBlock? forgeBlock(String companionId, SealType type) {
    final c = companions.where((c) => c.id == companionId).firstOrNull;
    if (c == null) return ForgeBlock.gone;
    if (!unlocks.forge) return ForgeBlock.locked;
    final cost = Forge.nextCost(c, type);
    if (cost == null) return ForgeBlock.statMaxed;
    if (c.freeSocket == null) return ForgeBlock.noSocket;
    if (c.spirit < 100) return ForgeBlock.needsSpirit;
    if (lp < cost) return ForgeBlock.notEnoughLp;
    return null;
  }

  /// Pays for a seal of [type] and sets it into the first free socket.
  /// Check [forgeBlock] first.
  GameData forging(String companionId, SealType type) {
    final c = companions.firstWhere((c) => c.id == companionId);
    return replaceCompanion(c.withCharm(c.freeSocket!, type.name)).copyWith(
      lp: lp - Forge.nextCost(c, type)!,
      totals: totals.addingForgeUse(),
    );
  }

  /// Stores [run] (newest first, capped) and counts it in [totals].
  GameData recordingRun(RunSummary run) => copyWith(
    runs: [run, ...runs].take(maxStoredRuns).toList(),
    totals: totals.addingRun(run),
  );

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

  /// Empties charm socket [slot] of [companionId]. LP are not refunded.
  GameData clearingSeal(String companionId, int slot) {
    final c = companions.firstWhere((c) => c.id == companionId);
    return replaceCompanion(c.withCharm(slot, null));
  }

  /// Keeps the current market until its drift is due, then rolls a new one.
  /// Offers only come from [marketWorlds].
  GameData withMarket(DateTime now, Random random) {
    final pool = marketWorlds;
    return copyWith(
      market:
          market?.drifted(now, random, worlds: pool) ??
          Market.rolled(now, random, worlds: pool),
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
  /// Check [sellBlock] first.
  GameData selling(String companionId, DateTime now) {
    final c = companions.firstWhere((c) => c.id == companionId);
    final next = c.id == activeCompanionId
        ? takingAlong(companions.firstWhere((o) => o.id != c.id).id, now)
        : this;
    return next.copyWith(
      lp: lp + market!.sellPriceOf(c),
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
    'breath': breath.toJson(),
    'runs': [for (final r in runs) r.toJson()],
    if (market case final m?) 'market': m.toJson(),
    'totals': totals.toJson(),
    'videos': videos.toJson(),
    'wanderweg': wanderweg.toJson(),
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
    final owned = [for (final c in companions) Companion.fromJson(c)];
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
    );
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

  /// Already +[Forge.maxPerStat] on this stat.
  statMaxed,

  /// Every charm socket holds a seal.
  noSocket,
  needsSpirit,
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
