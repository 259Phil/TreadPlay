import '../domain/companion.dart';
import '../domain/world.dart';

/// How often a species turns up in the Market, next to the other species
/// of its pool. Independent of [Rarity]: a scarce species still comes in
/// all four rarities.
enum FindRate {
  frequent(1.0),
  scarce(0.5),
  elusive(0.25),
  mythic(0.1);

  const FindRate(this.weight);

  /// Relative weight when the Market picks a species for an offer.
  final double weight;
}

/// One invented creature. Every species exists in all four rarities; rarer
/// ones share the body and add an extra (crest, glow, ridge).
class Species {
  const Species({
    required this.id,
    required this.name,
    required this.world,
    required this.type,
    this.findRate = FindRate.frequent,
    this.unlockKm = 0,
  });

  /// Save id; never changes, even when the display name does.
  final String id;
  final String name;
  final World world;
  final CompanionType type;

  /// Weight in the Market's species pick.
  final FindRate findRate;

  /// Lifetime km walked before the Market offers this species; its world
  /// has to be open as well. 0 = with its world.
  final double unlockKm;

  /// True once [distanceM] lifetime metres pass [unlockKm].
  bool openAt(double distanceM) => distanceM >= unlockKm * 1000 - 1e-6;
}

const List<Species> speciesCatalog = [
  Species(
    id: 'pebble',
    name: 'Mossik',
    world: World.medieval,
    type: CompanionType.moss,
  ),
  Species(
    id: 'lumen',
    name: 'Astrillo',
    world: World.space,
    type: CompanionType.brook,
  ),
  Species(
    id: 'coil',
    name: 'Krullo',
    world: World.robot,
    type: CompanionType.moss,
  ),
  Species(
    id: 'gilt',
    name: 'Frilla',
    world: World.rococo,
    type: CompanionType.brook,
  ),
  Species(
    id: 'hookfin',
    name: 'Finzack',
    world: World.pirate,
    type: CompanionType.gale,
  ),
  Species(
    id: 'valve',
    name: 'Kettrik',
    world: World.steampunk,
    type: CompanionType.moss,
  ),
  Species(
    id: 'dune',
    name: 'Sahri',
    world: World.egypt,
    type: CompanionType.gale,
  ),
  Species(
    id: 'brine',
    name: 'Blubbo',
    world: World.underwater,
    type: CompanionType.brook,
  ),
  Species(
    id: 'vine',
    name: 'Rankix',
    world: World.jungle,
    type: CompanionType.moss,
  ),
  Species(
    id: 'glaze',
    name: 'Zuckli',
    world: World.candy,
    type: CompanionType.gale,
  ),
  // Second wave: rarer finds, opened along the trail (unlockKm).
  Species(
    id: 'zinnbuck',
    name: 'Zinnbuck',
    world: World.medieval,
    type: CompanionType.moss,
    findRate: FindRate.frequent,
    unlockKm: 0,
  ),
  Species(
    id: 'ringelpanz',
    name: 'Ringelpanz',
    world: World.medieval,
    type: CompanionType.brook,
    findRate: FindRate.scarce,
    unlockKm: 2.3,
  ),
  Species(
    id: 'nebulo',
    name: 'Nebulo',
    world: World.space,
    type: CompanionType.moss,
    findRate: FindRate.frequent,
    unlockKm: 77.4,
  ),
  Species(
    id: 'kraterix',
    name: 'Kraterix',
    world: World.space,
    type: CompanionType.gale,
    findRate: FindRate.elusive,
    unlockKm: 101.3,
  ),
  Species(
    id: 'drahtel',
    name: 'Drahtel',
    world: World.robot,
    type: CompanionType.brook,
    findRate: FindRate.scarce,
    unlockKm: 88.8,
  ),
  Species(
    id: 'muttrix',
    name: 'Muttrix',
    world: World.robot,
    type: CompanionType.moss,
    findRate: FindRate.frequent,
    unlockKm: 77.4,
  ),
  Species(
    id: 'porzella',
    name: 'Porzella',
    world: World.rococo,
    type: CompanionType.brook,
    findRate: FindRate.elusive,
    unlockKm: 150,
  ),
  Species(
    id: 'puderling',
    name: 'Puderling',
    world: World.rococo,
    type: CompanionType.moss,
    findRate: FindRate.frequent,
    unlockKm: 128.2,
  ),
  Species(
    id: 'teerbock',
    name: 'Teerbock',
    world: World.pirate,
    type: CompanionType.moss,
    findRate: FindRate.frequent,
    unlockKm: 28.4,
  ),
  Species(
    id: 'segelkamm',
    name: 'Segelkamm',
    world: World.pirate,
    type: CompanionType.gale,
    findRate: FindRate.scarce,
    unlockKm: 34.7,
  ),
  Species(
    id: 'messingor',
    name: 'Messingor',
    world: World.steampunk,
    type: CompanionType.gale,
    findRate: FindRate.mythic,
    unlockKm: 66.9,
  ),
  Species(
    id: 'emaillo',
    name: 'Emaillo',
    world: World.steampunk,
    type: CompanionType.brook,
    findRate: FindRate.frequent,
    unlockKm: 41.3,
  ),
  Species(
    id: 'papyrix',
    name: 'Papyrix',
    world: World.egypt,
    type: CompanionType.brook,
    findRate: FindRate.scarce,
    unlockKm: 28.4,
  ),
  Species(
    id: 'lapisor',
    name: 'Lapisor',
    world: World.egypt,
    type: CompanionType.gale,
    findRate: FindRate.mythic,
    unlockKm: 57.2,
  ),
  Species(
    id: 'muschlo',
    name: 'Muschlo',
    world: World.underwater,
    type: CompanionType.moss,
    findRate: FindRate.frequent,
    unlockKm: 13.2,
  ),
  Species(
    id: 'tangwell',
    name: 'Tangwell',
    world: World.underwater,
    type: CompanionType.gale,
    findRate: FindRate.elusive,
    unlockKm: 22.9,
  ),
  Species(
    id: 'farnix',
    name: 'Farnix',
    world: World.jungle,
    type: CompanionType.brook,
    findRate: FindRate.frequent,
    unlockKm: 4.1,
  ),
  Species(
    id: 'schwammo',
    name: 'Schwammo',
    world: World.jungle,
    type: CompanionType.moss,
    findRate: FindRate.scarce,
    unlockKm: 9.4,
  ),
  Species(
    id: 'karamello',
    name: 'Karamello',
    world: World.candy,
    type: CompanionType.brook,
    findRate: FindRate.scarce,
    unlockKm: 128.2,
  ),
  Species(
    id: 'lakrillo',
    name: 'Lakrillo',
    world: World.candy,
    type: CompanionType.gale,
    findRate: FindRate.elusive,
    unlockKm: 175,
  ),
];

final Map<String, Species> speciesById = {
  for (final s in speciesCatalog) s.id: s,
};
