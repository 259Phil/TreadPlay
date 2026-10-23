import 'run_summary.dart';

/// Lifetime counters for later milestones. Kept apart from the run list, so
/// they are not capped at the stored runs and survive "Erase local record".
/// Only valid runs count.
class Totals {
  const Totals({
    this.distanceM = 0,
    this.lp = 0,
    this.runs = 0,
    this.forgeUses = 0,
    this.sweetSpot58Runs = 0,
    this.sweetSpot71Runs = 0,
    this.companionsBought = 0,
  });

  /// Built once from the runs of a save that has no totals yet.
  factory Totals.fromRuns(Iterable<RunSummary> runs) =>
      runs.fold(const Totals(), (t, r) => t.addingRun(r));

  final double distanceM;

  /// LP earned by running (videos and sales not included).
  final double lp;
  final int runs;

  /// Seals made in the Forge: bought L1, forged up, combined or melted
  /// from splinters. Saves from before seal levels counted each seal set.
  final int forgeUses;

  /// Valid runs with a Sweet Spot share of at least 58 % / 71 % (Wanderweg).
  final int sweetSpot58Runs;
  final int sweetSpot71Runs;

  /// Companions bought in the Market.
  final int companionsBought;

  static bool _share(RunSummary r, double min) =>
      r.valid && (r.sweetSpotShare ?? 0) >= min - 1e-9;

  Totals addingRun(RunSummary run) => run.valid
      ? copyWith(
          distanceM: distanceM + run.distanceM,
          lp: lp + run.lp,
          runs: runs + 1,
          sweetSpot58Runs: sweetSpot58Runs + (_share(run, 0.58) ? 1 : 0),
          sweetSpot71Runs: sweetSpot71Runs + (_share(run, 0.71) ? 1 : 0),
        )
      : this;

  Totals addingForgeUse() => copyWith(forgeUses: forgeUses + 1);

  Totals addingPurchase() => copyWith(companionsBought: companionsBought + 1);

  Totals copyWith({
    double? distanceM,
    double? lp,
    int? runs,
    int? forgeUses,
    int? sweetSpot58Runs,
    int? sweetSpot71Runs,
    int? companionsBought,
  }) => Totals(
    distanceM: distanceM ?? this.distanceM,
    lp: lp ?? this.lp,
    runs: runs ?? this.runs,
    forgeUses: forgeUses ?? this.forgeUses,
    sweetSpot58Runs: sweetSpot58Runs ?? this.sweetSpot58Runs,
    sweetSpot71Runs: sweetSpot71Runs ?? this.sweetSpot71Runs,
    companionsBought: companionsBought ?? this.companionsBought,
  );

  Map<String, Object?> toJson() => {
    'distanceM': distanceM,
    'lp': lp,
    'runs': runs,
    'forgeUses': forgeUses,
    'sweetSpot58Runs': sweetSpot58Runs,
    'sweetSpot71Runs': sweetSpot71Runs,
    'companionsBought': companionsBought,
  };

  /// Counters missing in older saves are counted once from [runs] (Sweet
  /// Spot) and [boughtOnShelf] (market companions still owned).
  factory Totals.fromJson(
    Map<String, Object?> json, {
    Iterable<RunSummary> runs = const [],
    int boughtOnShelf = 0,
  }) {
    final retro = json.containsKey('sweetSpot58Runs')
        ? null
        : Totals.fromRuns(runs);
    return Totals(
      distanceM: (json['distanceM'] as num? ?? 0).toDouble(),
      lp: (json['lp'] as num? ?? 0).toDouble(),
      runs: json['runs'] as int? ?? 0,
      forgeUses: json['forgeUses'] as int? ?? 0,
      sweetSpot58Runs:
          json['sweetSpot58Runs'] as int? ?? retro?.sweetSpot58Runs ?? 0,
      sweetSpot71Runs:
          json['sweetSpot71Runs'] as int? ?? retro?.sweetSpot71Runs ?? 0,
      companionsBought: json['companionsBought'] as int? ?? boughtOnShelf,
    );
  }
}
