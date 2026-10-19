# Visual swap

Final painted assets for the Flutter app. Swap these in. Do not change game logic, numbers, shared Breath, market rules, forge costs, tests, or the forbidden-terms check.

## Cutouts

Path: `assets/companions/`

These PNGs are clean cutouts: transparent background, no leftover border, no gray liner, feet complete. Checked on black and on white.

| File | Rarity |
|---|---|
| `{id}.png` | Common |
| `{id}-rare.png` | Rare |
| `{id}-epic.png` | Epic |
| `{id}-legendary.png` | Legendary |

Ids: `pebble`, `lumen`, `coil`, `gilt`, `hookfin`, `valve`, `dune`, `brine`, `vine`, `glaze`.

Rare, Epic, and Legendary are the same body with a stronger crest, glow, or world trait. The metal frame stays in code, not in the PNG.

Older files such as `pebble_c.png`, `gilt_r.png`, and `gilt_l.png` are the previous set. Point the app at the names above. Do not keep using the `_c` / `_r` / `_l` suffixes.

## Worlds

Path: `assets/worlds/`

Ten backgrounds, one per companion. Use the world of the companion that is equipped.

| Companion | World file |
|---|---|
| pebble | `medieval.jpg` |
| lumen | `space.jpg` |
| coil | `robot.jpg` |
| gilt | `rococo.jpg` |
| hookfin | `pirate.jpg` |
| valve | `steam.jpg` |
| dune | `egypt.jpg` |
| brine | `water.jpg` |
| vine | `jungle.jpg` |
| glaze | `candy.jpg` |

Older `*_bg.jpg` files can stay until those references are replaced.

## What to change in the UI

- **Home:** world background of the equipped companion. Companion larger, feet on the ground.
- **Shelf and Market:** the PNG that matches the companion's rarity. Keep the metal frame in code: Common steel, Rare bronze, Epic copper, Legendary brass plus a quiet glow.
- **Forge:** show every socket for that rarity (1 / 2 / 2 / 3). A filled socket can be cleared. Clearing costs no LP. Seals are three metals: Stride steel, Grit copper, Fortune brass.

## What to leave alone

Logic, numbers, shared Breath, market rules, forge costs, tests, and CI. Only replace assets and adjust layout and spacing to match the polished web version.
