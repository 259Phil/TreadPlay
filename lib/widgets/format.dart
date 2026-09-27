import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/shoe.dart';
import '../l10n/app_localizations.dart';

String formatKm(BuildContext context, double meters) => NumberFormat(
  '0.00',
  Localizations.localeOf(context).toString(),
).format(meters / 1000);

String formatNumber(
  BuildContext context,
  double value, {
  String pattern = '0.#',
}) => NumberFormat(
  pattern,
  Localizations.localeOf(context).toString(),
).format(value);

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String shoeTypeLabel(AppLocalizations l, ShoeType type) => switch (type) {
  ShoeType.stomper => l.typeStomper,
  ShoeType.strider => l.typeStrider,
  ShoeType.dasher => l.typeDasher,
};

String rarityLabel(AppLocalizations l, Rarity rarity) => switch (rarity) {
  Rarity.common => l.rarityCommon,
  Rarity.rare => l.rarityRare,
  Rarity.epic => l.rarityEpic,
  Rarity.legendary => l.rarityLegendary,
};
