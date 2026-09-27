import 'dart:async';
import 'dart:math';

import '../domain/movement.dart';

/// Source of movement samples during a run (GPS + health steps).
abstract class MovementSource {
  Stream<MovementSample> start(DateTime startedAt);
  void stop();
}

/// Stand-in until GPS and Apple Health / Health Connect are wired up.
/// Speed is set from the demo controls on the run screen.
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
