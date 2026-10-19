import 'dart:math';

import 'movement.dart';

/// Merges GPS distance and pedometer steps into one [MovementSample] per tick.
///
/// Only deltas and a few seconds of totals are kept in memory: no
/// coordinates, no route.
class MovementFuser {
  MovementFuser({this.startedAt});

  /// Pedometer distance per step when GPS has no usable fix.
  static const double strideM = 0.75;

  /// GPS fixes worse than this are ignored.
  static const double maxAccuracyM = 25;

  /// Without a GPS fix for this long, distance comes from steps.
  static const Duration gpsStale = Duration(seconds: 5);

  /// Speed is averaged over this window.
  static const Duration speedWindow = Duration(seconds: 5);

  final DateTime? startedAt;

  double _gpsM = 0;
  int _steps = 0;
  bool _hasStepCounter = false;
  int? _lastStepTotal;
  DateTime? _lastFix;
  final List<(DateTime, double)> _window = [];

  /// Distance in meters between two accepted GPS fixes.
  void addGps(DateTime time, double meters, {required double accuracyM}) {
    if (accuracyM > maxAccuracyM) return;
    _lastFix = time;
    _gpsM += meters;
  }

  /// Cumulative pedometer count (since boot on Android).
  void addStepTotal(int total) {
    _hasStepCounter = true;
    final last = _lastStepTotal;
    _lastStepTotal = total;
    if (last != null && total >= last) _steps += total - last;
  }

  MovementSample tick(DateTime now) {
    final fix = _lastFix;
    final gpsLive = fix != null && now.difference(fix) <= gpsStale;
    final meters = gpsLive ? _gpsM : _steps * strideM;
    final steps = _hasStepCounter ? _steps : null;
    _gpsM = 0;
    _steps = 0;

    _window
      ..add((now, meters))
      ..removeWhere((e) => now.difference(e.$1) > speedWindow);
    final span = _window.length < 2
        ? Duration.zero
        : now.difference(_window.first.$1);
    final windowM = _window.skip(1).fold(0.0, (s, e) => s + e.$2);
    final speedKmh = span == Duration.zero
        ? 0.0
        : max(0.0, windowM / span.inMilliseconds * 3600);

    return MovementSample(
      time: now,
      speedKmh: speedKmh,
      distanceM: meters,
      steps: steps,
    );
  }
}
