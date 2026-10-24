import 'messenger.dart';
import 'pouch.dart';

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
    this.sweetSpotShare,
    this.glut = 0,
    this.pouch,
    this.leashFull = false,
    this.pouchesWarmed = 0,
    this.messenger,
    this.spiritLost = 0,
    this.spiritAfter,
    this.xpGained = 0,
    this.levelReady = false,
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

  /// Share (0–1) of the run's time inside the sweet spot range; null for runs
  /// saved before it was tracked.
  final double? sweetSpotShare;

  /// Glut this run brought for the Forge (only when it found no pouch).
  final int glut;

  /// Pouch this run found, if any.
  final PouchColor? pouch;

  /// The leash was full, so the run could not find a pouch.
  final bool leashFull;

  /// Pouches on the leash this run warmed all the way (free to open now).
  final int pouchesWarmed;

  /// The messenger that came after this run, if any.
  final Messenger? messenger;

  /// Mut the companion lost on this run (percent points, after Grit).
  final double spiritLost;

  /// The companion's Mut after the run; null for runs before Mut dropped.
  final double? spiritAfter;

  /// XP the companion gained on this run.
  final int xpGained;

  /// The companion has the XP for its next level after this run.
  final bool levelReady;

  Duration? get pace => paceOf(duration, distanceM);

  /// The companion's Mut and XP change from this run.
  RunSummary withCompanion({
    required double spiritLost,
    required double spiritAfter,
    required int xpGained,
    required bool levelReady,
  }) => _copy(
    spiritLost: spiritLost,
    spiritAfter: spiritAfter,
    xpGained: xpGained,
    levelReady: levelReady,
  );

  RunSummary _copy({
    int? glut,
    PouchColor? Function()? pouch,
    bool? leashFull,
    int? pouchesWarmed,
    Messenger? Function()? messenger,
    double? spiritLost,
    double? spiritAfter,
    int? xpGained,
    bool? levelReady,
  }) => RunSummary(
    companionId: companionId,
    startedAt: startedAt,
    duration: duration,
    distanceM: distanceM,
    steps: steps,
    lp: lp,
    breathUsed: breathUsed,
    valid: valid,
    breathLeft: breathLeft,
    tankSize: tankSize,
    earnsLp: earnsLp,
    sweetSpotShare: sweetSpotShare,
    glut: glut ?? this.glut,
    pouch: pouch != null ? pouch() : this.pouch,
    leashFull: leashFull ?? this.leashFull,
    pouchesWarmed: pouchesWarmed ?? this.pouchesWarmed,
    messenger: messenger != null ? messenger() : this.messenger,
    spiritLost: spiritLost ?? this.spiritLost,
    spiritAfter: spiritAfter ?? this.spiritAfter,
    xpGained: xpGained ?? this.xpGained,
    levelReady: levelReady ?? this.levelReady,
  );

  RunSummary withRewards({
    required int glut,
    PouchColor? pouch,
    bool leashFull = false,
    int pouchesWarmed = 0,
    Messenger? messenger,
  }) => _copy(
    glut: glut,
    pouch: () => pouch,
    leashFull: leashFull,
    pouchesWarmed: pouchesWarmed,
    messenger: () => messenger,
  );

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
    if (sweetSpotShare case final s?) 'sweetSpotShare': s,
    if (glut > 0) 'glut': glut,
    if (pouch case final p?) 'pouch': p.name,
    if (leashFull) 'leashFull': true,
    if (pouchesWarmed > 0) 'pouchesWarmed': pouchesWarmed,
    if (messenger case final m?) 'messenger': m.name,
    if (spiritLost > 0) 'spiritLost': spiritLost,
    if (spiritAfter case final s?) 'spiritAfter': s,
    if (xpGained > 0) 'xpGained': xpGained,
    if (levelReady) 'levelReady': true,
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
    sweetSpotShare: (json['sweetSpotShare'] as num?)?.toDouble(),
    glut: json['glut'] as int? ?? 0,
    pouch: PouchColor.tryParse(json['pouch']),
    leashFull: json['leashFull'] as bool? ?? false,
    pouchesWarmed: json['pouchesWarmed'] as int? ?? 0,
    messenger: Messenger.tryParse(json['messenger']),
    spiritLost: (json['spiritLost'] as num?)?.toDouble() ?? 0,
    spiritAfter: (json['spiritAfter'] as num?)?.toDouble(),
    xpGained: (json['xpGained'] as num?)?.toInt() ?? 0,
    levelReady: json['levelReady'] as bool? ?? false,
  );
}
