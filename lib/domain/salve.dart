/// Mutsalben: they restore a companion's Mut (Spirit). Bought in the
/// Market for LP, kept in the Vorrat, used on any companion on the shelf.
/// A small one is sometimes found in a brown or copper pouch.
enum Salve {
  /// Small tin: +15 % Mut.
  small(points: 15, price: 5),

  /// Jar: +40 % Mut.
  medium(points: 40, price: 12),

  /// Rune pot: back to 100 % Mut.
  large(points: 100, price: 28);

  const Salve({required this.points, required this.price});

  /// Mut points it adds (the large one fills up whatever is missing).
  final double points;

  /// Base price in LP before the Market's drift.
  final int price;

  static Salve? tryParse(Object? name) =>
      name is String ? values.asNameMap()[name] : null;
}

/// Salves in the Vorrat.
class SalveStock {
  const SalveStock([this.counts = const {}]);

  final Map<Salve, int> counts;

  int count(Salve s) => counts[s] ?? 0;

  int get total => counts.values.fold(0, (n, v) => n + v);

  bool get isEmpty => total == 0;

  SalveStock adding(Salve s, [int n = 1]) {
    final next = {...counts};
    final v = count(s) + n;
    if (v <= 0) {
      next.remove(s);
    } else {
      next[s] = v;
    }
    return SalveStock(next);
  }

  SalveStock removing(Salve s) => adding(s, -1);

  Map<String, Object?> toJson() => {
    for (final e in counts.entries)
      if (e.value > 0) e.key.name: e.value,
  };

  /// Unknown salves and bad counts are dropped.
  factory SalveStock.fromJson(Object? json) => SalveStock({
    if (json is Map)
      for (final e in json.entries)
        if ((Salve.tryParse(e.key), e.value) case (
          final s?,
          final int n,
        ) when n > 0)
          s: n,
  });
}
