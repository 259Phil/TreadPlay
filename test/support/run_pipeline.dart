import 'dart:math';

import 'package:treadplay/domain/companion.dart';
import 'package:treadplay/domain/gps_filter.dart';
import 'package:treadplay/domain/movement_fuser.dart';
import 'package:treadplay/domain/run_engine.dart';

import 'synthetic_track.dart';

/// What the run screen showed at one second of a simulated run.
class ShownSample {
  const ShownSample({
    required this.second,
    required this.trueKmh,
    required this.speedKmh,
    required this.livePace,
    required this.oldSpeedKmh,
    required this.oldPace,
  });

  final int second;
  final double trueKmh;

  /// Live speed (gauge marker, gait check) and the tempo field now.
  final double speedKmh;
  final Duration? livePace;

  /// What the screen showed before: the filter's step speed and the
  /// average pace of the whole run in the tempo field.
  final double oldSpeedKmh;
  final Duration? oldPace;

  static double? kmhOf(Duration? pace) =>
      pace == null ? null : 3600000 / pace.inMilliseconds;
}

/// Feeds a [SyntheticTrack] through the same chain as the device (filter →
/// fuser → run engine), one tick per second, and records what the run
/// screen shows.
class RunPipeline {
  RunPipeline(
    this.track, {
    Companion? companion,
    this.dopplerNoiseMps,
    int seed = 1,
    Duration? liveWindow,
    this.legacy = false,
  }) : fuser = MovementFuser(liveWindow: liveWindow),
       _rng = Random(seed),
       engine = RunEngine(
         companion: companion ?? Companion.pebble(),
         breathAtStart: 100,
         tankSize: 100,
         startedAt: track.t0,
       );

  final SyntheticTrack track;

  /// Speed as before this change: the filter's speed of the last step.
  final bool legacy;

  /// Null: no Doppler speed (like many browsers). Otherwise the device
  /// reports the true speed with this much noise.
  final double? dopplerNoiseMps;
  final Random _rng;
  final GpsFilter filter = GpsFilter(checkFixAge: true);
  final MovementFuser fuser;
  final RunEngine engine;
  final List<ShownSample> shown = [];

  RunPipeline run() {
    final fixes = track.fixes;
    var i = 0;
    var trueMps = 0.0;
    var oldKmh = 0.0;
    final end = fixes.last.time.add(const Duration(seconds: 1));
    for (var s = 1; ; s++) {
      final now = track.t0.add(Duration(seconds: s));
      if (now.isAfter(end)) break;
      while (i < fixes.length && !fixes[i].time.isAfter(now)) {
        final f = fixes[i];
        trueMps = track.trueSpeeds[i];
        i++;
        final m = filter.add(f, receivedAt: f.time);
        if (filter.lastVerdict != GpsVerdict.accepted) continue;
        oldKmh = filter.speedMps * 3.6;
        final noise = dopplerNoiseMps;
        fuser.addGps(
          f.time,
          m,
          accuracyM: f.accuracyM,
          speedKmh: oldKmh,
          x: legacy ? null : filter.rawX,
          y: legacy ? null : filter.rawY,
          moving: filter.moving,
          dopplerMps: noise == null
              ? null
              : max(0.0, trueMps + noise * (_rng.nextDouble() * 2 - 1)),
        );
      }
      engine.add(fuser.tick(now));
      shown.add(
        ShownSample(
          second: s,
          trueKmh: trueMps * 3.6,
          speedKmh: engine.speedKmh,
          livePace: engine.livePace,
          oldSpeedKmh: oldKmh,
          oldPace: engine.pace,
        ),
      );
    }
    return this;
  }

  /// Samples from second [from] up to (not including) [to].
  List<ShownSample> between(int from, int to) => [
    for (final s in shown)
      if (s.second >= from && s.second < to) s,
  ];
}

/// Share of [values] within ±[tolerance] (relative) of [truth].
double shareWithin(Iterable<double?> values, double truth, double tolerance) {
  final v = values.toList();
  if (v.isEmpty) return 0;
  final ok = v.where(
    (x) => x != null && (x - truth).abs() <= truth * tolerance,
  );
  return ok.length / v.length;
}
