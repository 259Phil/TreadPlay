class RunSummary {
  const RunSummary({
    required this.shoeId,
    required this.startedAt,
    required this.duration,
    required this.distanceM,
    required this.steps,
    required this.lp,
    required this.breathUsed,
    required this.valid,
  });

  final String shoeId;
  final DateTime startedAt;
  final Duration duration;
  final double distanceM;
  final int steps;
  final double lp;
  final double breathUsed;
  final bool valid;

  Map<String, Object?> toJson() => {
    'shoeId': shoeId,
    'startedAt': startedAt.toIso8601String(),
    'durationS': duration.inSeconds,
    'distanceM': distanceM,
    'steps': steps,
    'lp': lp,
    'breathUsed': breathUsed,
    'valid': valid,
  };

  factory RunSummary.fromJson(Map<String, Object?> json) => RunSummary(
    shoeId: json['shoeId']! as String,
    startedAt: DateTime.parse(json['startedAt']! as String),
    duration: Duration(seconds: json['durationS']! as int),
    distanceM: (json['distanceM']! as num).toDouble(),
    steps: json['steps']! as int,
    lp: (json['lp']! as num).toDouble(),
    breathUsed: (json['breathUsed']! as num).toDouble(),
    valid: json['valid']! as bool,
  );
}
