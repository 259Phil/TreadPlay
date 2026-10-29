import 'dart:math';

import '../data/species.dart';
import 'companion.dart';
import 'wanderweg.dart';

/// What the Album remembers: every species ever owned, every species ever
/// owned as a Schimmer, and where the last Schimmer showed up in the Market.
class AlbumState {
  const AlbumState({
    this.owned = const {},
    this.shimmer = const {},
    this.lastShimmerAtM,
  });

  /// From what a save holds right now (saves from before the Album).
  factory AlbumState.fromCompanions(
    Iterable<Companion> companions, {
    double? lastShimmerAtM,
  }) => const AlbumState().noting(companions).withMark(lastShimmerAtM);

  /// Species ids ever owned.
  final Set<String> owned;

  /// Species ids ever owned as a Schimmer.
  final Set<String> shimmer;

  /// Lifetime metres when a Schimmer was last on offer; null until the
  /// first one (the count then starts at the save's current distance).
  final double? lastShimmerAtM;

  /// Also notes [companions] as owned (and Schimmer). Same object when
  /// nothing is new.
  AlbumState noting(Iterable<Companion> companions) {
    final o = {...owned, for (final c in companions) c.speciesId};
    final s = {
      ...shimmer,
      for (final c in companions)
        if (c.shimmer) c.speciesId,
    };
    if (o.length == owned.length && s.length == shimmer.length) return this;
    return AlbumState(owned: o, shimmer: s, lastShimmerAtM: lastShimmerAtM);
  }

  AlbumState withMark(double? atM) =>
      AlbumState(owned: owned, shimmer: shimmer, lastShimmerAtM: atM);

  Map<String, Object?> toJson() => {
    'owned': [...owned]..sort(),
    'shimmer': [...shimmer]..sort(),
    if (lastShimmerAtM case final m?) 'lastShimmerAtM': m,
  };

  factory AlbumState.fromJson(Map<String, Object?> json) => AlbumState(
    owned: {
      for (final s in json['owned'] as List<Object?>? ?? const [])
        if (s is String) s,
    },
    shimmer: {
      for (final s in json['shimmer'] as List<Object?>? ?? const [])
        if (s is String) s,
    },
    lastShimmerAtM: (json['lastShimmerAtM'] as num?)?.toDouble(),
  );
}

/// Lifetime km from which the Market can offer [s]: its own
/// [Species.unlockKm] or the waymark that opens its world, whichever is
/// later (the waymark may also ask for tasks). Owning a companion of a
/// world opens that world early.
double speciesOpenKm(Species s) {
  final world = WaymarkUnlocks.startWorlds.contains(s.world)
      ? 0.0
      : waymarks
                .where((w) => w.unlock.marketWorlds.contains(s.world))
                .firstOrNull
                ?.km ??
            0.0;
  return max(world, s.unlockKm);
}
