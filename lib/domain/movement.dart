/// One tick of movement data. Distance and steps are deltas since the
/// previous sample.
class MovementSample {
  const MovementSample({
    required this.time,
    required this.speedKmh,
    required this.distanceM,
    required this.steps,
  });

  final DateTime time;
  final double speedKmh;
  final double distanceM;
  final int steps;
}
