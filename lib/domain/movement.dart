/// One tick of movement data. Distance and steps are deltas since the
/// previous sample. [steps] is null when the device has no step counter.
class MovementSample {
  const MovementSample({
    required this.time,
    required this.speedKmh,
    required this.distanceM,
    required this.steps,
    this.speedReady = true,
  });

  final DateTime time;
  final double speedKmh;
  final double distanceM;
  final int? steps;

  /// False while too little movement was seen for [speedKmh] to be shown as
  /// a tempo (it is still the best guess and used for the sweet spot).
  final bool speedReady;
}
