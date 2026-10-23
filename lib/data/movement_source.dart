import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/gps_filter.dart';
import '../domain/movement.dart';
import '../domain/movement_fuser.dart';
import 'screen_wake.dart';

/// Source of movement samples during a run.
abstract class MovementSource {
  Stream<MovementSample> start(DateTime startedAt);
  void stop();
}

/// Build with `--dart-define=TREADPLAY_SIM=true` to run on the simulator
/// slider instead of GPS and the step counter. Ignored in release builds.
const bool simulatorFlag =
    !kReleaseMode && bool.fromEnvironment('TREADPLAY_SIM');

/// Live GPS quality for the hidden developer readout on the run screen.
class GpsReadout {
  const GpsReadout({
    required this.accuracyM,
    required this.accepted,
    required this.rejected,
    required this.jumps,
    required this.gaps,
    required this.warmingUp,
    required this.verdict,
  });

  final double? accuracyM;
  final int accepted;
  final int rejected;
  final int jumps;
  final int gaps;
  final bool warmingUp;
  final GpsVerdict? verdict;
}

/// GPS distance and pedometer steps from this device (GPS only on Web).
/// Nothing is stored or sent: only the last smoothed position is held in
/// memory to measure the next step.
class DeviceMovementSource implements MovementSource {
  static const Duration tick = Duration(seconds: 1);

  Timer? _timer;
  StreamController<MovementSample>? _controller;
  StreamSubscription<Position>? _gps;
  StreamSubscription<StepCount>? _steps;
  GpsFilter? _filter;
  int _session = 0;

  /// Latest GPS quality (null while no run is active).
  final ValueNotifier<GpsReadout?> readout = ValueNotifier(null);

  @override
  Stream<MovementSample> start(DateTime startedAt) {
    stop();
    final session = ++_session;
    final fuser = MovementFuser();
    _filter = GpsFilter(checkFixAge: kIsWeb);
    if (kIsWeb) ScreenWake.enable();
    final controller = StreamController<MovementSample>();
    _controller = controller;
    _timer = Timer.periodic(tick, (_) => controller.add(fuser.tick(_now())));
    _listen(session, fuser);
    return controller.stream;
  }

  DateTime _now() => DateTime.now();

  Future<void> _listen(int session, MovementFuser fuser) async {
    if (await _locationAllowed() && session == _session) {
      _gps = Geolocator.getPositionStream(
        locationSettings: _locationSettings(),
      ).listen((p) => _onFix(fuser, p), onError: (Object _) {});
    }
    if (!kIsWeb && await _stepsAllowed() && session == _session) {
      _steps = Pedometer.stepCountStream.listen(
        (s) => fuser.addStepTotal(s.steps),
        onError: (Object _) {},
      );
    }
  }

  void _onFix(MovementFuser fuser, Position p) {
    final filter = _filter;
    if (filter == null) return;
    final now = _now();
    final meters = filter.add(
      GpsFix(
        time: p.timestamp,
        latitude: p.latitude,
        longitude: p.longitude,
        accuracyM: p.accuracy,
      ),
      receivedAt: now,
    );
    readout.value = GpsReadout(
      accuracyM: filter.lastAccuracyM,
      accepted: filter.accepted,
      rejected: filter.rejected,
      jumps: filter.jumps,
      gaps: filter.gaps,
      warmingUp: filter.warmingUp,
      verdict: filter.lastVerdict,
    );
    // Rejected fixes do not count as a live GPS signal, so on phones the
    // step counter takes over while GPS is unusable.
    if (filter.lastVerdict != GpsVerdict.accepted) return;
    fuser.addGps(
      now,
      meters,
      accuracyM: p.accuracy,
      speedKmh: filter.speedMps * 3.6,
    );
  }

  Future<bool> _locationAllowed() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _stepsAllowed() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      return (await Permission.activityRecognition.request()).isGranted;
    } catch (_) {
      return false;
    }
  }

  LocationSettings _locationSettings() => kIsWeb
      // Checked first: on a phone browser defaultTargetPlatform is android or
      // iOS too. enableHighAccuracy on, no cached positions (maximumAge 0).
      ? WebSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          maximumAge: Duration.zero,
        )
      : switch (defaultTargetPlatform) {
          TargetPlatform.android => AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            intervalDuration: tick,
          ),
          TargetPlatform.iOS => AppleSettings(
            accuracy: LocationAccuracy.best,
            activityType: ActivityType.fitness,
            distanceFilter: 0,
            pauseLocationUpdatesAutomatically: false,
          ),
          _ => const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
          ),
        };

  @override
  void stop() {
    _session++;
    _timer?.cancel();
    _timer = null;
    _gps?.cancel();
    _gps = null;
    _steps?.cancel();
    _steps = null;
    _filter = null;
    readout.value = null;
    if (kIsWeb) ScreenWake.disable();
    _controller?.close();
    _controller = null;
  }
}

/// Debug-only stand-in: speed is set from the simulator slider on the run
/// screen.
class SimulatedMovementSource implements MovementSource {
  SimulatedMovementSource({this.tick = const Duration(seconds: 1)});

  final Duration tick;

  double targetSpeedKmh = 0;
  int timeScale = 1;

  Timer? _timer;
  StreamController<MovementSample>? _controller;
  double _stepRemainder = 0;
  int _ticks = 0;

  @override
  Stream<MovementSample> start(DateTime startedAt) {
    stop();
    _ticks = 0;
    _stepRemainder = 0;
    var simTime = startedAt;
    final controller = StreamController<MovementSample>();
    _controller = controller;
    _timer = Timer.periodic(tick, (_) {
      _ticks++;
      final dt = tick * timeScale;
      simTime = simTime.add(dt);
      final wobble = targetSpeedKmh == 0 ? 0 : 0.15 * sin(_ticks / 3);
      final speed = max(0.0, targetSpeedKmh + wobble);
      final meters = speed / 3.6 * dt.inMilliseconds / 1000;
      final strideLengthM = speed < 8 ? 0.75 : 1.05;
      final rawSteps = meters / strideLengthM + _stepRemainder;
      final steps = rawSteps.floor();
      _stepRemainder = rawSteps - steps;
      controller.add(
        MovementSample(
          time: simTime,
          speedKmh: speed,
          distanceM: meters,
          steps: steps,
        ),
      );
    });
    return controller.stream;
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}
