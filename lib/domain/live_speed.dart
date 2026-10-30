import 'dart:math';

import 'gps_filter.dart';

/// Current speed from GPS for the live tempo, the sweet-spot gauge and the
/// gait check.
///
/// The [GpsFilter] counts distance in steps of a few meters from a smoothed
/// position whose lag changes with the accuracy, so the speed of a single
/// step jumps a lot. Here the speed is fitted to the raw accepted positions
/// of the last [window] (distance over time, least squares, weighted by
/// accuracy) and blended with the device's Doppler speed (`coords.speed`)
/// when that is plausible. Jumps the filter rejected never get here.
class LiveSpeed {
  LiveSpeed({this.window = defaultWindow, this.fitDistanceM = 50});

  static const Duration defaultWindow = Duration(seconds: 15);

  /// Positions are fitted over at least this long ...
  final Duration window;

  /// ... or as long as it takes to cover this distance at the last speed
  /// (so a slow walk is fitted over more time than a run) ...
  final double fitDistanceM;

  /// ... but never longer than this.
  static const Duration maxWindow = Duration(seconds: 30);

  /// Until this much movement is seen, the speed is only provisional.
  static const Duration minSpan = Duration(seconds: 8);

  /// Shorter than this, there is no estimate at all.
  static const Duration minFitSpan = Duration(seconds: 3);

  /// Doppler values are taken as a median over this long.
  static const Duration dopplerWindow = Duration(seconds: 5);

  /// Doppler and positions are blended only when they agree this well;
  /// otherwise Doppler alone is used.
  static const double dopplerAgreement = 0.3;

  /// Weight of the Doppler speed when both agree.
  static const double dopplerWeight = 0.8;

  /// Doppler values above this are not walking or running.
  static const double maxDopplerMps = GpsFilter.maxSpeedMps;

  /// Doppler at or below this is "unknown" (web reports 0 without it).
  static const double minDopplerMps = 0.3;

  // Raw positions (time, x, y, weight) since moving started.
  final List<(DateTime, double, double, double)> _fixes = [];
  final List<(DateTime, double)> _doppler = [];
  bool _moving = false;
  double _fastDoppler = 0;
  double _lastFit = 0;

  /// One accepted fix at [x], [y] (meters) with accuracy [accuracyM],
  /// whether the filter believes the device is [moving], and the device's
  /// Doppler speed if it has one.
  void add(
    DateTime time, {
    required double x,
    required double y,
    required double accuracyM,
    required bool moving,
    double? dopplerMps,
  }) {
    if (!moving) {
      _moving = false;
      _fixes.clear();
      _doppler.clear();
      _fastDoppler = 0;
      _lastFit = 0;
      return;
    }
    if (!_moving) {
      _moving = true;
      _fixes.clear();
      _doppler.clear();
    }
    final acc = max(accuracyM, 3.0);
    _fixes.add((time, x, y, 1 / (acc * acc)));
    final d = dopplerMps;
    if (d != null && d.isFinite && d > minDopplerMps) {
      if (d <= maxDopplerMps) {
        _doppler.add((time, d));
        _fastDoppler = 0;
      } else {
        _fastDoppler = d;
      }
    }
    _prune(time);
  }

  void _prune(DateTime now) {
    _fixes.removeWhere((e) => now.difference(e.$1) > maxWindow);
    _doppler.removeWhere((e) => now.difference(e.$1) > dopplerWindow);
  }

  /// Speed in m/s at [now] (null while there is nothing to go by yet), and
  /// whether enough movement has been seen for it to be shown as a tempo.
  ({double? mps, bool ready}) at(DateTime now) {
    if (!_moving) return (mps: 0, ready: true);
    if (_fastDoppler > 0) return (mps: _fastDoppler, ready: true);
    _prune(now);

    final doppler = _dopplerSpeed();
    final guess = doppler ?? _lastFit;
    var secs = window.inMilliseconds / 1000;
    if (guess > 0) secs = max(secs, fitDistanceM / guess);
    final from = now.subtract(
      Duration(
        milliseconds: (min(secs, maxWindow.inMilliseconds / 1000) * 1000)
            .round(),
      ),
    );
    final use = [
      for (final f in _fixes)
        if (!f.$1.isBefore(from)) f,
    ];
    final fit = _fit(use);
    if (fit != null) _lastFit = fit;
    final span = use.length < 2
        ? Duration.zero
        : use.last.$1.difference(use.first.$1);
    final ready = span >= minSpan || doppler != null && _doppler.length >= 3;
    if (fit == null || span < minFitSpan) {
      return (mps: doppler, ready: doppler != null && ready);
    }
    if (doppler == null) return (mps: fit, ready: ready);
    // The device's Doppler speed is far steadier than positions a few
    // meters off; the positions only nudge it when both agree.
    if ((doppler - fit).abs() <= dopplerAgreement * fit) {
      return (
        mps: dopplerWeight * doppler + (1 - dopplerWeight) * fit,
        ready: ready,
      );
    }
    return (mps: doppler, ready: ready);
  }

  /// Weighted least-squares velocity over the window, as a speed.
  static double? _fit(List<(DateTime, double, double, double)> fixes) {
    if (fixes.length < 3) return null;
    final t0 = fixes.first.$1;
    var sw = 0.0, st = 0.0, sx = 0.0, sy = 0.0;
    for (final f in fixes) {
      final t = f.$1.difference(t0).inMilliseconds / 1000;
      sw += f.$4;
      st += f.$4 * t;
      sx += f.$4 * f.$2;
      sy += f.$4 * f.$3;
    }
    final mt = st / sw, mx = sx / sw, my = sy / sw;
    var stt = 0.0, stx = 0.0, sty = 0.0;
    for (final f in fixes) {
      final t = f.$1.difference(t0).inMilliseconds / 1000 - mt;
      stt += f.$4 * t * t;
      stx += f.$4 * t * (f.$2 - mx);
      sty += f.$4 * t * (f.$3 - my);
    }
    if (stt <= 0) return null;
    final v = sqrt(pow(stx / stt, 2) + pow(sty / stt, 2));
    return min(v, GpsFilter.maxSpeedMps);
  }

  double? _dopplerSpeed() {
    if (_doppler.isEmpty) return null;
    final v = [for (final e in _doppler) e.$2]..sort();
    final n = v.length;
    return n.isOdd ? v[n ~/ 2] : (v[n ~/ 2 - 1] + v[n ~/ 2]) / 2;
  }
}
