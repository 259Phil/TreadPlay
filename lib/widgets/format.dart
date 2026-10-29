import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../data/species.dart';
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
      'zinnbuck' => l.flavourZinnbuck,
      'ringelpanz' => l.flavourRingelpanz,
      'nebulo' => l.flavourNebulo,
      'kraterix' => l.flavourKraterix,
      'drahtel' => l.flavourDrahtel,
      'muttrix' => l.flavourMuttrix,
      'porzella' => l.flavourPorzella,
      'puderling' => l.flavourPuderling,
      'teerbock' => l.flavourTeerbock,
      'segelkamm' => l.flavourSegelkamm,
      'messingor' => l.flavourMessingor,
      'emaillo' => l.flavourEmaillo,
      'papyrix' => l.flavourPapyrix,
      'lapisor' => l.flavourLapisor,
      'muschlo' => l.flavourMuschlo,
      'tangwell' => l.flavourTangwell,
      'farnix' => l.flavourFarnix,
      'schwammo' => l.flavourSchwammo,
      'karamello' => l.flavourKaramello,
      'lakrillo' => l.flavourLakrillo,
      _ => null,
    };

/// How often a species turns up in the Market, as a word.
String findRateLabel(AppLocalizations l, FindRate r) => switch (r) {
  FindRate.frequent => l.findRateFrequent,
  FindRate.scarce => l.findRateScarce,
  FindRate.elusive => l.findRateElusive,
  FindRate.mythic => l.findRateMythic,
};
