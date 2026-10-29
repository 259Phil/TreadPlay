import 'companion.dart';

/// Sammlerbonus: a bigger shared Breath tank for a well-kept collection.
/// Only companions with at least [minSpirit] % Mut count.
abstract final class Collector {
  /// Companions needed for +1, +2 and +3 Breath tank.
  static const List<int> tiers = [5, 10, 20];

  static const double minSpirit = 50;

  static bool counts(Companion c) => c.spirit >= minSpirit;

  /// Companions that count towards the bonus.
  static int countOf(Iterable<Companion> companions) =>
      companions.where(counts).length;

  /// Extra Breath tank for [count] counting companions (0 to 3).
  static int bonusFor(int count) => tiers.where((t) => count >= t).length;

  /// Counting companions needed for the next step, or null at the top.
  static int? nextTierFor(int count) {
    for (final t in tiers) {
      if (count < t) return t;
    }
    return null;
  }
}

/// Shelf slots bought for LP on top of the base and the waymark slots.
abstract final class ShelfSlots {
  /// Never more slots than this, however they came.
  static const int max = 30;

  /// The first slot bought (slot 15 with waymark 17) costs this; every
  /// further one [priceStep] more than the one before.
  static const int firstPrice = 60;
  static const int priceStep = 30;

  /// Slots that can be bought at all: up to [max] from base plus waymark.
  static const int maxBought = max - 14;

  /// LP for the next slot after [bought] slots were bought.
  static int priceAfter(int bought) => firstPrice + priceStep * bought;
}
