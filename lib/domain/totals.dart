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
  });

  /// Built once from the runs of a save that has no totals yet.
  factory Totals.fromRuns(Iterable<RunSummary> runs) =>
      runs.fold(const Totals(), (t, r) => t.addingRun(r));

  final double distanceM;

  /// LP earned by running (videos and sales not included).
  final double lp;
  final int runs;

  /// Seals set in the Forge.
  final int forgeUses;

  Totals addingRun(RunSummary run) => run.valid
      ? Totals(
          distanceM: distanceM + run.distanceM,
          lp: lp + run.lp,
          runs: runs + 1,
          forgeUses: forgeUses,
        )
      : this;

  Totals addingForgeUse() => Totals(
    distanceM: distanceM,
    lp: lp,
    runs: runs,
    forgeUses: forgeUses + 1,
  );

  Map<String, Object?> toJson() => {
    'distanceM': distanceM,
    'lp': lp,
    'runs': runs,
    'forgeUses': forgeUses,
  };

  factory Totals.fromJson(Map<String, Object?> json) => Totals(
    distanceM: (json['distanceM'] as num? ?? 0).toDouble(),
    lp: (json['lp'] as num? ?? 0).toDouble(),
    runs: json['runs'] as int? ?? 0,
    forgeUses: json['forgeUses'] as int? ?? 0,
  );
}
