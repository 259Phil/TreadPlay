import 'dart:math';

/// One raw position fix as delivered by the platform.
class GpsFix {
  const GpsFix({
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    this.speedMps,
  });

  /// When the fix was taken (platform timestamp).
  final DateTime time;
  final double latitude;
  final double longitude;

  /// Horizontal accuracy radius in meters (0 or negative = unknown).
  final double accuracyM;

  /// Speed the receiver measured (Doppler, `coords.speed`) in m/s; null or
  /// not positive when unknown.
  final double? speedMps;
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
///
/// The receiver speed (`coords.speed`, Doppler) is independent of position
/// drift: when it confirms walking or running, the filter starts at once
/// with a small radius, accepts coarser fixes (iPhones outdoors report 35
/// or 48 m), bridges short gaps and predicts the position with it (no lag).
/// Above the foot limit it means a vehicle: nothing counts.
class GpsFilter {
  GpsFilter({this.checkFixAge = false});

  /// Hard upper limit for the accuracy radius while moving. iPhones
  /// outdoors often report 35 or 48 m for fixes that are much better than
  /// that; only the cold-start values (65 m and worse) are useless.
  static const double maxAccuracyM = 50;

  /// Hard limit while standing without receiver speed: indoors the radius
  /// says 25–45 m and the fixes scatter even more, so those must not start
  /// a walk.
  static const double stillMaxAccuracyM = 25;

  /// Limit while moving without receiver speed.
  static const double movingMaxAccuracyM = 35;

  /// Adaptive gate: a fix may be at most this much worse than the recent
  /// typical accuracy, but the gate never drops below [minAccuracyGateM].
  static const double adaptiveAccuracyFactor = 2.5;
  static const double minAccuracyGateM = 25;
  static const double stillMinAccuracyGateM = 15;

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
  /// distance. Shorter ones (a few inaccurate fixes in a row) are bridged
  /// with the straight line when the jump gate finds it plausible.
  static const Duration maxGap = Duration(seconds: 30);
  static const Duration stillMaxGap = Duration(seconds: 10);

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

  /// Receiver speed (Doppler) that confirms walking or running. Phones
  /// report it from the carrier frequency shift, not from positions, so
  /// position drift does not raise it. [dopplerFixes] fixes in a row must
  /// agree.
  static const double minDopplerMps = 1.0;
  static const int dopplerFixes = 3;

  /// Escape radius while the receiver speed confirms movement: the current
  /// typical accuracy, clamped to [minEscapeM]..[dopplerEscapeMaxM], with
  /// [dopplerConfirmS] confirmation.
  static const double dopplerEscapeMaxM = 20;
  static const double dopplerConfirmS = 2;

  /// While moving, the Kalman position is predicted with the velocity of
  /// the raw fixes over the last [velocityWindow] (least squares, at least
  /// [minVelocitySpan]); without it the smoothed position lags tens of
  /// meters behind at running pace with 35 m accuracy.
  static const Duration velocityWindow = Duration(seconds: 10);
  static const Duration minVelocitySpan = Duration(seconds: 4);

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
  int inaccurate = 0;
  int stale = 0;
  int duplicates = 0;
  int warmUps = 0;
  double? lastDopplerMps;
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

  // Consecutive accepted fixes whose receiver speed says moving, and the
  // way they add up to (speed × time) while standing.
  int _dopRun = 0;
  DateTime? _lastSeen;
  double _dopDist = 0;

  // How far the anchor followed the position before the first movement.
  double _followed = 0;

  // Lightly smoothed position, its last [progressWindow] (oldest first) and
  // the pending escape (time and distance when the radius was left).
  double _ex = 0;
  double _ey = 0;
  final List<(DateTime, double, double)> _trail = [];
  DateTime? _candTime;
  double _candD = 0;

  // Raw accepted fixes of the last [velocityWindow] (oldest first).
  final List<(DateTime, double, double)> _raw = [];

  /// Last accepted fix in meters east and north of the first fix, raw (not
  /// smoothed), for the live speed.
  double get rawX => _lastRawX;
  double get rawY => _lastRawY;

  /// True while the filter believes the device is moving.
  bool get moving => _moving;

  /// Moving, or the receiver speed says so: poorer fixes and longer gaps
  /// are usable then.
  bool get _relaxed => _moving || dopplerMoving;

  /// Accuracy limit for the next fix (developer readout).
  double get accuracyGateM => _accuracyGate;

  /// True while the receiver speed (Doppler) confirms movement.
  bool get dopplerMoving => _dopRun >= dopplerFixes;

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
      switch (verdict.$1) {
        case GpsVerdict.inaccurate:
          inaccurate++;
        case GpsVerdict.stale:
          stale++;
        case GpsVerdict.duplicate:
          duplicates++;
        case GpsVerdict.warmingUp:
          warmUps++;
        default:
          break;
      }
    }
    return verdict.$2;
  }

  (GpsVerdict, double) _classify(GpsFix fix, DateTime? receivedAt) {
    final acc = fix.accuracyM > 0 ? fix.accuracyM : unknownAccuracyM;
    lastAccuracyM = acc;
    final dop = fix.speedMps;
    lastDopplerMps = dop != null && dop > 0 ? dop : null;
    final last = _lastTime;
    if (last != null && !fix.time.isAfter(last)) {
      return (GpsVerdict.duplicate, 0);
    }
    if (checkFixAge &&
        receivedAt != null &&
        receivedAt.difference(fix.time) > maxFixAge) {
      return (GpsVerdict.stale, 0);
    }
    // Receiver speed counts from every fresh fix, also an inaccurate one:
    // it does not come from the position.
    final seen = _lastSeen;
    _lastSeen = fix.time;
    if (dop != null && dop >= minDopplerMps && dop <= maxSpeedMps) {
      _dopRun++;
      if (!_moving && seen != null) {
        final ds = fix.time.difference(seen).inMilliseconds / 1000;
        _dopDist += dop * min(ds, 2.0);
      }
    } else {
      _dopRun = 0;
      _dopDist = 0;
    }
    final gate = _accuracyGate;
    _rememberAcc(acc);
    if (acc > gate) return (GpsVerdict.inaccurate, 0);

    _lat0 ??= fix.latitude;
    _lon0 ??= fix.longitude;
    if (_cosLat0 == 1) _cosLat0 = cos(_lat0! * pi / 180);
    final rx = (fix.longitude - _lon0!) * pi / 180 * _earthR * _cosLat0;
    final ry = (fix.latitude - _lat0!) * pi / 180 * _earthR;

    // Receiver speed above the foot limit: a vehicle. Nothing counts, and
    // the position starts over here so the ride is not bridged later.
    if (dop != null && dop > maxSpeedMps) {
      jumps++;
      _restart(fix.time, rx, ry, acc);
      return (GpsVerdict.jump, 0);
    }

    // Long silence: start over from this fix, no distance across the gap.
    if (last != null &&
        fix.time.difference(last) > (_relaxed ? maxGap : stillMaxGap)) {
      gaps++;
      _restart(fix.time, rx, ry, acc);
      _dopRun = 0;
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

    _raw.add((fix.time, rx, ry));
    while (_raw.length > 2 &&
        fix.time.difference(_raw.first.$1) > velocityWindow) {
      _raw.removeAt(0);
    }

    // Kalman update, accuracy as standard deviation of the measurement.
    // Faster movement may turn harder: more process noise, less lag.
    final q = _moving
        ? processNoiseMps + speedProcessNoise * _segSpeed
        : stillProcessNoiseMps;
    if (_moving && dopplerMoving) {
      final v = _rawVelocity(dop);
      if (v != null) {
        _x += v.$1 * dt;
        _y += v.$2 * dt;
      }
    }
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
    // While the receiver speed says moving, slow position progress is
    // GPS lag, not a stop.
    if (!dopplerMoving &&
        (stalled ||
            (moved < stepGate &&
                sinceAnchor >= stopAfter &&
                moved < minMovingMps * secs))) {
      // Standing again. The anchor stays at the last counted point: if
      // the walk goes on, the next start credits the rest of the last step
      // too.
      _stop();
      return (GpsVerdict.accepted, 0);
    }
    if (moved < stepGate) return (GpsVerdict.accepted, 0);
    _setAnchor(fix.time);
    // Coarse accuracy lets single fixes pass the jump gate even in a car;
    // over [velocityWindow] the raw fixes give the speed away.
    if (_rawSpeed() > maxSpeedMps) {
      jumps++;
      _stop();
      return (GpsVerdict.jump, 0);
    }
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
    final doppler = dopplerMoving;
    final radius = doppler
        ? noise.clamp(minEscapeM, dopplerEscapeMaxM)
        : (escapeAccFactor * noise * max(1.0, noise / noiseKneeM)).clamp(
            minEscapeM,
            maxEscapeM,
          );
    final d = _dist(_ex, _ey, _ax, _ay);
    final cand = _candTime;
    if (cand == null) {
      if (d >= radius) {
        _candTime = t;
        _candD = d;
        return (GpsVerdict.accepted, 0);
      }
      if (!_hasMoved && !doppler && d < anchorFollow * radius) {
        final b = 1 - exp(-dt / anchorTauS);
        final fx = b * (_x - _ax), fy = b * (_y - _ay);
        _ax += fx;
        _ay += fy;
        _followed += sqrt(fx * fx + fy * fy);
      }
      return (GpsVerdict.accepted, 0);
    }
    if (d < escapeHoldFactor * radius) {
      _candTime = null;
      return (GpsVerdict.accepted, 0);
    }
    final secs = t.difference(cand).inMilliseconds / 1000;
    if (secs >= (doppler ? dopplerConfirmS : confirmS) &&
        d >= _candD + minEscapeMps * secs) {
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
      // The way the anchor followed was the start of this movement. With
      // the receiver speed confirming it, the speed × time since then is
      // the better measure when the lagging positions show less.
      var credit = d + _followed;
      if (doppler) credit = max(credit, _dopDist);
      _followed = 0;
      _dopDist = 0;
      _setAnchor(t);
      return (GpsVerdict.accepted, credit);
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

  /// Speed of the raw fixes over [velocityWindow] in m/s, 0 when unknown.
  double _rawSpeed() {
    final v = _rawVelocity(null, clamp: false);
    return v == null ? 0 : sqrt(v.$1 * v.$1 + v.$2 * v.$2);
  }

  /// Least-squares velocity of the raw fixes in m/s, scaled to the receiver
  /// speed when that confirms movement; null with too little data.
  (double, double)? _rawVelocity(double? dop, {bool clamp = true}) {
    if (_raw.length < 3) return null;
    final t0 = _raw.first.$1;
    if (_raw.last.$1.difference(t0) < minVelocitySpan) return null;
    var st = 0.0, sx = 0.0, sy = 0.0;
    for (final r in _raw) {
      st += r.$1.difference(t0).inMilliseconds / 1000;
      sx += r.$2;
      sy += r.$3;
    }
    final n = _raw.length;
    final mt = st / n, mx = sx / n, my = sy / n;
    var stt = 0.0, stx = 0.0, sty = 0.0;
    for (final r in _raw) {
      final t = r.$1.difference(t0).inMilliseconds / 1000 - mt;
      stt += t * t;
      stx += t * (r.$2 - mx);
      sty += t * (r.$3 - my);
    }
    if (stt <= 0) return null;
    var vx = stx / stt, vy = sty / stt;
    var v = sqrt(vx * vx + vy * vy);
    if (v <= 0) return null;
    if (!clamp) return (vx, vy);
    var target = min(v, maxSpeedMps);
    if (dopplerMoving && dop != null && dop > 0) target = min(dop, maxSpeedMps);
    return (vx / v * target, vy / v * target);
  }

  void _stop() {
    _moving = false;
    _dopDist = 0;
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
    _raw.clear();
    _followed = 0;
    _dopDist = 0;
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
    final relaxed = _relaxed;
    final cap = dopplerMoving
        ? maxAccuracyM
        : _moving
        ? movingMaxAccuracyM
        : stillMaxAccuracyM;
    if (_recentAcc.length < 3) return cap;
    final sorted = [..._recentAcc]..sort();
    final median = sorted[sorted.length ~/ 2];
    return (median * adaptiveAccuracyFactor).clamp(
      relaxed ? minAccuracyGateM : stillMinAccuracyGateM,
      cap,
    );
  }

  static double _dist(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }
}
