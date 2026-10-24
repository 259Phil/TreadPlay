import 'dart:math';

import 'package:treadplay/domain/gps_filter.dart';

/// Realistic GPS scenarios for the drift tests: indoor jitter while sitting
/// still, and outdoor walking / jogging / running with ordinary noise.
class GpsScenario {
  GpsScenario({int seed = 1}) : _rng = Random(seed);

  static const double lat0 = 49.4875; // Mannheim
  static const double lon0 = 8.466;
  static const double _earthR = 6371000;

  final Random _rng;
  final DateTime t0 = DateTime.utc(2026, 10, 24, 12);
  final List<GpsFix> fixes = [];

  /// Fix index and time at which each movement phase started.
  final List<DateTime> moveStarts = [];

  double trueDistanceM = 0;
  double _x = 0;
  double _y = 0;
  double _heading = 0;
  double _nx = 0;
  double _ny = 0;
  double _acc = 10;
  int _ms = 0;

  double _gauss() {
    final u1 = max(1e-12, _rng.nextDouble());
    final u2 = _rng.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  double _uniform(double a, double b) => a + (b - a) * _rng.nextDouble();

  void _emit(double ex, double ey, double acc) {
    final mx = _x + ex;
    final my = _y + ey;
    fixes.add(
      GpsFix(
        time: t0.add(Duration(milliseconds: _ms)),
        latitude: lat0 + my / _earthR * 180 / pi,
        longitude: lon0 + mx / (_earthR * cos(lat0 * pi / 180)) * 180 / pi,
        accuracyM: acc,
      ),
    );
  }

  /// Sitting still indoors: reported accuracy wanders between 15 and 65 m,
  /// the position error is correlated, often larger than the reported
  /// radius (up to 30–50 m), and now and then a fix lands ~100 m away (Wi-Fi
  /// positioning flips). Fixes arrive every 1–2 s.
  void indoorStill(int seconds) {
    _acc = _uniform(15, 40);
    var end = _ms + seconds * 1000;
    var flip = 0;
    double fx = 0, fy = 0;
    while (_ms < end) {
      _ms += _rng.nextDouble() < 0.7 ? 1000 : 2000;
      _acc = (_acc + _gauss() * 4).clamp(15, 65);
      // Error: AR(1) with a per-axis sigma of ~12 m, independent of the
      // reported radius (indoors the radius is often too optimistic).
      const rho = 0.9;
      const sigma = 12.0;
      final k = sqrt(1 - rho * rho);
      _nx = rho * _nx + k * sigma * _gauss();
      _ny = rho * _ny + k * sigma * _gauss();
      if (flip == 0 && _rng.nextDouble() < 1 / 90) {
        flip = 1 + _rng.nextInt(4);
        final a = _uniform(0, 2 * pi);
        fx = 100 * sin(a);
        fy = 100 * cos(a);
      }
      if (flip > 0) {
        flip--;
        _emit(_nx + fx, _ny + fy, _uniform(18, 45));
      } else {
        _emit(_nx, _ny, _acc);
      }
    }
    end = 0;
  }

  /// Outdoors, standing or moving at [kmh], accuracy 5–15 m, one fix/s.
  /// The heading turns slowly so the route is not a straight line.
  void outdoor(int seconds, double kmh, {bool turns = true}) {
    if (kmh > 0) moveStarts.add(t0.add(Duration(milliseconds: _ms)));
    final v = kmh / 3.6;
    for (var i = 0; i < seconds; i++) {
      _ms += 1000;
      if (turns && i % 120 == 119) _heading += _uniform(-100, 100);
      _x += v * sin(_heading * pi / 180);
      _y += v * cos(_heading * pi / 180);
      trueDistanceM += v;
      _acc = (_acc + _gauss() * 1.5).clamp(5, 15);
      const rho = 0.85;
      final sigma = _acc / 2;
      final k = sqrt(1 - rho * rho);
      _nx = rho * _nx + k * sigma * _gauss();
      _ny = rho * _ny + k * sigma * _gauss();
      _emit(_nx, _ny, _acc);
    }
  }

  /// Seconds outdoors needed for [meters] at [kmh].
  static int secondsFor(double meters, double kmh) =>
      (meters / (kmh / 3.6)).ceil();
}

/// Result of feeding a scenario through a [GpsFilter].
class FilterRun {
  FilterRun(this.distanceM, this.detectSecs, this.maxStillSpeedKmh);

  final double distanceM;

  /// Seconds from the start of each movement phase until the filter first
  /// added distance (null when it never did).
  final List<double?> detectSecs;
  final double maxStillSpeedKmh;
}

FilterRun runFilter(GpsScenario s) {
  final f = GpsFilter(checkFixAge: true);
  var d = 0.0;
  final detect = List<double?>.filled(s.moveStarts.length, null);
  var maxStill = 0.0;
  for (final fix in s.fixes) {
    final add = f.add(fix, receivedAt: fix.time);
    d += add;
    var phase = -1;
    for (var i = 0; i < s.moveStarts.length; i++) {
      if (!fix.time.isBefore(s.moveStarts[i])) phase = i;
    }
    if (phase < 0) {
      maxStill = max(maxStill, f.speedMps * 3.6);
    } else if (add > 0 && detect[phase] == null) {
      detect[phase] =
          fix.time.difference(s.moveStarts[phase]).inMilliseconds / 1000;
    }
  }
  return FilterRun(d, detect, maxStill);
}
