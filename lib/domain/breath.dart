import 'dart:math';

const Duration breathRegenInterval = Duration(minutes: 90);

/// The player's one Breath bar, shared by all companions. Its cap is the tank
/// size of the companion taken along; owning more companions adds nothing.
class Breath {
  const Breath({required this.points, required this.updatedAt});

  factory Breath.full(int cap, DateTime now) =>
      Breath(points: cap.toDouble(), updatedAt: now);

  final double points;
  final DateTime updatedAt;

  /// Adds 1 point per [breathRegenInterval] since [updatedAt], up to [cap].
  Breath regenerated(DateTime now, int cap) {
    if (!now.isAfter(updatedAt)) return this;
    final gained =
        now.difference(updatedAt).inSeconds / breathRegenInterval.inSeconds;
    return Breath(points: min(cap.toDouble(), points + gained), updatedAt: now);
  }

  Breath capped(int cap) => points <= cap
      ? this
      : Breath(points: cap.toDouble(), updatedAt: updatedAt);

  Map<String, Object?> toJson() => {
    'points': points,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Breath.fromJson(Map<String, Object?> json) => Breath(
    points: (json['points']! as num).toDouble(),
    updatedAt: DateTime.parse(json['updatedAt']! as String),
  );
}
