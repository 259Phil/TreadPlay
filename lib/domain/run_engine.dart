import 'companion.dart';
import 'movement.dart';
import 'run_summary.dart';
import 'sweet_spot.dart';

/// Turns movement samples into LP blocks for one run with one companion.
class RunEngine {
  RunEngine({
    required this.companion,
    required this.breathAtStart,
    required this.startedAt,
    this.earnsLp = true,
  }) : breathLeft = breathAtStart;

  static const double metersPerBreath = 250;

  /// Above this, movement is treated as a vehicle.
  static const double maxPlausibleKmh = 30;
  static const Duration maxFastTime = Duration(minutes: 1);

  /// Below this ratio, distance without matching steps is implausible.
  static const double minStepsPerMeter = 0.4;
  static const double minDistanceForStepCheckM = 200;

  final Companion companion;

  /// Points on the shared Breath bar when the run started.
  final double breathAtStart;
  final DateTime startedAt;

  /// False when movement access was denied: distance is tracked, LP is not.
  final bool earnsLp;

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
  Duration _inBandTime = Duration.zero;
  DateTime? _lastTime;
  bool _stepsKnown = false;

  bool get canEarn => earnsLp && companion.spirit > 0 && breathLeft >= 1;

  /// True while the current pace is inside the companion's sweet spot.
  bool get inBand =>
      sweetSpotFactor(
        companion.type,
        speedKmh,
        widenKmh: companion.sweetSpotWidenKmh,
      ) >
      0;

  /// Average pace of the run, null before the first 10 m.
  Duration? get pace => paceOf(elapsed, distanceM);

  double get breathUsed => breathAtStart - breathLeft;

  /// Share (0–1) of the run's time spent inside the companion's sweet spot
  /// range, null before any time has passed.
  double? get sweetSpotShare => elapsed <= Duration.zero
      ? null
      : (_inBandTime.inMicroseconds / elapsed.inMicroseconds).clamp(0.0, 1.0);

  bool get isValid {
    if (_fastTime > maxFastTime) return false;
    if (_stepsKnown &&
        distanceM >= minDistanceForStepCheckM &&
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
    final sampleSteps = sample.steps;
    if (sampleSteps != null) {
      _stepsKnown = true;
      steps += sampleSteps;
    }
    speedKmh = sample.speedKmh;
    if (speedKmh > maxPlausibleKmh) _fastTime += dt;
    if (inBand) _inBandTime += dt;

    factor = canEarn
        ? sweetSpotFactor(
            companion.type,
            speedKmh,
            widenKmh: companion.sweetSpotWidenKmh,
          )
        : 0;
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
      breathLeft: valid ? breathLeft : breathAtStart,
      tankSize: companion.tankSize,
      earnsLp: earnsLp,
      valid: valid,
      sweetSpotShare: sweetSpotShare,
    );
  }
}
