import 'companion.dart';
import 'movement.dart';
import 'run_summary.dart';
import 'sweet_spot.dart';

/// Turns movement samples into LP for one run with one companion.
///
/// A Breath block is [metersPerBreath] of weighted sweet-spot distance and
/// pays [Companion.lpPerBreath]. It is paid out in [piecesPerBreath] pieces
/// (every [metersPerPiece]), each taking 1/[piecesPerBreath] Breath and
/// paying 1/[piecesPerBreath] of the block's LP, so LP show up early while
/// LP and Breath per metre stay as before. A new block only starts with at
/// least one full Breath left, so the tank ends exactly where whole blocks
/// would have left it.
class RunEngine {
  RunEngine({
    required this.companion,
    required this.breathAtStart,
    required this.startedAt,
    this.earnsLp = true,
  });

  static const double metersPerBreath = 250;
  static const int piecesPerBreath = 5;
  static const double metersPerPiece = metersPerBreath / piecesPerBreath;

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

  double distanceM = 0;
  int steps = 0;

  /// Pieces paid out so far ([piecesPerBreath] make one Breath block).
  int pieces = 0;
  double speedKmh = 0;
  double factor = 0;
  Duration elapsed = Duration.zero;

  double _progressM = 0;
  Duration _fastTime = Duration.zero;
  Duration _inBandTime = Duration.zero;
  DateTime? _lastTime;
  bool _stepsKnown = false;

  /// Whole Breath blocks completed.
  int get blocks => pieces ~/ piecesPerBreath;

  /// Pieces into the current, unfinished block (0 to [piecesPerBreath] - 1).
  int get _openPieces => pieces % piecesPerBreath;

  double get breathLeft =>
      breathAtStart - blocks - _openPieces / piecesPerBreath;

  double get lp =>
      blocks * companion.lpPerBreath +
      _openPieces * companion.lpPerBreath / piecesPerBreath;

  /// LP one piece pays.
  double get lpPerPiece => companion.lpPerBreath / piecesPerBreath;

  /// A started block is always finished; a new one needs a full Breath.
  bool get canEarn =>
      earnsLp && companion.spirit > 0 && (_openPieces > 0 || breathLeft >= 1);

  /// Progress (0–1) towards the next piece.
  double get pieceProgress =>
      canEarn ? (_progressM / metersPerPiece).clamp(0.0, 1.0) : 0;

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

  /// Returns the number of pieces earned by this sample.
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
    while (_progressM >= metersPerPiece && canEarn) {
      _progressM -= metersPerPiece;
      pieces++;
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
