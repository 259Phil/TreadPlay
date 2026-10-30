import 'dart:math';

import 'synthetic_track.dart';

/// Accuracy profiles as an iPhone reports them (Safari / Web app): coarse
/// steps (5, 10, 14, 16, 25, 35, 48, 65 m), held for a few seconds, starting
/// with 65 m while the GPS warms up.
enum IosSky {
  /// Open sky: mostly 5–16 m.
  open({5: 3, 10: 3, 14: 2, 16: 2}),

  /// Streets and trees: often 16–35 m, sometimes worse.
  mixed({10: 2, 14: 2, 16: 2, 25: 1, 35: 4, 48: 1, 65: 0.5}),

  /// Bad: mostly 35 m and worse.
  poor({16: 1, 25: 1, 35: 4, 48: 2, 65: 1});

  const IosSky(this.weights);

  final Map<int, double> weights;
}

/// Reported accuracies for [seconds] at 1 Hz.
List<double> iosAccuracies(int seed, int seconds, IosSky sky) {
  final r = Random(seed * 31 + sky.index);
  const coldStart = <double>[65, 65, 65, 48, 35, 35, 25, 16];
  final total = sky.weights.values.fold(0.0, (s, w) => s + w);
  double draw() {
    var x = r.nextDouble() * total;
    for (final e in sky.weights.entries) {
      x -= e.value;
      if (x <= 0) return e.key.toDouble();
    }
    return sky.weights.keys.last.toDouble();
  }

  final out = <double>[];
  var hold = 0;
  var cur = 16.0;
  for (var i = 0; i < seconds; i++) {
    if (i < coldStart.length) {
      out.add(coldStart[i]);
      continue;
    }
    if (hold-- <= 0) {
      cur = draw();
      hold = 2 + r.nextInt(8);
    }
    out.add(cur);
  }
  return out;
}

/// A run at [kmh] for [seconds] with iPhone-like accuracy and phone-like
/// noise: the true error is about a third of the reported radius per axis,
/// drifting slowly, plus 1.5 m jitter.
SyntheticTrack iosRun(
  int seed,
  double kmh,
  int seconds,
  IosSky sky, {
  int standS = 0,
}) {
  final t = SyntheticTrack(
    seed: seed,
    correlation: 0.99,
    jitterM: 1.5,
    sigmaShare: 1 / 3,
  );
  final acc = iosAccuracies(seed, standS + seconds, sky);
  if (standS > 0) t.moveWith(acc.sublist(0, standS), 0);
  if (seconds > 0) {
    t.moveWith(acc.sublist(standS), kmh / 3.6, turnDegPerS: 0.4);
  }
  return t;
}
