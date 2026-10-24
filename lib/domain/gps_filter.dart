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
/// accuracy as measurement variance → stationary/moving state machine.
///
/// While standing, nothing is summed: the filter holds an anchor and only
/// switches to moving once the smoothed position has left an escape radius
/// around it (scaled with the recent accuracy, larger indoors) and kept
/// moving away for several fixes. Jitter wanders back, real movement does
/// not. The distance from the anchor is then credited in one piece, so the
/// detection delay costs no distance. While moving, distance is summed in
/// steps of a few meters and the filter falls back to standing when the
/// position stops making progress (see [stopAfter], [progressWindow]).
class GpsFilter {
  GpsFilter({this.checkFixAge = false});

  /// Hard upper limit for the accuracy radius.
  static const double maxAccuracyM = 25;

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

  /// While moving, movement smaller than this share of the accuracy radius
  /// is jitter.
  static const double stationaryFactor = 1.25;
  static const double minStepM = 3;
  static const double maxStepGateM = 15;

  /// A step slower than this since the last counted point is drift, not
  /// walking (about 1.1 km/h).
  static const double minWalkMps = 0.3;

  /// Kalman process noise while standing (heavier smoothing of jitter) and
  /// the extra per m/s while moving (less lag at running pace).
  static const double stillProcessNoiseMps = 0.5;
  static const double speedProcessNoise = 0.25;

  /// Time constant of the light smoothing used to spot the start and end of
  /// movement (much less lag than the Kalman position).
  static const double escapeTauS = 3;

  /// Escape radius around the standing anchor: [escapeAccFactor] × the
  /// median reported accuracy of the last fixes (rejected ones included),
  /// growing quadratically above [noiseKneeM] because indoor fixes scatter
  /// much more than they claim; clamped to [minEscapeM]..[maxEscapeM].
  static const double escapeAccFactor = 1.5;
  static const double noiseKneeM = 12;
  static const double minEscapeM = 10;
  static const double maxEscapeM = 100;
  static const int accuracyHistory = 20;

  /// After leaving the radius, the position must keep moving away: at least
  /// [confirmS] later it has to be [minEscapeMps] × the elapsed time farther
  /// out, without falling back below [escapeHoldFactor] × the radius.
  static const double confirmS = 4;
  static const double minEscapeMps = 0.6;
  static const double escapeHoldFactor = 0.8;

  /// A candidate that neither confirms nor falls back within this time is a
  /// lasting position correction (unless it still drifts outward faster than
  /// [snapMps]): the anchor moves there, no distance.
  static const Duration escapeTimeout = Duration(seconds: 20);
  static const double snapMps = 0.2;

  /// Until the first movement after a (re)start, the anchor follows the
  /// smoothed position while it stays within [anchorFollow] × the radius,
  /// with time constant [anchorTauS]: the first fixes are often off.
  static const double anchorTauS = 30;
  static const double anchorFollow = 0.5;

  /// While moving, standing again when there was no counted step for
  /// [stopAfter] and less than [minMovingMps] progress since the last
  /// one, or when the lightly smoothed position made less than
  /// [minProgressMps] net progress over [progressWindow].
  static const Duration stopAfter = Duration(seconds: 10);
  static const double minMovingMps = 0.4;
  static const Duration progressWindow = Duration(seconds: 20);
  static const double minProgressMps = 0.3;

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
  // Reported accuracy of the last [accuracyHistory] fixes, for the escape
  // radius.
  final List<double> _accHist = [];

  // Standing or moving; whether movement was seen since the last restart.
  bool _moving = false;
  bool _hasMoved = false;

  // Lightly smoothed position, its last [progressWindow] (oldest first) and
  // the pending escape (time and distance when the radius was left).
  double _ex = 0;
  double _ey = 0;
  final List<(DateTime, double, double)> _trail = [];
  DateTime? _candTime;
  double _candD = 0;

  /// True while the filter believes the device is moving.
  bool get moving => _moving;

  /// True until the accuracy has settled.
  bool get warmingUp => !_warm;

  /// Walking speed in m/s at the latest accepted fix.
  ///
  /// 0 while standing. When moving, distance is counted in steps of a few
  /// meters, so speed comes from the last step (distance / its duration)
  /// instead of per-second deltas. When no new step follows in time, the
  /// speed falls to the progress since the last counted point.
  double get speedMps {
    final now = _fixTime;
    final since = now == null || _anchorTime == null
        ? 0.0
        : now.difference(_anchorTime!).inMilliseconds / 1000;
    if (!_warm || _var < 0 || !_moving) return 0;
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

    _lastTime = fix.time;
    _lastRawX = rx;
    _lastRawY = ry;
    _lastAcc = acc;

    // Kalman update, accuracy as standard deviation of the measurement.
    // Faster movement may turn harder: more process noise, less lag.
    final q = _moving
        ? processNoiseMps + speedProcessNoise * _segSpeed
        : stillProcessNoiseMps;
    _var += dt * q * q;
    final k = _var / (_var + acc * acc);
    _x += k * (rx - _x);
    _y += k * (ry - _y);
    _var *= 1 - k;
    final a = 1 - exp(-dt / escapeTauS);
    _ex += a * (rx - _ex);
    _ey += a * (ry - _ey);
    _trail.add((fix.time, _ex, _ey));
    while (_trail.length > 2 &&
        fix.time.difference(_trail[1].$1) >= progressWindow) {
      _trail.removeAt(0);
    }

    if (!_warm) {
      _noteWarm(acc);
      _setAnchor(fix.time);
      return (_warm ? GpsVerdict.accepted : GpsVerdict.warmingUp, 0);
    }

    final moved = _dist(_x, _y, _ax, _ay);
    if (!_moving) return _still(fix.time, dt, acc);

    final stepGate = (stationaryFactor * acc).clamp(minStepM, maxStepGateM);
    final sinceAnchor = fix.time.difference(_anchorTime ?? fix.time);
    final secs = sinceAnchor.inMilliseconds / 1000;
    final old = _trail.first;
    final span = fix.time.difference(old.$1);
    final stalled =
        span >= progressWindow &&
        _dist(_ex, _ey, old.$2, old.$3) <
            minProgressMps * span.inMilliseconds / 1000;
    if (stalled ||
        (moved < stepGate &&
            sinceAnchor >= stopAfter &&
            moved < minMovingMps * secs)) {
      // Standing again. The anchor stays at the last counted point: if
      // the walk goes on, the next start credits the rest of the last step
      // too.
      _stop();
      return (GpsVerdict.accepted, 0);
    }
    if (moved < stepGate) return (GpsVerdict.accepted, 0);
    _setAnchor(fix.time);
    if (secs <= 0 || moved / secs < minWalkMps) {
      _stop();
      return (GpsVerdict.accepted, 0);
    }
    _segSpeed = min(maxSpeedMps, moved / secs);
    _segSecs = secs;
    _speed = _segSpeed;
    return (GpsVerdict.accepted, moved);
  }

  /// Standing: count nothing until the position has clearly and steadily
  /// left the anchor, then credit the whole way from the anchor at once.
  (GpsVerdict, double) _still(DateTime t, double dt, double acc) {
    final noise = _medianAcc;
    final radius = (escapeAccFactor * noise * max(1.0, noise / noiseKneeM))
        .clamp(minEscapeM, maxEscapeM);
    final d = _dist(_ex, _ey, _ax, _ay);
    final cand = _candTime;
    if (cand == null) {
      if (d >= radius) {
        _candTime = t;
        _candD = d;
        return (GpsVerdict.accepted, 0);
      }
      if (!_hasMoved && d < anchorFollow * radius) {
        final b = 1 - exp(-dt / anchorTauS);
        _ax += b * (_x - _ax);
        _ay += b * (_y - _ay);
      }
      return (GpsVerdict.accepted, 0);
    }
    if (d < escapeHoldFactor * radius) {
      _candTime = null;
      return (GpsVerdict.accepted, 0);
    }
    final secs = t.difference(cand).inMilliseconds / 1000;
    if (secs >= confirmS && d >= _candD + minEscapeMps * secs) {
      _moving = true;
      _hasMoved = true;
      _candTime = null;
      _segSpeed = min(maxSpeedMps, (d - _candD) / secs);
      _segSecs = secs;
      _speed = _segSpeed;
      // Jump the Kalman position to the lightly smoothed one so moving
      // starts without the standing lag.
      _x = _ex;
      _y = _ey;
      _var = max(_var, acc * acc / 4);
      _setAnchor(t);
      return (GpsVerdict.accepted, d);
    }
    if (t.difference(cand) > escapeTimeout) {
      if (d < _candD + snapMps * secs) {
        // Stayed out without moving on: a lasting position correction.
        _candTime = null;
        _ax = _x = _ex;
        _ay = _y = _ey;
      } else {
        // Slow but steady: keep watching from here.
        _candTime = t;
        _candD = d;
      }
    }
    return (GpsVerdict.accepted, 0);
  }

  void _stop() {
    _moving = false;
    _segSpeed = 0;
    _speed = 0;
    _candTime = null;
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
    _moving = false;
    _hasMoved = false;
    _candTime = null;
    _trail.clear();
    _ex = rx;
    _ey = ry;
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
    _accHist.add(acc);
    if (_accHist.length > accuracyHistory) _accHist.removeAt(0);
    _recentAcc.add(acc);
    if (_recentAcc.length > 10) _recentAcc.removeAt(0);
  }

  double get _medianAcc {
    if (_accHist.isEmpty) return unknownAccuracyM;
    final sorted = [..._accHist]..sort();
    return sorted[sorted.length ~/ 2];
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
