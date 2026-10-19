/// Time per km, null below 10 m.
Duration? paceOf(Duration time, double distanceM) => distanceM < 10
    ? null
    : Duration(milliseconds: (time.inMilliseconds * 1000 / distanceM).round());

class RunSummary {
  const RunSummary({
    required this.companionId,
    required this.startedAt,
    required this.duration,
    required this.distanceM,
    required this.steps,
    required this.lp,
    required this.breathUsed,
    required this.valid,
    this.breathLeft,
    this.tankSize,
    this.earnsLp = true,
  });

  final String companionId;
  final DateTime startedAt;
  final Duration duration;
  final double distanceM;
  final int steps;
  final double lp;
  final double breathUsed;
  final bool valid;

  /// Shared Breath after the run; null for runs saved before it was kept.
  final double? breathLeft;
  final int? tankSize;

  /// False when the run had no movement access.
  final bool earnsLp;

  Duration? get pace => paceOf(duration, distanceM);

  Map<String, Object?> toJson() => {
    'companionId': companionId,
    'startedAt': startedAt.toIso8601String(),
    'durationS': duration.inSeconds,
    'distanceM': distanceM,
    'steps': steps,
    'lp': lp,
    'breathUsed': breathUsed,
    'valid': valid,
    'breathLeft': breathLeft,
    'tankSize': tankSize,
    'earnsLp': earnsLp,
  };

  factory RunSummary.fromJson(Map<String, Object?> json) => RunSummary(
    companionId: json['companionId']! as String,
    startedAt: DateTime.parse(json['startedAt']! as String),
    duration: Duration(seconds: json['durationS']! as int),
    distanceM: (json['distanceM']! as num).toDouble(),
    steps: json['steps']! as int,
    lp: (json['lp']! as num).toDouble(),
    breathUsed: (json['breathUsed']! as num).toDouble(),
    valid: json['valid']! as bool,
    breathLeft: (json['breathLeft'] as num?)?.toDouble(),
    tankSize: json['tankSize'] as int?,
    earnsLp: json['earnsLp'] as bool? ?? true,
  );
}
