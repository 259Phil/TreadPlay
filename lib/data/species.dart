import '../domain/companion.dart';
import '../domain/world.dart';

/// One invented creature. Every species exists in all four rarities; rarer
/// ones share the body and add an extra (crest, glow, ridge).
class Species {
  const Species({
    required this.id,
    required this.name,
    required this.world,
    required this.type,
  });

  final String id;
  final String name;
  final World world;
  final CompanionType type;
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
    name: 'Kurlo',
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
    name: 'Kettlo',
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
];

final Map<String, Species> speciesById = {
  for (final s in speciesCatalog) s.id: s,
};
