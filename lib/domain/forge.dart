import 'companion.dart';

/// Seal prices and limits. Seals are bought with LP only, set locally into a
/// free charm socket of one companion and stay on it.
class Forge {
  static const int maxPerStat = 3;

  /// LP for the first, second and third seal on the same stat.
  static const List<double> costs = [40, 90, 160];

  /// LP for the next seal of [type] on [c], or null once the stat is at +3.
  static double? nextCost(Companion c, SealType type) {
    final n = c.sealCount(type);
    return n < maxPerStat ? costs[n] : null;
  }
}
