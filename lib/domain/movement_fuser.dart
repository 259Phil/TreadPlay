import 'dart:math';

import 'gps_filter.dart';
import 'live_speed.dart';
import 'movement.dart';

/// Merges GPS distance and pedometer steps into one [MovementSample] per tick.
///
/// Only deltas and a few seconds of totals are kept in memory: no
/// coordinates, no route.
class MovementFuser {
  MovementFuser({this.startedAt, Duration? liveWindow})
    : _live = LiveSpeed(window: liveWindow ?? LiveSpeed.defaultWindow);

  /// Pedometer distance per step when GPS has no usable fix.
  static const double strideM = 0.75;

  /// GPS fixes worse than this are ignored (the [GpsFilter] gate is
  /// stricter and adaptive; this is the last line).
  static const double maxAccuracyM = GpsFilter.maxAccuracyM;

  /// Without a GPS fix for this long, distance comes from steps.
  static const Duration gpsStale = Duration(seconds: 5);

  /// Pedometer speed is averaged over this window.
  static const Duration speedWindow = Duration(seconds: 10);

  final DateTime? startedAt;

  double _gpsM = 0;
  int _steps = 0;
  bool _hasStepCounter = false;
  int? _lastStepTotal;
  DateTime? _lastFix;
  double? _gpsSpeedKmh;
  final LiveSpeed _live;
  bool _hasPositions = false;
  final List<(DateTime, double)> _window = [];

  /// Distance in meters between two accepted GPS fixes.
  ///
  /// [x], [y] (raw position in meters), [moving] (the filter's
  /// standing/moving state) and [dopplerMps] (the device's own speed
  /// reading, `coords.speed`) feed the live speed; without a position there
  /// is none.
  /// [speedKmh] (the filter's speed of the last step) is only a stand-in
  /// until the live speed has two counted steps.
  void addGps(
    DateTime time,
    double meters, {
    required double accuracyM,
    double? speedKmh,
    double? x,
    double? y,
    bool moving = true,
    double? dopplerMps,
  }) {
    if (accuracyM > maxAccuracyM) return;
    _lastFix = time;
    _gpsM += meters;
    _gpsSpeedKmh = speedKmh;
    if (x != null && y != null) {
      _hasPositions = true;
      _live.add(
        time,
        x: x,
        y: y,
        accuracyM: accuracyM,
        moving: moving,
        dopplerMps: dopplerMps,
      );
    }
  }

  /// Cumulative pedometer count (since the device started, on Android).
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
    final windowKmh = span == Duration.zero
        ? 0.0
        : max(0.0, windowM / span.inMilliseconds * 3600);

    double speedKmh;
    bool ready;
    if (gpsLive && !_hasPositions) {
      speedKmh = _gpsSpeedKmh ?? windowKmh;
      ready = span >= speedWindow - const Duration(seconds: 1);
    } else if (gpsLive) {
      final live = _live.at(now);
      final mps = live.mps;
      speedKmh = mps != null ? mps * 3.6 : _gpsSpeedKmh ?? windowKmh;
      ready = mps != null && live.ready;
    } else {
      speedKmh = windowKmh;
      ready = span >= speedWindow - const Duration(seconds: 1);
    }

    return MovementSample(
      time: now,
      speedKmh: speedKmh,
      distanceM: meters,
      steps: steps,
      speedReady: ready,
    );
  }
}
