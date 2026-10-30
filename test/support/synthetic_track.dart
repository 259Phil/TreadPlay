import 'dart:math';

import 'package:treadplay/domain/gps_filter.dart';

/// Builds synthetic GPS fixes around a fixed origin with correlated noise
/// (GPS errors drift slowly rather than jumping every second).
class SyntheticTrack {
  SyntheticTrack({int seed = 1, this.correlation = 0.85, this.jitterM = 0})
    : _rng = Random(seed);

  static const double lat0 = 52.52;
  static const double lon0 = 13.405;
  static const double _earthR = 6371000;

  final Random _rng;
  final double correlation;

  /// Extra white noise per fix (sigma per axis) on top of the slow drift.
  final double jitterM;
  final DateTime t0 = DateTime.utc(2026, 10, 23, 8);

  final List<GpsFix> fixes = [];

  /// True speed in m/s at each fix in [fixes].
  final List<double> trueSpeeds = [];
  double trueDistanceM = 0;
  double _speed = 0;

  double _x = 0;
  double _y = 0;
  double _nx = 0;
  double _ny = 0;
  int _second = 0;

  double _gauss() {
    final u1 = max(1e-12, _rng.nextDouble());
    final u2 = _rng.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  void _emit(double accuracyM, {double dx = 0, double dy = 0}) {
    // Per-axis sigma of about half the reported radius, AR(1) in time.
    final sigma = accuracyM / 2;
    final k = sqrt(1 - correlation * correlation);
    _nx = correlation * _nx + k * sigma * _gauss();
    _ny = correlation * _ny + k * sigma * _gauss();
    final jx = jitterM == 0 ? 0.0 : jitterM * _gauss();
    final jy = jitterM == 0 ? 0.0 : jitterM * _gauss();
    final mx = _x + _nx + dx + jx;
    final my = _y + _ny + dy + jy;
    trueSpeeds.add(_speed);
    fixes.add(
      GpsFix(
        time: t0.add(Duration(seconds: _second)),
        latitude: lat0 + my / _earthR * 180 / pi,
        longitude: lon0 + mx / (_earthR * cos(lat0 * pi / 180)) * 180 / pi,
        accuracyM: accuracyM,
      ),
    );
  }

  /// Walks [seconds] at [speedMps] in direction [headingDeg], one fix/s.
  void move(
    int seconds,
    double speedMps, {
    double headingDeg = 0,
    double accuracyM = 6,
    bool record = true,
    bool countTruth = true,
  }) {
    final h = headingDeg * pi / 180;
    _speed = speedMps;
    for (var i = 0; i < seconds; i++) {
      _second++;
      _x += speedMps * sin(h);
      _y += speedMps * cos(h);
      if (countTruth) trueDistanceM += speedMps;
      if (record) _emit(accuracyM);
    }
  }

  void stand(int seconds, {double accuracyM = 10}) =>
      move(seconds, 0, accuracyM: accuracyM);

  /// One wild fix [meters] away from the true position.
  void spike(double meters, {double accuracyM = 8}) {
    _second++;
    _emit(accuracyM, dx: meters);
  }

  /// Same timestamp as the previous fix again.
  void duplicate() {
    final last = fixes.last;
    trueSpeeds.add(_speed);
    fixes.add(
      GpsFix(
        time: last.time,
        latitude: last.latitude + 0.001,
        longitude: last.longitude,
        accuracyM: last.accuracyM,
      ),
    );
  }

  /// Fixes during warm-up: poor accuracy and offset.
  void coldStart(int seconds, {double offsetM = 60}) {
    for (var i = 0; i < seconds; i++) {
      _second++;
      final acc = 80.0 - i * 12;
      _emit(max(acc, 26), dx: offsetM * (1 - i / seconds));
    }
  }

  double filtered({bool web = true}) {
    final f = GpsFilter(checkFixAge: web);
    var d = 0.0;
    for (final fix in fixes) {
      d += f.add(fix, receivedAt: fix.time);
    }
    lastFilter = f;
    return d;
  }

  GpsFilter? lastFilter;

  /// Behaviour before this change: every fix with accuracy ≤ 25 m adds the
  /// straight line to the previous one.
  double legacy() {
    GpsFix? prev;
    var d = 0.0;
    for (final fix in fixes) {
      if (fix.accuracyM > 25) continue;
      if (prev != null) d += _haversine(prev, fix);
      prev = fix;
    }
    return d;
  }

  static double _haversine(GpsFix a, GpsFix b) {
    final p1 = a.latitude * pi / 180;
    final p2 = b.latitude * pi / 180;
    final dp = p2 - p1;
    final dl = (b.longitude - a.longitude) * pi / 180;
    final h =
        sin(dp / 2) * sin(dp / 2) +
        cos(p1) * cos(p2) * sin(dl / 2) * sin(dl / 2);
    return 2 * _earthR * asin(sqrt(h));
  }
}
