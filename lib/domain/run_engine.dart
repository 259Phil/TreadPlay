import 'companion.dart';
import 'movement.dart';
import 'run_summary.dart';
import 'sweet_spot.dart';

/// Turns movement samples into LP blocks for one run with one companion.
class RunEngine {
  RunEngine({required this.companion, required this.startedAt})
    : breathLeft = companion.breath;

  static const double metersPerBreath = 250;

  /// Above this, movement is treated as a vehicle.
  static const double maxPlausibleKmh = 30;
  static const Duration maxFastTime = Duration(minutes: 1);

  /// Below this ratio, distance without matching steps is implausible.
  static const double minStepsPerMeter = 0.4;
  static const double minDistanceForStepCheckM = 200;

  final Companion companion;
  final DateTime startedAt;

  double breathLeft;
  double distanceM = 0;
  int steps = 0;
  double lp = 0;
  int blocks = 0;
  double speedKmh = 0;
  double factor = 0;
  Duration elapsed = Duration.zero;

  double _progressM = 0;
  Duration _fastTime = Duration.zero;
  DateTime? _lastTime;

  bool get canEarn => companion.spirit > 0 && breathLeft >= 1;

  double get breathUsed => companion.breath - breathLeft;

  bool get isValid {
    if (_fastTime > maxFastTime) return false;
    if (distanceM >= minDistanceForStepCheckM &&
        steps / distanceM < minStepsPerMeter) {
      return false;
    }
    return true;
  }

  /// Returns the number of LP blocks earned by this sample.
  int add(MovementSample sample) {
    final dt = sample.time.difference(_lastTime ?? startedAt);
    _lastTime = sample.time;
    elapsed = sample.time.difference(startedAt);
    distanceM += sample.distanceM;
    steps += sample.steps;
    speedKmh = sample.speedKmh;
    if (speedKmh > maxPlausibleKmh) _fastTime += dt;

    factor = canEarn ? sweetSpotFactor(companion.type, speedKmh) : 0;
    if (factor == 0) return 0;

    _progressM += sample.distanceM * factor;
    var earned = 0;
    while (_progressM >= metersPerBreath && canEarn) {
      _progressM -= metersPerBreath;
      breathLeft -= 1;
      lp += companion.lpPerBreath;
      blocks++;
      earned++;
    }
    if (!canEarn) _progressM = 0;
    return earned;
  }

  RunSummary finish() {
    final valid = isValid;
    return RunSummary(
      companionId: companion.id,
      startedAt: startedAt,
      duration: elapsed,
      distanceM: distanceM,
      steps: steps,
      lp: valid ? lp : 0,
      breathUsed: valid ? breathUsed : 0,
      valid: valid,
    );
  }
}
