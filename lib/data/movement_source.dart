import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/movement.dart';
import '../domain/movement_fuser.dart';

/// Source of movement samples during a run.
abstract class MovementSource {
  Stream<MovementSample> start(DateTime startedAt);
  void stop();
}

/// Build with `--dart-define=TREADPLAY_SIM=true` to run on the simulator
/// slider instead of GPS and the step counter. Ignored in release builds.
const bool simulatorFlag =
    !kReleaseMode && bool.fromEnvironment('TREADPLAY_SIM');

/// GPS distance and pedometer steps from this device. Nothing is stored or
/// sent: only the previous fix is held in memory to measure the next step.
class DeviceMovementSource implements MovementSource {
  static const Duration tick = Duration(seconds: 1);

  Timer? _timer;
  StreamController<MovementSample>? _controller;
  StreamSubscription<Position>? _gps;
  StreamSubscription<StepCount>? _steps;
  Position? _lastFix;
  int _session = 0;

  @override
  Stream<MovementSample> start(DateTime startedAt) {
    stop();
    final session = ++_session;
    final fuser = MovementFuser();
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
    if (await _stepsAllowed() && session == _session) {
      _steps = Pedometer.stepCountStream.listen(
        (s) => fuser.addStepTotal(s.steps),
        onError: (Object _) {},
      );
    }
  }

  void _onFix(MovementFuser fuser, Position p) {
    if (p.accuracy > MovementFuser.maxAccuracyM) return;
    final last = _lastFix;
    _lastFix = p;
    final meters = last == null
        ? 0.0
        : Geolocator.distanceBetween(
            last.latitude,
            last.longitude,
            p.latitude,
            p.longitude,
          );
    fuser.addGps(_now(), meters, accuracyM: p.accuracy);
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

  LocationSettings _locationSettings() => switch (defaultTargetPlatform) {
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
    _lastFix = null;
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
