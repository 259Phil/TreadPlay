import '../domain/run_summary.dart';
import '../domain/shoe.dart';

class GameData {
  const GameData({
    required this.lp,
    required this.shoes,
    required this.activeShoeId,
    required this.runs,
  });

  factory GameData.initial(DateTime now) {
    final cobble = Shoe.cobble(now);
    return GameData(lp: 0, shoes: [cobble], activeShoeId: cobble.id, runs: []);
  }

  static const int maxStoredRuns = 50;

  final double lp;
  final List<Shoe> shoes;
  final String activeShoeId;

  /// Newest first.
  final List<RunSummary> runs;

  Shoe get activeShoe => shoes.firstWhere((s) => s.id == activeShoeId);

  RunSummary? get lastRun => runs.isEmpty ? null : runs.first;

  GameData copyWith({
    double? lp,
    List<Shoe>? shoes,
    String? activeShoeId,
    List<RunSummary>? runs,
  }) => GameData(
    lp: lp ?? this.lp,
    shoes: shoes ?? this.shoes,
    activeShoeId: activeShoeId ?? this.activeShoeId,
    runs: runs ?? this.runs,
  );

  GameData replaceShoe(Shoe shoe) =>
      copyWith(shoes: [for (final s in shoes) s.id == shoe.id ? shoe : s]);

  Map<String, Object?> toJson() => {
    'lp': lp,
    'shoes': [for (final s in shoes) s.toJson()],
    'activeShoeId': activeShoeId,
    'runs': [for (final r in runs) r.toJson()],
  };

  factory GameData.fromJson(Map<String, Object?> json) => GameData(
    lp: (json['lp']! as num).toDouble(),
    shoes: [
      for (final s in json['shoes']! as List<Object?>)
        Shoe.fromJson(s! as Map<String, Object?>),
    ],
    activeShoeId: json['activeShoeId']! as String,
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
