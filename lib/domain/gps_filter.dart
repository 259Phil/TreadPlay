import 'dart:math';

/// One raw position fix as delivered by the platform.
class GpsFix {
  const GpsFix({
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
  });

  /// When the fix was taken (platform timestamp).
  final DateTime time;
  final double latitude;
  final double longitude;

  /// Horizontal accuracy radius in meters (0 or negative = unknown).
  final double accuracyM;
}

/// Why a fix did not add distance.
enum GpsVerdict {
  /// Counted (distance may still be 0 while standing).
  accepted,

  /// Same or older timestamp than the previous fix.
  duplicate,

  /// Cached fix older than [GpsFilter.maxFixAge].
  stale,

  /// Accuracy radius too large.
  inaccurate,

  /// Still settling after the start or after a gap.
  warmingUp,

  /// Implied speed or acceleration not possible on foot.
  jump,

  /// First fix after a long gap: position re-anchored, no distance.
  gap,
}

/// Turns noisy GPS fixes into walked distance.
///
/// Pure Dart and stateful for one run. Only the last smoothed position is
/// held in memory, no route is kept.
///
/// Pipeline per fix: duplicate/stale check → accuracy gate (adaptive) →
/// warm-up → jump gate (speed and acceleration) → Kalman smoothing with the
/// accuracy as measurement variance → stationary gate (movement smaller than
/// the accuracy radius adds nothing).
class GpsFilter {
  GpsFilter({this.checkFixAge = false});

  /// Hard upper limit for the accuracy radius.
  static const double maxAccuracyM = 30;

  /// Adaptive gate: a fix may be at most this much worse than the recent
  /// typical accuracy, but the gate never drops below [minAccuracyGateM].
  static const double adaptiveAccuracyFactor = 2.5;
  static const double minAccuracyGateM = 15;

  /// Warm-up ends after this many consecutive usable fixes, or at once with
  /// one fix at or below [warmUpGoodAccuracyM].
  static const int warmUpFixes = 3;
  static const double warmUpGoodAccuracyM = 10;

  /// Faster than this between two fixes is not possible on foot (matches the
  /// vehicle limit of the run engine, 30 km/h).
  static const double maxSpeedMps = 30 / 3.6;

  /// Human acceleration limit used for the jump gate.
  static const double maxAccelMps2 = 3;

  /// A longer silence (tab in background, tunnel) re-anchors without
  /// distance.
  static const Duration maxGap = Duration(seconds: 10);

  /// On Web, fixes older than this when they arrive are cached ones.
  static const Duration maxFixAge = Duration(seconds: 10);

  /// After this many consecutive jump rejections that agree with each other,
  /// the position is re-anchored (the filter was wrong, not the fixes).
  static const int reanchorAfterJumps = 3;

  /// Kalman process noise: how fast the true position may drift (m/s).
  static const double processNoiseMps = 1.0;

  /// Movement smaller than this share of the accuracy radius is jitter.
  static const double stationaryFactor = 1.0;
  static const double minStepM = 3;
  static const double maxStepGateM = 15;

  /// A step slower than this since the last counted point is drift, not
  /// walking (about 1.1 km/h).
  static const double minWalkMps = 0.3;

  /// While nearly in place for this long, the anchor follows the smoothed
  /// position so the next real step is not judged as slow drift.
  static const Duration anchorRefresh = Duration(seconds: 20);

  /// Accuracy used when the platform reports none.
  static const double unknownAccuracyM = 20;

  static const double _earthR = 6371000;

  /// Reject fixes that arrive much later than they were taken (Web).
  final bool checkFixAge;

  // Counters for the developer readout.
  int accepted = 0;
  int rejected = 0;
  int jumps = 0;
  int gaps = 0;
  double? lastAccuracyM;
  GpsVerdict? lastVerdict;

  // Local metric frame (equirectangular around the first fix).
  double? _lat0;
  double? _lon0;
  double _cosLat0 = 1;

  // Kalman state (position only, per axis same variance).
  double _x = 0;
  double _y = 0;
  double _var = -1; // < 0: not initialised

  // Anchor: last smoothed point that was counted.
  double _ax = 0;
  double _ay = 0;
  DateTime? _anchorTime;

  // Last accepted raw fix for the jump gate.
  DateTime? _lastTime;
  double _lastRawX = 0;
  double _lastRawY = 0;
  double _lastAcc = 0;
  double _speed = 0;

  // Consecutive jump rejections and the first of them.
  int _jumpRun = 0;
  double _jumpX = 0;
  double _jumpY = 0;
  DateTime? _jumpTime;

  // Speed of the last counted step and how long it took.
  double _segSpeed = 0;
  double _segSecs = 0;
  DateTime? _fixTime;

  int _warmGood = 0;
  bool _warm = false;
  final List<double> _recentAcc = [];

  /// True until the accuracy has settled.
  bool get warmingUp => !_warm;

  /// Walking speed in m/s at the latest accepted fix.
  ///
  /// Distance is counted in steps of a few meters, so speed comes from the
  /// last step (distance / its duration) instead of per-second deltas. When
  /// no new step follows in time, the speed falls to the progress since the
  /// last counted point, which reaches 0 while standing.
  double get speedMps {
    final now = _fixTime;
    final since = now == null || _anchorTime == null
        ? 0.0
        : now.difference(_anchorTime!).inMilliseconds / 1000;
    if (!_warm || _var < 0) return 0;
    if (since <= max(_segSecs * 1.5, 2)) return _segSpeed;
    if (since <= 0) return 0;
    final progress = _dist(_x, _y, _ax, _ay) / since;
    return min(_segSpeed, progress);
  }

  /// Feeds one fix and returns the distance it adds in meters (0 when not
  /// counted). [receivedAt] is only used when [checkFixAge] is on.
  double add(GpsFix fix, {DateTime? receivedAt}) {
    final verdict = _classify(fix, receivedAt);
    lastVerdict = verdict.$1;
    if (verdict.$1 == GpsVerdict.accepted) {
      _fixTime = fix.time;
      accepted++;
    } else {
      rejected++;
    }
    return verdict.$2;
  }

  (GpsVerdict, double) _classify(GpsFix fix, DateTime? receivedAt) {
    final acc = fix.accuracyM > 0 ? fix.accuracyM : unknownAccuracyM;
    lastAccuracyM = acc;
    final last = _lastTime;
    if (last != null && !fix.time.isAfter(last)) {
      return (GpsVerdict.duplicate, 0);
    }
    if (checkFixAge &&
        receivedAt != null &&
        receivedAt.difference(fix.time) > maxFixAge) {
      return (GpsVerdict.stale, 0);
    }
    final gate = _accuracyGate;
    _rememberAcc(acc);
    if (acc > gate) return (GpsVerdict.inaccurate, 0);

    _lat0 ??= fix.latitude;
    _lon0 ??= fix.longitude;
    if (_cosLat0 == 1) _cosLat0 = cos(_lat0! * pi / 180);
    final rx = (fix.longitude - _lon0!) * pi / 180 * _earthR * _cosLat0;
    final ry = (fix.latitude - _lat0!) * pi / 180 * _earthR;

    // Long silence: start over from this fix, no distance across the gap.
    if (last != null && fix.time.difference(last) > maxGap) {
      gaps++;
      _restart(fix.time, rx, ry, acc);
      _warm = false;
      _warmGood = 0;
      _noteWarm(acc);
      return (GpsVerdict.gap, 0);
    }

    if (_var < 0) {
      _restart(fix.time, rx, ry, acc);
      _noteWarm(acc);
      return (_warm ? GpsVerdict.accepted : GpsVerdict.warmingUp, 0);
    }

    final dt = fix.time.difference(last!).inMilliseconds / 1000;
    final rawD = _dist(rx, ry, _lastRawX, _lastRawY);
    // Part of the jump that the two accuracy radii cannot explain.
    final excess = max(0.0, rawD - 0.5 * (acc + _lastAcc));
    final allowed = min(maxSpeedMps, _speed + maxAccelMps2 * dt);
    if (excess / dt > allowed) {
      jumps++;
      if (_jumpRun == 0 || !_agreesWithJump(rx, ry, fix.time, acc)) {
        _jumpRun = 1;
        _jumpX = rx;
        _jumpY = ry;
        _jumpTime = fix.time;
        return (GpsVerdict.jump, 0);
      }
      _jumpRun++;
      _jumpX = rx;
      _jumpY = ry;
      _jumpTime = fix.time;
      if (_jumpRun >= reanchorAfterJumps) {
        _restart(fix.time, rx, ry, acc);
        return (GpsVerdict.gap, 0);
      }
      return (GpsVerdict.jump, 0);
    }
    _jumpRun = 0;

    _speed = min(maxSpeedMps, rawD / dt);
    _lastTime = fix.time;
    _lastRawX = rx;
    _lastRawY = ry;
    _lastAcc = acc;

    // Kalman update, accuracy as standard deviation of the measurement.
    _var += dt * processNoiseMps * processNoiseMps;
    final k = _var / (_var + acc * acc);
    _x += k * (rx - _x);
    _y += k * (ry - _y);
    _var *= 1 - k;

    if (!_warm) {
      _noteWarm(acc);
      _setAnchor(fix.time);
      return (_warm ? GpsVerdict.accepted : GpsVerdict.warmingUp, 0);
    }

    final moved = _dist(_x, _y, _ax, _ay);
    final stepGate = (stationaryFactor * acc).clamp(minStepM, maxStepGateM);
    final sinceAnchor = fix.time.difference(_anchorTime ?? fix.time);
    if (moved < stepGate) {
      if (sinceAnchor > anchorRefresh && moved < stepGate / 2) {
        _setAnchor(fix.time);
      }
      return (GpsVerdict.accepted, 0);
    }
    final secs = sinceAnchor.inMilliseconds / 1000;
    _setAnchor(fix.time);
    if (secs <= 0 || moved / secs < minWalkMps) {
      _segSpeed = 0;
      return (GpsVerdict.accepted, 0);
    }
    _segSpeed = min(maxSpeedMps, moved / secs);
    _segSecs = secs;
    return (GpsVerdict.accepted, moved);
  }

  bool _agreesWithJump(double rx, double ry, DateTime t, double acc) {
    final jt = _jumpTime;
    if (jt == null) return false;
    final dt = t.difference(jt).inMilliseconds / 1000;
    if (dt <= 0) return false;
    final d = max(0.0, _dist(rx, ry, _jumpX, _jumpY) - acc);
    return d / dt <= maxSpeedMps;
  }

  void _setAnchor(DateTime t) {
    _ax = _x;
    _ay = _y;
    _anchorTime = t;
  }

  void _restart(DateTime t, double rx, double ry, double acc) {
    _x = rx;
    _y = ry;
    _setAnchor(t);
    _var = acc * acc;
    _lastTime = t;
    _lastRawX = rx;
    _lastRawY = ry;
    _lastAcc = acc;
    _speed = 0;
    _jumpRun = 0;
    _segSpeed = 0;
    _segSecs = 0;
    _fixTime = t;
  }

  void _noteWarm(double acc) {
    if (_warm) return;
    if (acc <= warmUpGoodAccuracyM) {
      _warm = true;
      return;
    }
    _warmGood++;
    if (_warmGood >= warmUpFixes) _warm = true;
  }

  void _rememberAcc(double acc) {
    _recentAcc.add(acc);
    if (_recentAcc.length > 10) _recentAcc.removeAt(0);
  }

  double get _accuracyGate {
    if (_recentAcc.length < 3) return maxAccuracyM;
    final sorted = [..._recentAcc]..sort();
    final median = sorted[sorted.length ~/ 2];
    return (median * adaptiveAccuracyFactor).clamp(
      minAccuracyGateM,
      maxAccuracyM,
    );
  }

  static double _dist(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }
}
