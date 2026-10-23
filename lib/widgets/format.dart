import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/companion.dart';
import '../domain/world.dart';
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

String typeLabel(AppLocalizations l, CompanionType type) => switch (type) {
  CompanionType.moss => l.typeMoss,
  CompanionType.brook => l.typeBrook,
  CompanionType.gale => l.typeGale,
};

String rarityLabel(AppLocalizations l, Rarity rarity) => switch (rarity) {
  Rarity.common => l.rarityCommon,
  Rarity.rare => l.rarityRare,
  Rarity.epic => l.rarityEpic,
  Rarity.legendary => l.rarityLegendary,
};

String worldLabel(AppLocalizations l, World world) => switch (world) {
  World.medieval => l.worldMedieval,
  World.space => l.worldSpace,
  World.underwater => l.worldUnderwater,
  World.egypt => l.worldEgypt,
  World.jungle => l.worldJungle,
  World.pirate => l.worldPirate,
  World.robot => l.worldRobot,
  World.rococo => l.worldRococo,
  World.steampunk => l.worldSteampunk,
  World.candy => l.worldCandy,
};

/// Pace as m:ss (per km), or a dash before there is distance.
String formatPace(Duration? pace) {
  if (pace == null) return '–';
  final m = pace.inMinutes;
  final s = pace.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// One-line flavour text for a species, or null for unknown ids.
String? speciesFlavour(AppLocalizations l, String speciesId) =>
    switch (speciesId) {
      'pebble' => l.flavourPebble,
      'lumen' => l.flavourLumen,
      'coil' => l.flavourCoil,
      'gilt' => l.flavourGilt,
      'hookfin' => l.flavourHookfin,
      'valve' => l.flavourValve,
      'dune' => l.flavourDune,
      'brine' => l.flavourBrine,
      'vine' => l.flavourVine,
      'glaze' => l.flavourGlaze,
      _ => null,
    };
