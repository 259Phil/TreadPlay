import '../domain/companion.dart';
import '../domain/run_summary.dart';

class GameData {
  const GameData({
    required this.lp,
    required this.companions,
    required this.activeCompanionId,
    required this.runs,
  });

  factory GameData.initial(DateTime now) {
    final pebble = Companion.pebble(now);
    return GameData(
      lp: 0,
      companions: [pebble],
      activeCompanionId: pebble.id,
      runs: const [],
    );
  }

  static const int maxStoredRuns = 50;
  static const int inventoryCap = 12;

  final double lp;
  final List<Companion> companions;
  final String activeCompanionId;

  /// Newest first.
  final List<RunSummary> runs;

  Companion get activeCompanion =>
      companions.firstWhere((c) => c.id == activeCompanionId);

  RunSummary? get lastRun => runs.isEmpty ? null : runs.first;

  /// The last companion can never be sold, so a player is never left without
  /// one; selling also needs full Spirit.
  bool canSell(String companionId) {
    if (companions.length < 2) return false;
    final c = companions.where((c) => c.id == companionId).firstOrNull;
    return c != null && c.spirit >= 100;
  }

  GameData copyWith({
    double? lp,
    List<Companion>? companions,
    String? activeCompanionId,
    List<RunSummary>? runs,
  }) => GameData(
    lp: lp ?? this.lp,
    companions: companions ?? this.companions,
    activeCompanionId: activeCompanionId ?? this.activeCompanionId,
    runs: runs ?? this.runs,
  );

  GameData replaceCompanion(Companion companion) => copyWith(
    companions: [
      for (final c in companions) c.id == companion.id ? companion : c,
    ],
  );

  Map<String, Object?> toJson() => {
    'lp': lp,
    'companions': [for (final c in companions) c.toJson()],
    'activeCompanionId': activeCompanionId,
    'runs': [for (final r in runs) r.toJson()],
  };

  factory GameData.fromJson(Map<String, Object?> json) => GameData(
    lp: (json['lp']! as num).toDouble(),
    companions: [
      for (final c in json['companions']! as List<Object?>)
        Companion.fromJson(c! as Map<String, Object?>),
    ],
    activeCompanionId: json['activeCompanionId']! as String,
    runs: [
      for (final r in json['runs']! as List<Object?>)
        RunSummary.fromJson(r! as Map<String, Object?>),
    ],
  );
}

class AppSettings {
  const AppSettings({this.localeCode = 'en', this.kaching = true});

  final String localeCode;
  final bool kaching;

  AppSettings copyWith({String? localeCode, bool? kaching}) => AppSettings(
    localeCode: localeCode ?? this.localeCode,
    kaching: kaching ?? this.kaching,
  );

  Map<String, Object?> toJson() => {
    'localeCode': localeCode,
    'kaching': kaching,
  };

  factory AppSettings.fromJson(Map<String, Object?> json) => AppSettings(
    localeCode: json['localeCode'] as String? ?? 'en',
    kaching: json['kaching'] as bool? ?? true,
  );
}
